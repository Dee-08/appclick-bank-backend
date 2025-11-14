import 'package:appclick_bank_backend/src/routes/wallet_routes.dart';
import 'package:flint_dart/flint_dart.dart';
import 'package:appclick_bank_backend/src/middlewares/auth_middleware.dart';
import 'package:appclick_bank_backend/src/routes/auth_routes.dart';
import 'package:appclick_bank_backend/src/routes/user_routes.dart';

void main() {
  final app = Flint(withDefaultMiddleware: true, enableSwaggerDocs: true);

  app.get("/", (req, res) => res.send("Server runing"));
  app.mount("/users", registerUserRoutes, middlewares: [
    AuthMiddleware(),
  ]);

  app.mount("/auth", registerAuthRoutes);
  app.mount("/wallet", registerWalletRoutes);
  app.listen(3001);
}
