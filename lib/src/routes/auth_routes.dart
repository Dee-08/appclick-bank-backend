import 'package:flint_dart/flint_dart.dart';
import 'package:appclick_bank_backend/src/controllers/auth_controller.dart';

void authRoutes(Flint app) {
  final authController = AuthController();

  ///@summary Create a New User
  ///@prefix /auth
  ///@body {"name": "string", "email": "string", "password": "string"}
  ///@response 200 User Registered Successfully
  ///@response 500 Server Error
  app.post("/register", authController.register);

  ///@summary Create a new token for registered user
  ///@prefix /auth
  ///@body {"name": "string", "email": "string", "password": "string"}
  ///@response 200 User logged in Successfully
  ///@response 500 Server Error
  app.post("/login", authController.login);

  app.post("/login-with-google", authController.login);
}
