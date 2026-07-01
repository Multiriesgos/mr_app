import 'package:flutter_test/flutter_test.dart';
import 'package:mr_app/features/auth/data/models/user_model.dart';

void main() {
  group('UserModel.fromJson', () {
    test('parsea todos los campos cuando vienen presentes', () {
      final model = UserModel.fromJson({
        'userapp_user': '0801199012345',
        'userapp_nombre': 'JUAN PÉREZ',
        'userapp_correo': 'juan@example.com',
        'userapp_docsearch': '0801199012345',
      });

      expect(model.documentNumber, '0801199012345');
      expect(model.name, 'JUAN PÉREZ');
      expect(model.email, 'juan@example.com');
      expect(model.docSearch, '0801199012345');
    });

    test('email queda en null cuando no viene en el json', () {
      final model = UserModel.fromJson({
        'userapp_user': '0801199012345',
        'userapp_nombre': 'JUAN PÉREZ',
        'userapp_correo': null,
        'userapp_docsearch': '0801199012345',
      });

      expect(model.email, isNull);
    });
  });

  group('UserModel.toEntity', () {
    test('mapea todos los campos al entity User', () {
      final model = UserModel.fromJson({
        'userapp_user': '0801199012345',
        'userapp_nombre': 'JUAN PÉREZ',
        'userapp_correo': 'juan@example.com',
        'userapp_docsearch': '0801199012345',
      });

      final entity = model.toEntity();

      expect(entity.documentNumber, model.documentNumber);
      expect(entity.name, model.name);
      expect(entity.email, model.email);
      expect(entity.docSearch, model.docSearch);
    });
  });
}
