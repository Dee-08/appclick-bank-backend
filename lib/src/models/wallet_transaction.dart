import 'package:flint_dart/flint_dart.dart';

class WalletTransaction extends Model<WalletTransaction> {
  @override
  String? id;

  String? userId;
  String? walletId;
  double? amount;
  String? type; // credit/debit
  String? reference;
  String? status; // success, pending, failed
  String? description;

  @override
  Table get table => Table(
        name: 'wallet_transactions',
        columns: [
          Column(name: 'user_id', type: ColumnType.string),
          Column(name: 'wallet_id', type: ColumnType.string),
          Column(name: 'amount', type: ColumnType.double),
          Column(name: 'type', type: ColumnType.string),
          Column(name: 'reference', type: ColumnType.string, isUnique: true),
          Column(name: 'status', type: ColumnType.string),
          Column(
              name: 'description', type: ColumnType.string, isNullable: true),
        ],
      );

  @override
  Map<String, dynamic> toMap() => {
        'id': id,
        'user_id': userId,
        'wallet_id': walletId,
        'amount': amount,
        'type': type,
        'reference': reference,
        'status': status,
        'description': description,
      };

  @override
  WalletTransaction fromMap(Map<dynamic, dynamic> map) {
    return WalletTransaction()
      ..id = map['id']
      ..userId = map['user_id']
      ..walletId = map['wallet_id']
      ..amount = map['amount']
      ..type = map['type']
      ..reference = map['reference']
      ..status = map['status']
      ..description = map['description'];
  }
}
