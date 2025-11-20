import 'package:flint_dart/flint_dart.dart';
import 'package:flint_dart/storage.dart';
import 'package:appclick_bank_backend/src/models/user_model.dart';

class UserController {
  /// List all users
  Future<Response> index(Request req, Response res) async {
    try {
      final users = await User().all();
      return res.json({
        "status": "success",
        "message": "Users retrieved successfully",
        "users": users.map((user) => user.toMap()).toList(),
      });
    } catch (e) {
      return res.status(500).json({
        "status": "error",
        "message": "Failed to retrieve users: ${e.toString()}",
      });
    }
  }

  /// Get single user
  Future<Response> show(Request req, Response res) async {
    try {
      final user = await User().find(req.params['id']);
      if (user != null) {
        return res.json({
          "status": "success",
          "message": "User retrieved successfully",
          "user": user.toMap()
        });
      }
      return res
          .status(404)
          .json({"status": "error", "message": "User not found"});
    } catch (e) {
      return res.status(500).json({
        "status": "error",
        "message": "Failed to retrieve user: ${e.toString()}",
      });
    }
  }

  /// Update general user info
  Future<Response> update(Request req, Response res) async {
    try {
      final String userId = req.params['id']!;
      final user = await User().find(userId);
      if (user == null) {
        return res
            .status(404)
            .json({"status": "error", "message": "User not found"});
      }

      final body = await req.form();
      final Map<String, dynamic> updateData = {};

      if (body['name'] != null && body['name']!.isNotEmpty) {
        updateData['name'] = body['name'];
      }

      if (body['phone_number'] != null && body['phone_number']!.isNotEmpty) {
        updateData['phone_number'] = int.tryParse(body['phone_number']!);
      }

      if (await req.hasFile('profile_pic')) {
        final file = await req.file('profile_pic');
        if (file != null) {
          // Validate file type
          final allowedTypes = [
            'image/jpeg',
            'image/png',
            'image/gif',
            'image/webp'
          ];
          if (!allowedTypes.contains(file.contentType)) {
            return res.status(400).json({
              "status": "error",
              "message": "Profile picture must be JPEG, PNG, GIF, or WebP"
            });
          }

          if (user.profilePicUrl != null) {
            updateData['profile_pic_url'] = await Storage.update(
                user.profilePicUrl!, file,
                subdirectory: 'profiles');
          } else {
            updateData['profile_pic_url'] =
                await Storage.create(file, subdirectory: 'profiles');
          }
        }
      }

      if (updateData.isNotEmpty) {
        await user.update(userId, updateData);
      }

      final updatedUser = await User().find(userId);
      return res.json({
        "status": "success",
        "message": "User updated successfully",
        "user": updatedUser?.toMap(),
      });
    } catch (e) {
      return res.status(500).json({
        "status": "error",
        "message": "Failed to update user: ${e.toString()}",
      });
    }
  }

  /// Upload/verify BVN
  Future<Response> uploadBVN(Request req, Response res) async {
    try {
      final String userId = req.params['id']!;
      final body = await req.form();
      final bvn = body['bvn'];
      print(bvn);
      if (bvn == null || bvn.length != 11) {
        return res.status(400).json({
          "status": "error",
          "message": "BVN is required and must be 11 digits"
        });
      }

      // Validate BVN contains only digits
      if (!RegExp(r'^\d{11}$').hasMatch(bvn)) {
        return res.status(400).json(
            {"status": "error", "message": "BVN must contain only digits"});
      }

      final user = await User().find(userId);
      if (user == null) {
        return res
            .status(404)
            .json({"status": "error", "message": "User not found"});
      }

      await user.update(userId, {"bvn": bvn});

      final updatedUser = await User().find(userId);
      return res.json({
        "status": "success",
        "message": "BVN updated successfully",
        "bvn": bvn,
        "user": updatedUser?.toMap()
      });
    } catch (e) {
      return res.status(500).json({
        "status": "error",
        "message": "Failed to update BVN: ${e.toString()}",
      });
    }
  }

  /// Upload/verify NIN
  Future<Response> uploadNIN(Request req, Response res) async {
    try {
      final String userId = req.params['id']!;
      final body = await req.form();
      final nin = body['nin'];

      if (nin == null || nin.length != 11) {
        return res.status(400).json({
          "status": "error",
          "message": "NIN is required and must be 11 digits"
        });
      }

      // Validate NIN contains only digits
      if (!RegExp(r'^\d{11}$').hasMatch(nin)) {
        return res.status(400).json(
            {"status": "error", "message": "NIN must contain only digits"});
      }

      final user = await User().find(userId);
      if (user == null) {
        return res
            .status(404)
            .json({"status": "error", "message": "User not found"});
      }

      await user.update(userId, {"nin": nin});

      final updatedUser = await User().find(userId);
      return res.json({
        "status": "success",
        "message": "NIN updated successfully",
        "nin": nin,
        "user": updatedUser?.toMap()
      });
    } catch (e) {
      return res.status(500).json({
        "status": "error",
        "message": "Failed to update NIN: ${e.toString()}",
      });
    }
  }

  /// Update PIN
  Future<Response> updatePIN(Request req, Response res) async {
    try {
      final String userId = req.params['id']!;
      final body = await req.form();
      final pin = body['pin'];

      if (pin == null || pin.length < 4 || pin.length > 6) {
        return res.status(400).json(
            {"status": "error", "message": "PIN is required (4-6 digits)"});
      }

      // Validate PIN contains only digits
      if (!RegExp(r'^\d+$').hasMatch(pin)) {
        return res.status(400).json(
            {"status": "error", "message": "PIN must contain only digits"});
      }

      final user = await User().find(userId);
      if (user == null) {
        return res
            .status(404)
            .json({"status": "error", "message": "User not found"});
      }

      // Use Hashing().hash() for PIN
      final hashedPin = Hashing().hash(pin).toString();
      await user.update(userId, {"pin": hashedPin});

      return res
          .json({"status": "success", "message": "PIN updated successfully"});
    } catch (e) {
      return res.status(500).json({
        "status": "error",
        "message": "Failed to update PIN: ${e.toString()}",
      });
    }
  }

  /// Delete user
  Future<Response> delete(Request req, Response res) async {
    try {
      final userId = req.params['id']!;
      final user = await User().find(userId);
      if (user == null) {
        return res
            .status(404)
            .json({"status": "error", "message": "User not found"});
      }

      // Delete profile picture if exists
      if (user.profilePicUrl != null) {
        await Storage.delete(user.profilePicUrl!);
      }

      await user.delete();
      return res
          .json({"status": "success", "message": "User deleted successfully"});
    } catch (e) {
      return res.status(500).json({
        "status": "error",
        "message": "Failed to delete user: ${e.toString()}",
      });
    }
  }
}
