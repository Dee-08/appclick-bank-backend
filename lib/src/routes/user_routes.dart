import 'package:flint_dart/flint_dart.dart';
import 'package:appclick_bank_backend/src/middlewares/auth_middleware.dart';
import '../controllers/user_controller.dart';

void registerUserRoutes(Flint app) {
  final controller = UserController();

  /// @summary Get all users
  /// @auth bearer
  /// @prefix /users
  /// @response 200 Users retrieved successfully
  /// @response 401 Unauthorized
  /// @response 500 Internal server error
  /// @server http://localhost:3000
  /// @server https://api.mydomain.com
  app.get("/", AuthMiddleware().handle(controller.index));

  /// @summary Get user by ID
  /// @auth bearer
  /// @prefix /users
  /// @response 200 User retrieved successfully
  /// @response 404 User not found
  /// @response 500 Internal server error
  app.get("/:id", AuthMiddleware().handle(controller.show));

  /// @summary Update user profile
  /// @auth bearer
  /// @prefix /users
  /// @param name formData string optional User's full name
  /// @param phone_number formData string optional User's phone number
  /// @param profile_pic formData file optional User's profile picture
  /// @response 200 User updated successfully
  /// @response 400 Invalid file type
  /// @response 404 User not found
  /// @response 500 Internal server error
  app.put("/:id", AuthMiddleware().handle(controller.update));

  /// @summary Upload BVN
  /// @auth bearer
  /// @prefix /users
  /// @param bvn formData string required 11-digit BVN
  /// @response 200 BVN updated successfully
  /// @response 400 BVN must be 11 digits
  /// @response 404 User not found
  /// @response 500 Internal server error
  app.post("/:id/bvn", AuthMiddleware().handle(controller.uploadBVN));

  /// @summary Upload NIN
  /// @auth bearer
  /// @prefix /users
  /// @param nin formData string required 11-digit NIN
  /// @response 200 NIN updated successfully
  /// @response 400 NIN must be 11 digits
  /// @response 404 User not found
  /// @response 500 Internal server error
  app.post("/:id/nin", AuthMiddleware().handle(controller.uploadNIN));

  /// @summary Update PIN
  /// @auth bearer
  /// @prefix /users
  /// @param pin formData string required 4-6 digit PIN
  /// @response 200 PIN updated successfully
  /// @response 400 PIN must be 4-6 digits
  /// @response 404 User not found
  /// @response 500 Internal server error
  app.post("/:id/pin", AuthMiddleware().handle(controller.updatePIN));

  /// @summary Delete user
  /// @auth bearer
  /// @prefix /users
  /// @response 200 User deleted successfully
  /// @response 404 User not found
  /// @response 500 Internal server error
  app.delete("/:id", AuthMiddleware().handle(controller.delete));
}
