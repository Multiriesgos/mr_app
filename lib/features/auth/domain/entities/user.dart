import 'package:flutter/foundation.dart';

@immutable
class User {
  const User({
    required this.documentNumber,
    required this.name,
    required this.email,
    required this.docSearch,
  });

  final String documentNumber;
  final String name;
  final String? email;
  final String docSearch;

  @override
  bool operator ==(Object other) =>
      other is User && other.documentNumber == documentNumber;

  @override
  int get hashCode => documentNumber.hashCode;
}
