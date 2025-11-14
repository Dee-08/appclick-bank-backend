import 'package:flint_dart/flint_dart.dart';
import 'package:appclick_bank_backend/src/middlewares/auth_middleware.dart';
import '../controllers/wallet_controller.dart';

void registerWalletRoutes(Flint app) {
  final controller = WalletController();

  /// @summary Get wallet balance by account number
  /// @prefix /wallet
  /// @auth bearer
  /// @response 200 Balance retrieved successfully
  /// @response 404 Account not found
  app.get('/balance/:account_number',
      AuthMiddleware().handle(controller.getBalance));

  /// @summary Credit wallet by account number
  /// @auth bearer
  /// @prefix /wallet
  /// @body {"account_number": "string", "amount": 1000.0, "reference": "string", "description": "optional string"}
  /// @response 200 Wallet credited successfully
  /// @response 400 Invalid input or account not found
  app.post('/credit', AuthMiddleware().handle(controller.credit));

  /// @summary Debit wallet by account number
  /// @auth bearer
  /// @prefix /wallet
  /// @body {"account_number": "string", "amount": 1000.0, "reference": "string", "description": "optional string"}
  /// @response 200 Wallet debited successfully
  /// @response 400 Invalid input, insufficient funds, or account not found
  app.post('/debit', AuthMiddleware().handle(controller.debit));

  /// @summary Transfer between accounts
  /// @auth bearer
  /// @prefix /wallet
  /// @body {"from_account": "string", "to_account": "string", "amount": 1000.0, "description": "optional string"}
  /// @response 200 Transfer completed successfully
  /// @response 400 Invalid input, insufficient funds, or accounts not found
  app.post('/transfer', AuthMiddleware().handle(controller.transfer));

  /// @summary Get transaction history by account number
  /// @auth bearer
  /// @prefix /wallet
  /// @response 200 Transactions retrieved successfully
  /// @response 404 Account not found
  app.get('/transactions/:account_number',
      AuthMiddleware().handle(controller.getTransactions));
}
