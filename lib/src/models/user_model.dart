import 'package:flint_dart/model.dart';
import 'package:flint_dart/schema.dart';

class User extends Model<User> {
  @override
  String? id;

  // Personal Info
  String? name;
  String? email;
  String? password;
  int? phoneNumber;
  String? profilePicUrl;

  // Banking / Identity
  String? accountNumber; // wallet account number (10 digits)
  String? bvn; // Bank Verification Number
  String? nin; // National Identity Number

  // KYC
  String? kycStatus; // pending, verified, rejected
  String? address;
  String? dateOfBirth;
  String? gender;

  // Wallet Summary (cached for faster queries)
  double? walletBalance; // available balance
  double? ledgerBalance; // balance including holds

  DateTime? createdAt;

  @override
  Table get table => Table(
        name: 'users',
        columns: [
          Column(name: 'name', type: ColumnType.string),
          Column(name: 'email', type: ColumnType.string, isUnique: true),
          Column(name: 'password', type: ColumnType.string),
          Column(
              name: 'phone_number', type: ColumnType.string, isNullable: true),
          Column(
              name: 'profile_pic_url',
              type: ColumnType.string,
              isNullable: true),

          // Banking / Identity
          Column(
              name: 'account_number',
              type: ColumnType.string,
              isUnique: true,
              isNullable: true), // Will be generated
          Column(
              name: 'bvn',
              type: ColumnType.string,
              isUnique: true,
              isNullable: true),
          Column(
              name: 'pin',
              type: ColumnType.string,
              isUnique: true,
              isNullable: true),
          Column(
              name: 'nin',
              type: ColumnType.string,
              isUnique: true,
              isNullable: true),

          // KYC
          Column(name: 'kyc_status', type: ColumnType.string, isNullable: true),
          Column(name: 'address', type: ColumnType.string, isNullable: true),
          Column(
              name: 'date_of_birth', type: ColumnType.string, isNullable: true),
          Column(name: 'gender', type: ColumnType.string, isNullable: true),

          // Wallet
          Column(
              name: 'wallet_balance',
              type: ColumnType.double,
              isNullable: true),
          Column(
              name: 'ledger_balance',
              type: ColumnType.double,
              isNullable: true),
        ],
      );

  @override
  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'email': email,
        'password': password,
        'phone_number': phoneNumber,
        'profile_pic_url': profilePicUrl,

        // Banking
        'account_number': accountNumber,
        'bvn': bvn,
        'nin': nin,

        // KYC
        'kyc_status': kycStatus,
        'address': address,
        'date_of_birth': dateOfBirth,
        'gender': gender,

        // Wallet
        'wallet_balance': walletBalance,
        'ledger_balance': ledgerBalance,

        'created_at': createdAt,
      };

  @override
  User fromMap(Map<dynamic, dynamic> map) {
    return User()
      ..id = map['id']
      ..name = map['name']
      ..email = map['email']
      ..password = map['password']
      ..phoneNumber = map['phone_number']
      ..profilePicUrl = map['profile_pic_url']
      ..accountNumber = map['account_number']
      ..bvn = map['bvn']
      ..nin = map['nin']
      ..kycStatus = map['kyc_status']
      ..address = map['address']
      ..dateOfBirth = map['date_of_birth']
      ..gender = map['gender']
      ..walletBalance = map['wallet_balance']?.toDouble()
      ..ledgerBalance = map['ledger_balance']?.toDouble();
  }

  /// Generate a unique 10-digit account number
  static String generateAccountNumber() {
    final random = DateTime.now().millisecondsSinceEpoch;
    final baseNumber = (random % 9000000000 + 1000000000).toString();
    return baseNumber.substring(0, 10);
  }

  /// Find user by account number
  static Future<User?> findByAccountNumber(String accountNumber) async {
    final result = await User().where('account_number', accountNumber).first();
    return result;
  }
}
