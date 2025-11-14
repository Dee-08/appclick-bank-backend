import 'package:flint_dart/flint_dart.dart';

class Wallet extends Model<Wallet> {
  @override
  String? id;

  String? userId;
  double? balance;
  double? ledgerBalance;
  String? currency;

  @override
  Table get table => Table(
        name: 'wallets',
        columns: [
          Column(name: 'user_id', type: ColumnType.string),
          Column(name: 'balance', type: ColumnType.double),
          Column(name: 'ledger_balance', type: ColumnType.double),
          Column(name: 'currency', type: ColumnType.string),
        ],
      );

  @override
  Map<String, dynamic> toMap() => {
        'id': id,
        'user_id': userId,
        'balance': balance,
        'ledger_balance': ledgerBalance,
        'currency': currency,
      };

  @override
  Wallet fromMap(Map<dynamic, dynamic> map) {
    return Wallet()
      ..id = map['id']
      ..userId = map['user_id']
      ..balance = map['balance']
      ..ledgerBalance = map['ledger_balance']
      ..currency = map['currency'];
  }
}
