import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mr_app/models/storage_item.dart';

class StorageService {
  final _secureStorage = const FlutterSecureStorage(
      aOptions: AndroidOptions(
          keyCipherAlgorithm: KeyCipherAlgorithm.RSA_ECB_OAEPwithSHA_256andMGF1Padding,
          storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
          encryptedSharedPreferences: true
      ));

  Future<void> writeSecureData(StorageItem newItem) async {
    //debugPrint("Writing new data having key ${newItem.key}");
    await _secureStorage.write(key: newItem.key, value: newItem.value);
  }

  Future<String?> readSecureData(String key) async {
    //debugPrint("Reading data having key $key");
    var readData = await _secureStorage.read(key: key);
    //debugPrint("Read data $readData");
    return readData;
  }

  Future<void> deleteAllSecureData() async {
    //debugPrint("Deleting all secured data");
    await _secureStorage.deleteAll();
  }
}
