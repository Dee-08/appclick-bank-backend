import 'package:flint_dart/flint_dart.dart';
import 'package:appclick_bank_backend/src/services/wallet_service.dart';

class WalletController {
  /// GET /wallet/balance/:account_number
  Future<Response> getBalance(Request req, Response res) async {
    final accountNumber = req.params['account_number'];
    if (accountNumber == null) {
      return res
          .status(400)
          .json({"status": "error", "message": "Account number is required"});
    }

    try {
      final balance = await WalletService.getBalanceByAccount(accountNumber);

      return res.json({
        "status": "success",
        "message": "Balance retrieved successfully",
        "data": {
          "account_number": accountNumber,
          "balance": balance,
          "currency": "NGN"
        }
      });
    } catch (e) {
      return res.status(404).json({
        "status": "error",
        "message": e.toString(),
      });
    }
  }

  /// POST /wallet/credit
  Future<Response> credit(Request req, Response res) async {
    try {
      final body = await req.json();

      final tr = await WalletService.creditByAccount(
        accountNumber: body['account_number'],
        amount: double.parse(body['amount'].toString()),
        reference: body['reference'],
        description: body['description'],
      );

      return res.json({
        "status": "success",
        "message": "Wallet credited successfully",
        "data": {
          "transaction": tr.toMap(),
        }
      });
    } catch (e) {
      return res.status(400).json({
        "status": "error",
        "message": e.toString(),
      });
    }
  }

  /// POST /wallet/debit
  Future<Response> debit(Request req, Response res) async {
    try {
      final body = await req.json();

      final tr = await WalletService.debitByAccount(
        accountNumber: body['account_number'],
        amount: double.parse(body['amount'].toString()),
        reference: body['reference'],
        description: body['description'],
      );

      return res.json({
        "status": "success",
        "message": "Wallet debited successfully",
        "data": {
          "transaction": tr.toMap(),
        }
      });
    } catch (e) {
      return res.status(400).json({
        "status": "error",
        "message": e.toString(),
      });
    }
  }

  /// POST /wallet/transfer
  Future<Response> transfer(Request req, Response res) async {
    try {
      final body = await req.json();

      final transactions = await WalletService.transferByAccount(
        fromAccountNumber: body['from_account'],
        toAccountNumber: body['to_account'],
        amount: double.parse(body['amount'].toString()),
        description: body['description'],
      );

      return res.json({
        "status": "success",
        "message": "Transfer completed successfully",
        "data": {
          "from_account": body['from_account'],
          "to_account": body['to_account'],
          "amount": body['amount'],
          "out_transaction": transactions['out']?.toMap(),
          "in_transaction": transactions['in']?.toMap(),
        }
      });
    } catch (e) {
      return res.status(400).json({
        "status": "error",
        "message": e.toString(),
      });
    }
  }

  /// GET /wallet/transactions/:account_number
  Future<Response> getTransactions(Request req, Response res) async {
    final accountNumber = req.params['account_number'];
    if (accountNumber == null) {
      return res
          .status(400)
          .json({"status": "error", "message": "Account number is required"});
    }

    try {
      final transactions =
          await WalletService.getTransactionsByAccount(accountNumber);

      return res.json({
        "status": "success",
        "message": "Transactions retrieved successfully",
        "data": {
          "account_number": accountNumber,
          "transactions": transactions.map((t) => t.toMap()).toList(),
          "count": transactions.length
        }
      });
    } catch (e) {
      return res.status(404).json({
        "status": "error",
        "message": e.toString(),
      });
    }
  }
}
