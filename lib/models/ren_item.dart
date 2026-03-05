// To parse this JSON data, do
//
//     final renItem = renItemFromMap(jsonString);

import 'dart:convert';

import 'package:mr_app/services/webservice.dart';
import 'package:mr_app/utils/constants.dart';

class RenItem {
  RenItem({
    this.idRen,
    this.fechaRenovacion,
    this.ramo,
    this.tipoSeguro,
    this.suma,
    this.primaNeta,
    this.primaTotal,
    this.periodoPago,
    this.aseguradora,
    this.ejecutivo,
    this.formaPago,
    this.descripcionSeguro,
    this.fechaRegistro,
    this.status,
    this.usuarioIngreso,
    this.observacionVta,
    this.fechaUltRen,
    this.usuarioRen,
    this.dui,
    this.asegurado,
    this.adjunto,
    this.telefono,
    this.correo,
    this.idVenta,
    this.placa,
  });

  int? idRen;
  DateTime? fechaRenovacion;
  String? ramo;
  String? tipoSeguro;
  double? suma;
  double? primaNeta;
  double? primaTotal;
  String? periodoPago;
  String? aseguradora;
  String? ejecutivo;
  String? formaPago;
  String? descripcionSeguro;
  DateTime? fechaRegistro;
  int? status;
  String? usuarioIngreso;
  dynamic observacionVta;
  dynamic fechaUltRen;
  dynamic usuarioRen;
  String? dui;
  String? asegurado;
  dynamic adjunto;
  String? telefono;
  String? correo;
  int? idVenta;
  String? placa;

  factory RenItem.fromJson(Map<String, dynamic> json) => RenItem.fromMap(json);

  String toJson() => json.encode(toMap());

  factory RenItem.fromMap(Map<String, dynamic> json) => RenItem(
        idRen: json["id_ren"],
        fechaRenovacion: DateTime.tryParse(json["fecha_renovacion"]),
        ramo: json["ramo"],
        tipoSeguro: json["tipo_seguro"],
        suma: json["suma"]?.toDouble(),
        primaNeta:
            json["prima_neta"]?.toDouble(),
        primaTotal:
            json["prima_total"]?.toDouble(),
        periodoPago: json["periodo_pago"],
        aseguradora: json["aseguradora"],
        ejecutivo: json["ejecutivo"],
        formaPago: json["forma_pago"],
        descripcionSeguro: json["descripcion_seguro"],
        fechaRegistro: json["fecha_registro"] == null
            ? null
            : DateTime.tryParse(json["fecha_registro"]),
        status: json["status"],
        usuarioIngreso: json["usuario_ingreso"],
        observacionVta: json["observacion_vta"],
        fechaUltRen: json["fecha_ult_ren"],
        usuarioRen: json["usuario_ren"],
        dui: json["dui"],
        asegurado: json["asegurado"],
        adjunto: json["adjunto"],
        telefono: json["telefono"],
        correo: json["correo"],
        idVenta: json["id_venta"],
        placa: json["placa"] ?? '',
      );

  Map<String, dynamic> toMap() => {
        "id_ren": idRen,
        "fecha_renovacion": fechaRenovacion?.toIso8601String(),
        "ramo": ramo,
        "tipo_seguro": tipoSeguro,
        "suma": suma,
        "prima_neta": primaNeta,
        "prima_total": primaTotal,
        "periodo_pago": periodoPago,
        "aseguradora": aseguradora,
        "ejecutivo": ejecutivo,
        "forma_pago": formaPago,
        "descripcion_seguro": descripcionSeguro,
        "fecha_registro": fechaRegistro?.toIso8601String(),
        "status": status,
        "usuario_ingreso": usuarioIngreso,
        "observacion_vta": observacionVta,
        "fecha_ult_ren": fechaUltRen,
        "usuario_ren": usuarioRen,
        "dui": dui,
        "asegurado": asegurado,
        "adjunto": adjunto,
        "telefono": telefono,
        "correo": correo,
        "id_venta": idVenta,
        "placa": placa,
      };

  static Resource<List<RenItem>> get all {
    return Resource(
        url: Constants.headlineNewsUrl,
        parse: (response) {
          final result = json.decode(response.body);
          Iterable list = result;
          return list.map((model) => RenItem.fromJson(model)).toList();
        });
  }

  static ResourceFind<RenItem> one(int idRen) {
    return ResourceFind(
        url: '${Constants.headlineNewsUrl}/$idRen',
        idRen: idRen,
        parse: (response) {
          final result = json.decode(response.body);
          return RenItem.fromJson(result);
        });
  }
}
