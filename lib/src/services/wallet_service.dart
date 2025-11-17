import 'package:appclick_bank_backend/src/models/user_model.dart';
import 'package:appclick_bank_backend/src/models/wallet.dart';
import 'package:appclick_bank_backend/src/models/wallet_transaction.dart';

class WalletService {
  /// Get or create wallet for user by account number
  static Future<Wallet> getOrCreateWalletForUserByAccount(
      String accountNumber) async {
    final user = await User.findByAccountNumber(accountNumber);
    if (user == null)
      throw Exception('User with account $accountNumber not found');

    final wallet = await Wallet().where('user_id', user.id!).first();

    if (wallet != null) return wallet;

    final w = Wallet()
      ..userId = user.id
      ..balance = 0.0
      ..ledgerBalance = 0.0
      ..currency = 'NGN';

    await w.save();
    return w;
  }

  /// Get wallet by account number
  static Future<Wallet?> getWalletByAccountNumber(String accountNumber) async {
    final user = await User.findByAccountNumber(accountNumber);
    if (user == null) return null;

    final wallet = await Wallet().where('user_id', user.id!).first();
    return wallet;
  }

  /// CREDIT wallet by account number
  static Future<WalletTransaction> creditByAccount({
    required String accountNumber,
    required double amount,
    required String reference,
    String? description,
  }) async {
    if (amount <= 0) throw Exception('Amount must be positive');

    final user = await User.findByAccountNumber(accountNumber);
    if (user == null) throw Exception('Account $accountNumber not found');

    var wallet = await Wallet().where('user_id', user.id!).first();

    if (wallet == null) {
      wallet = Wallet()
        ..userId = user.id
        ..balance = amount
        ..ledgerBalance = amount
        ..currency = 'NGN';
      await wallet.save();
    } else {
      wallet.balance = (wallet.balance ?? 0) + amount;
      wallet.ledgerBalance = (wallet.ledgerBalance ?? 0) + amount;
      await wallet.save();
    }

    // Update user's cached balance
    await User().update(user.id!, {
      'wallet_balance': wallet.balance,
      'ledger_balance': wallet.ledgerBalance,
    });

    final tr = WalletTransaction()
      ..userId = user.id
      ..walletId = wallet.id
      ..amount = amount
      ..type = 'credit'
      ..reference = reference
      ..status = 'success'
      ..description = description ?? 'Credit to account $accountNumber';

    await tr.save();
    return tr;
  }

  /// DEBIT wallet by account number
  static Future<WalletTransaction> debitByAccount({
    required String accountNumber,
    required double amount,
    required String reference,
    String? description,
  }) async {
    if (amount <= 0) throw Exception('Amount must be positive');

    final user = await User.findByAccountNumber(accountNumber);
    if (user == null) throw Exception('Account $accountNumber not found');

    final wallet = await Wallet().where('user_id', user.id!).first();

    if (wallet == null)
      throw Exception('Wallet not found for account $accountNumber');

    if ((wallet.balance ?? 0) < amount) throw Exception('Insufficient funds');

    wallet.balance = (wallet.balance ?? 0) - amount;
    wallet.ledgerBalance = (wallet.ledgerBalance ?? 0) - amount;
    await wallet.save();

    // Update user's cached balance
    await User().update(user.id!, {
      'wallet_balance': wallet.balance,
      'ledger_balance': wallet.ledgerBalance,
    });

    final tr = WalletTransaction()
      ..userId = user.id
      ..walletId = wallet.id
      ..amount = amount
      ..type = 'debit'
      ..reference = reference
      ..status = 'success'
      ..description = description ?? 'Debit from account $accountNumber';

    await tr.save();
    return tr;
  }

  /// TRANSFER between accounts using account numbers
  static Future<Map<String, WalletTransaction>> transferByAccount({
    required String fromAccountNumber,
    required String toAccountNumber,
    required double amount,
    String? description,
  }) async {
    if (fromAccountNumber == toAccountNumber)
      throw Exception('Cannot transfer to same account');
    if (amount <= 0) throw Exception('Amount must be positive');

    // Find both users
    final fromUser = await User.findByAccountNumber(fromAccountNumber);
    if (fromUser == null)
      throw Exception('Sender account $fromAccountNumber not found');

    final toUser = await User.findByAccountNumber(toAccountNumber);
    if (toUser == null)
      throw Exception('Receiver account $toAccountNumber not found');

    // Get or create wallets
    final fromWallet = await Wallet().where('user_id', fromUser.id!).first();

    if (fromWallet == null) throw Exception('Sender wallet not found');

    final toWallet = await Wallet().where('user_id', toUser.id!).first() ??
        await getOrCreateWalletForUserByAccount(toAccountNumber);

    // Check sufficient funds
    if ((fromWallet.balance ?? 0) < amount)
      throw Exception('Insufficient funds in account $fromAccountNumber');

    // Generate transaction references
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final referenceOut = 'TRF_OUT_$timestamp';
    final referenceIn = 'TRF_IN_$timestamp';

    // Apply transfer
    fromWallet.balance = (fromWallet.balance ?? 0) - amount;
    fromWallet.ledgerBalance = (fromWallet.ledgerBalance ?? 0) - amount;

    toWallet.balance = (toWallet.balance ?? 0) + amount;
    toWallet.ledgerBalance = (toWallet.ledgerBalance ?? 0) + amount;

    await fromWallet.save();
    await toWallet.save();

    // Update cached balances in users table
    await User().update(fromUser.id!, {
      'wallet_balance': fromWallet.balance,
      'ledger_balance': fromWallet.ledgerBalance,
    });

    await User().update(toUser.id!, {
      'wallet_balance': toWallet.balance,
      'ledger_balance': toWallet.ledgerBalance,
    });

    final transferDescription = description ?? 'Transfer to $toAccountNumber';

    final outTr = WalletTransaction()
      ..userId = fromUser.id
      ..walletId = fromWallet.id
      ..amount = amount
      ..type = 'debit'
      ..reference = referenceOut
      ..status = 'success'
      ..description = transferDescription;

    await outTr.save();

    final inTr = WalletTransaction()
      ..userId = toUser.id
      ..walletId = toWallet.id
      ..amount = amount
      ..type = 'credit'
      ..reference = referenceIn
      ..status = 'success'
      ..description = 'Transfer from $fromAccountNumber';

    await inTr.save();

    return {'out': outTr, 'in': inTr};
  }

  /// Get wallet balance by account number
  static Future<double> getBalanceByAccount(String accountNumber) async {
    final user = await User.findByAccountNumber(accountNumber);
    if (user == null) throw Exception('Account $accountNumber not found');

    final wallets = await Wallet().where('user_id', user.id!).get();
    final wallet = wallets.isNotEmpty ? wallets.first : null;

    return wallet?.balance ?? 0.0;
  }

  /// Get transaction history by account number
  static Future<List<WalletTransaction>> getTransactionsByAccount(
      String accountNumber) async {
    final user = await User.findByAccountNumber(accountNumber);
    if (user == null) throw Exception('Account $accountNumber not found');

    return await WalletTransaction().where('user_id', user.id!).get();
  }
}
