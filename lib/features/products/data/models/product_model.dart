import 'package:mr_app/features/products/domain/entities/product.dart';

class ProductModel {
  const ProductModel({
    required this.idRen,
    required this.ramo,
    required this.tipoSeguro,
    required this.aseguradora,
    required this.asegurado,
    required this.placa,
    this.fechaRenovacion,
    this.adjunto,
    this.suma,
    this.primaNeta,
    this.primaTotal,
    this.primaMes,
    this.descripcionSeguro,
    this.ejecutivo,
    this.formaPago,
    this.periodoPago,
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
  final double? primaNeta;
  final double? primaTotal;
  final double? primaMes;
  final String? descripcionSeguro;
  final String? ejecutivo;
  final String? formaPago;
  final String? periodoPago;
  final String? marca;
  final String? modelo;
  final String? anioVehiculo;

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
        idRen: json['id_ren'] as int,
        ramo: (json['ramo'] as String?) ?? '',
        tipoSeguro: (json['tipo_seguro'] as String?) ?? '',
        aseguradora: (json['aseguradora'] as String?) ?? '',
        asegurado: (json['asegurado'] as String?) ?? '',
        placa: (json['placa'] as String?) ?? '',
        fechaRenovacion: json['fecha_renovacion'] == null
            ? null
            : DateTime.tryParse(json['fecha_renovacion'] as String),
        adjunto: json['adjunto'] as String?,
        suma: (json['suma'] as num?)?.toDouble(),
        primaNeta: (json['prima_neta'] as num?)?.toDouble(),
        primaTotal: (json['prima_total'] as num?)?.toDouble(),
        primaMes: (json['prima_mes'] as num?)?.toDouble(),
        descripcionSeguro: json['descripcion_seguro'] as String?,
        ejecutivo: json['ejecutivo'] as String?,
        formaPago: json['forma_pago'] as String?,
        periodoPago: json['periodo_pago'] as String?,
        marca: json['marca'] as String?,
        modelo: json['modelo'] as String?,
        anioVehiculo: json['anio_vehiculo']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'id_ren': idRen,
        'ramo': ramo,
        'tipo_seguro': tipoSeguro,
        'aseguradora': aseguradora,
        'asegurado': asegurado,
        'placa': placa,
        'fecha_renovacion': fechaRenovacion?.toIso8601String(),
        'adjunto': adjunto,
        'suma': suma,
        'prima_neta': primaNeta,
        'prima_total': primaTotal,
        'prima_mes': primaMes,
        'descripcion_seguro': descripcionSeguro,
        'ejecutivo': ejecutivo,
        'forma_pago': formaPago,
        'periodo_pago': periodoPago,
        'marca': marca,
        'modelo': modelo,
        'anio_vehiculo': anioVehiculo,
      };

  Product toEntity() => Product(
        idRen: idRen,
        ramo: ramo,
        tipoSeguro: tipoSeguro,
        aseguradora: aseguradora,
        asegurado: asegurado,
        placa: placa,
        fechaRenovacion: fechaRenovacion,
        adjunto: adjunto,
        suma: suma,
        primaNeta: primaNeta,
        primaTotal: primaTotal,
        primaMes: primaMes,
        descripcionSeguro: descripcionSeguro,
        ejecutivo: ejecutivo,
        formaPago: formaPago,
        periodoPago: periodoPago,
        marca: marca,
        modelo: modelo,
        anioVehiculo: anioVehiculo,
      );
}

class ContactInfoModel {
  const ContactInfoModel({this.phone, this.whatsapp});

  final String? phone;
  final String? whatsapp;

  factory ContactInfoModel.fromJson(Map<String, dynamic> json) =>
      ContactInfoModel(
        phone: json['cabina'] as String?,
        whatsapp: json['whatsapp']?.toString(),
      );

  ContactInfo toEntity() =>
      ContactInfo(phone: phone, whatsapp: whatsapp);
}
