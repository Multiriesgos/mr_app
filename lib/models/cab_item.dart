import 'dart:convert';

import 'package:mr_app/services/webservice.dart';
import 'package:mr_app/utils/constants.dart';

class CabItem {
  CabItem({
    this.aseguradora,
    this.ramo,
    this.tipoSeguro,
    this.cabina,
    this.whatsapp,
    this.idCabina,
  });

  String? aseguradora;
  String? ramo;
  String? tipoSeguro;
  String? cabina;
  dynamic whatsapp;
  int? idCabina;

  factory CabItem.fromJson(String str) => CabItem.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory CabItem.fromMap(Map<String, dynamic> json) => CabItem(
        aseguradora: json["aseguradora"],
        ramo: json["ramo"],
        tipoSeguro: json["tipo_seguro"],
        cabina: json["cabina"],
        whatsapp: json["whatsapp"],
        idCabina: json["id_cabina"],
      );

  Map<String, dynamic> toMap() => {
        "aseguradora": aseguradora,
        "ramo": ramo,
        "tipo_seguro": tipoSeguro,
        "cabina": cabina,
        "whatsapp": whatsapp,
        "id_cabina": idCabina,
      };

  static ResourceFindCab<CabItem> one(
      String? aseg, String? ramo, String? tipaseg) {
    return ResourceFindCab(
        url: Constants.headlineCabUrl,
        aseg: aseg,
        ramo: ramo,
        tipaseg: tipaseg,
        parse: (response) {
          final result = json.decode(response.body);
          return CabItem.fromMap(result[0]);
        });
  }
}
