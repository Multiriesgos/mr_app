import 'package:flutter/foundation.dart';

@immutable
class Product {
  const Product({
    required this.idRen,
    required this.ramo,
    required this.tipoSeguro,
    required this.aseguradora,
    required this.asegurado,
    required this.placa,
    this.fechaRenovacion,
    this.adjunto,
    this.suma,
    this.primaTotal,
    this.primaMes,
    this.marca,
    this.modelo,
    this.anioVehiculo,
  });

  final int idRen;
  final String ramo;
  final String tipoSeguro;
  final String aseguradora;
  final String asegurado;
  final String placa;
  final DateTime? fechaRenovacion;
  final String? adjunto;
  final double? suma;
  final double? primaTotal;
  final double? primaMes;
  final String? marca;
  final String? modelo;
  final String? anioVehiculo;

  @override
  bool operator ==(Object other) => other is Product && other.idRen == idRen;

  @override
  int get hashCode => idRen.hashCode;
}

@immutable
class ContactInfo {
  const ContactInfo({this.phone, this.whatsapp});

  final String? phone;
  final String? whatsapp;

  bool get hasPhone => phone != null && phone!.isNotEmpty;
  bool get hasWhatsApp =>
      whatsapp != null && whatsapp.toString().isNotEmpty;
}
