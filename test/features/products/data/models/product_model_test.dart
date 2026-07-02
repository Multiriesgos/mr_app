import 'package:flutter_test/flutter_test.dart';
import 'package:mr_app/features/products/data/models/product_model.dart';

void main() {
  group('ProductModel.fromJson', () {
    test('parsea todos los campos cuando vienen presentes', () {
      final model = ProductModel.fromJson({
        'id_ren': 42,
        'ramo': 'DAÑOS',
        'tipo_seguro': 'AUTOMOTORES',
        'aseguradora': 'ACSA',
        'asegurado': 'JUAN PÉREZ',
        'placa': 'P123456',
        'fecha_renovacion': '2026-07-16T00:00:00.000',
        'adjunto': 'POL-2024-001',
        'suma': 8000,
        'prima_neta': 350.5,
        'prima_total': 380,
        'prima_mes': 32.5,
        'descripcion_seguro': 'Cobertura amplia',
        'ejecutivo': 'María López',
        'forma_pago': 'TALONARIO',
        'periodo_pago': 'MENSUAL',
        'marca': 'TOYOTA',
        'modelo': 'COROLLA',
        'anio_vehiculo': 2022,
      });

      expect(model.idRen, 42);
      expect(model.ramo, 'DAÑOS');
      expect(model.tipoSeguro, 'AUTOMOTORES');
      expect(model.aseguradora, 'ACSA');
      expect(model.asegurado, 'JUAN PÉREZ');
      expect(model.placa, 'P123456');
      expect(model.fechaRenovacion, DateTime.parse('2026-07-16T00:00:00.000'));
      expect(model.adjunto, 'POL-2024-001');
      expect(model.suma, 8000.0);
      expect(model.primaNeta, 350.5);
      expect(model.primaTotal, 380.0);
      expect(model.primaMes, 32.5);
      expect(model.descripcionSeguro, 'Cobertura amplia');
      expect(model.ejecutivo, 'María López');
      expect(model.formaPago, 'TALONARIO');
      expect(model.periodoPago, 'MENSUAL');
      expect(model.marca, 'TOYOTA');
      expect(model.modelo, 'COROLLA');
      expect(model.anioVehiculo, '2022');
    });

    test('usa strings vacíos cuando faltan campos requeridos con fallback', () {
      final model = ProductModel.fromJson({'id_ren': 1});

      expect(model.idRen, 1);
      expect(model.ramo, '');
      expect(model.tipoSeguro, '');
      expect(model.aseguradora, '');
      expect(model.asegurado, '');
      expect(model.placa, '');
    });

    test('deja en null los campos opcionales ausentes', () {
      final model = ProductModel.fromJson({'id_ren': 1});

      expect(model.fechaRenovacion, isNull);
      expect(model.adjunto, isNull);
      expect(model.suma, isNull);
      expect(model.primaNeta, isNull);
      expect(model.primaTotal, isNull);
      expect(model.primaMes, isNull);
      expect(model.descripcionSeguro, isNull);
      expect(model.ejecutivo, isNull);
      expect(model.formaPago, isNull);
      expect(model.periodoPago, isNull);
      expect(model.marca, isNull);
      expect(model.modelo, isNull);
      expect(model.anioVehiculo, isNull);
    });

    test('fecha_renovacion inválida cae a null en vez de lanzar', () {
      final model = ProductModel.fromJson({
        'id_ren': 1,
        'fecha_renovacion': 'no-es-una-fecha',
      });

      expect(model.fechaRenovacion, isNull);
    });

    test('campos numéricos enteros se convierten a double', () {
      final model = ProductModel.fromJson({
        'id_ren': 1,
        'suma': 1000,
        'prima_neta': 50,
        'prima_total': 55,
      });

      expect(model.suma, isA<double>());
      expect(model.suma, 1000.0);
      expect(model.primaNeta, 50.0);
      expect(model.primaTotal, 55.0);
    });
  });

  group('ProductModel.toJson', () {
    test('serializa fecha_renovacion como ISO 8601 y respeta nulos', () {
      const model = ProductModel(
        idRen: 42,
        ramo: 'VIDA',
        tipoSeguro: 'Individual',
        aseguradora: 'SEGUROS SA',
        asegurado: 'MARÍA LÓPEZ',
        placa: '',
      );

      final json = model.toJson();

      expect(json['id_ren'], 42);
      expect(json['ramo'], 'VIDA');
      expect(json['fecha_renovacion'], isNull);
      expect(json['adjunto'], isNull);
      expect(json['suma'], isNull);
    });

    test('round-trip fromJson -> toJson -> fromJson preserva los datos', () {
      final original = ProductModel.fromJson({
        'id_ren': 7,
        'ramo': 'INCENDIO',
        'tipo_seguro': 'Comercial',
        'aseguradora': 'SISA',
        'asegurado': 'EMPRESA SA',
        'placa': '',
        'fecha_renovacion': '2027-02-21T00:00:00.000',
        'suma': 5000.0,
        'marca': 'NISSAN',
      });

      final roundTripped = ProductModel.fromJson(original.toJson());

      expect(roundTripped.idRen, original.idRen);
      expect(roundTripped.ramo, original.ramo);
      expect(roundTripped.fechaRenovacion, original.fechaRenovacion);
      expect(roundTripped.suma, original.suma);
      expect(roundTripped.marca, original.marca);
    });
  });

  group('ProductModel.toEntity', () {
    test('mapea todos los campos al entity Product', () {
      final model = ProductModel.fromJson({
        'id_ren': 42,
        'ramo': 'DAÑOS',
        'tipo_seguro': 'AUTOMOTORES',
        'aseguradora': 'ACSA',
        'asegurado': 'JUAN PÉREZ',
        'placa': 'P123456',
        'fecha_renovacion': '2026-07-16T00:00:00.000',
        'adjunto': 'POL-2024-001',
        'suma': 8000,
        'marca': 'TOYOTA',
        'modelo': 'COROLLA',
        'anio_vehiculo': 2022,
      });

      final entity = model.toEntity();

      expect(entity.idRen, model.idRen);
      expect(entity.ramo, model.ramo);
      expect(entity.tipoSeguro, model.tipoSeguro);
      expect(entity.aseguradora, model.aseguradora);
      expect(entity.asegurado, model.asegurado);
      expect(entity.placa, model.placa);
      expect(entity.fechaRenovacion, model.fechaRenovacion);
      expect(entity.adjunto, model.adjunto);
      expect(entity.suma, model.suma);
      expect(entity.marca, model.marca);
      expect(entity.modelo, model.modelo);
      expect(entity.anioVehiculo, model.anioVehiculo);
    });
  });

  group('ContactInfoModel.fromJson', () {
    test('mapea cabina a phone y whatsapp tal cual', () {
      final model = ContactInfoModel.fromJson({
        'cabina': '21234567',
        'whatsapp': '79876543',
      });

      expect(model.phone, '21234567');
      expect(model.whatsapp, '79876543');
    });

    test('convierte whatsapp numérico a String', () {
      final model = ContactInfoModel.fromJson({
        'cabina': '21234567',
        'whatsapp': 79876543,
      });

      expect(model.whatsapp, '79876543');
    });

    test('deja phone/whatsapp en null cuando no vienen en el json', () {
      final model = ContactInfoModel.fromJson(<String, dynamic>{});

      expect(model.phone, isNull);
      expect(model.whatsapp, isNull);
    });

    test('toEntity mapea phone/whatsapp sin transformación', () {
      final model = ContactInfoModel.fromJson({
        'cabina': '21234567',
        'whatsapp': '79876543',
      });

      final entity = model.toEntity();

      expect(entity.phone, '21234567');
      expect(entity.whatsapp, '79876543');
      expect(entity.hasPhone, isTrue);
      expect(entity.hasWhatsApp, isTrue);
    });
  });
}
