import 'package:mr_app/features/auth/domain/entities/user.dart';

class UserModel {
  const UserModel({
    required this.documentNumber,
    required this.name,
    required this.email,
    required this.docSearch,
  });

  final String documentNumber;
  final String name;
  final String? email;
  final String docSearch;

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        documentNumber: json['userapp_user'] as String,
        name: json['userapp_nombre'] as String,
        email: json['userapp_correo'] as String?,
        docSearch: json['userapp_docsearch'] as String,
      );

  User toEntity() => User(
        documentNumber: documentNumber,
        name: name,
        email: email,
        docSearch: docSearch,
      );
}
