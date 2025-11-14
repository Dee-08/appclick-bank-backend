import 'dart:isolate';

import 'package:appclick_bank_backend/src/models/wallet.dart';
import 'package:appclick_bank_backend/src/models/wallet_transaction.dart';
import 'package:flint_dart/schema.dart';
import 'package:appclick_bank_backend/src/models/user_model.dart';

void main(_, SendPort? sendPort) {
  runTableRegistry([
    User().table,
    Wallet().table,
    WalletTransaction().table,
  ], _, sendPort);
}
