import 'package:flint_dart/auth.dart';
import 'package:flint_dart/flint_dart.dart';
import 'package:appclick_bank_backend/src/models/user_model.dart';

class AuthController {
  Future<Response> register(Request req, Response res) async {
    try {
      final body = await req.validate({
        "name": "required|string|min:2",
        "email": "required|email|min:3",
        "password": "required|string|min:6|confirmed",
      });

      // Check if user already exists
      final existingUser = await User().where('email', body['email']);
      if (existingUser.isNotEmpty) {
        return res.status(409).json({
          "status": "error",
          "message": "User with this email already exists"
        });
      }

      // Generate account number
      final accountNumber = User.generateAccountNumber();

      // Register user with Auth system
      final authData = await Auth.register(
        name: body["name"],
        email: body["email"],
        password: body["password"],
      );

      // Update user with account number and initial wallet balance
      final user = await User().find(authData['user']['id']);
      if (user != null) {
        await user.update(user.id!, {
          'account_number': accountNumber,
          'wallet_balance': 0.0,
          'ledger_balance': 0.0,
          'kyc_status': 'pending'
        });
      }

      return res.status(201).json({
        "status": "success",
        "message": "User registered successfully",
        "data": {
          "user": {
            "id": authData['user']['id'],
            "name": authData['user']['name'],
            "email": authData['user']['email'],
            "account_number": accountNumber,
          },
          "token": authData['token'],
        }
      });
    } on ValidationException catch (e) {
      return res.status(422).json({
        "status": "error",
        "message": "Validation failed",
        "errors": e.errors,
      });
    } catch (e) {
      return res.status(500).json({
        "status": "error",
        "message": "Registration failed: ${e.toString()}",
      });
    }
  }

  Future<Response> login(Request req, Response res) async {
    try {
      final body = await req
          .validate({"email": "required|email", "password": "required|string"});

      final token = await Auth.login(body['email'], body["password"]);

      // Get user data with account number
      final user = await User().where('email', body['email']);
      final userData = user.isNotEmpty ? user.first : null;

      return res.json({
        "status": "success",
        "message": "Login successful",
        "data": {
          "token": token,
          "user": userData != null
              ? {
                  "id": userData.id,
                  "name": userData.name,
                  "email": userData.email,
                  "account_number": userData.accountNumber,
                  "wallet_balance": userData.walletBalance,
                  "kyc_status": userData.kycStatus,
                }
              : null
        }
      });
    } on ValidationException catch (e) {
      return res.status(422).json({
        "status": "error",
        "message": "Validation failed",
        "errors": e.errors,
      });
    } catch (e) {
      return res.status(500).json({
        "status": "error",
        "message": "Login failed: ${e.toString()}",
      });
    }
  }

  Future<Response> profile(Request req, Response res) async {
    try {
      // Get user ID from token (adjust based on your auth implementation)
      final userId = req.cookies["id"];

      if (userId == null) {
        return res
            .status(401)
            .json({"status": "error", "message": "Unauthorized"});
      }

      final user = await User().find(userId);
      if (user == null) {
        return res
            .status(404)
            .json({"status": "error", "message": "User not found"});
      }

      return res.json({
        "status": "success",
        "message": "Profile retrieved successfully",
        "data": {"user": user.toMap()}
      });
    } catch (e) {
      return res.status(500).json({
        "status": "error",
        "message": "Failed to get profile: ${e.toString()}",
      });
    }
  }

  Future<Response> logout(Request req, Response res) async {
    try {
      // Implement logout logic
      final token = req.bearerToken;
      // Add token to blacklist or perform other logout actions

      return res.json({"status": "success", "message": "Logout successful"});
    } catch (e) {
      return res.status(500).json({
        "status": "error",
        "message": "Logout failed: ${e.toString()}",
      });
    }
  }
}
