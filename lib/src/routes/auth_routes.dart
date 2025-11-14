import 'package:flint_dart/flint_dart.dart';
import 'package:appclick_bank_backend/src/middlewares/auth_middleware.dart';
import '../controllers/auth_controller.dart';

void registerAuthRoutes(Flint app) {
  final controller = AuthController();

  /// @summary Register new user
  /// @body {"name": "string", "email": "string", "password": "string", "password_confirmation": "string"}
  /// @response 201 User registered successfully
  /// @response 422 Validation failed
  /// @response 409 User already exists
  /// @response 500 Registration failed
  app.post("/auth/register", controller.register);

  /// @summary Login user
  /// @body {"email": "string", "password": "string"}
  /// @response 200 Login successful
  /// @response 422 Validation failed
  /// @response 401 Invalid credentials
  /// @response 500 Login failed
  app.post("/auth/login", controller.login);

  /// @summary Get user profile
  /// @auth bearer
  /// @response 200 Profile retrieved successfully
  /// @response 401 Unauthorized
  /// @response 404 User not found
  /// @response 500 Internal server error
  app.get("/auth/profile", AuthMiddleware().handle(controller.profile));

  /// @summary Logout user
  /// @auth bearer
  /// @response 200 Logout successful
  /// @response 500 Logout failed
  app.post("/auth/logout", AuthMiddleware().handle(controller.logout));
}
