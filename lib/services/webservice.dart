import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:mr_app/services/storage_service.dart';
import 'package:mr_app/utils/constants.dart';

class Resource<T> {
  final String url;
  T Function(Response response) parse;

  Resource({required this.url, required this.parse});
}

class ResourceFind<T> {
  final String? url;
  T Function(Response response)? parse;
  final int? idRen;

  ResourceFind({this.url, this.parse, this.idRen});
}

class ResourceFindCab<T> {
  final String? url;
  T Function(Response response)? parse;
  final String? aseg;
  final String? ramo;
  final String? tipaseg;

  ResourceFindCab({this.url, this.parse, this.aseg, this.ramo, this.tipaseg});
}

class Webservice {
  Future<T> load<T>(Resource<T> resource) async {
    String uname = "", searchdoc = "";
    final storageService = StorageService();
    uname = await storageService.readSecureData('KEY_USERNAME') ?? '';
    searchdoc = await storageService.readSecureData('KEY_SEARCH') ?? '';
    uname = uname.toUpperCase();

    final queryParameter = {'nodoc': searchdoc};

    final uri =
        Uri.parse(resource.url).replace(queryParameters: queryParameter);
    //Uri.parse(resource.url)

    final response = await http.get(uri, headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'MRApiKey': Constants.kMrApiKey
    });
    if (response.statusCode == 200) {
      return resource.parse(response);
    } else {
      throw Exception('Failed to load data!');
    }
  }

  Future<T> find<T>(ResourceFind<T> resource) async {
    final queryParameter = resource.url;

    final uri = Uri.parse(queryParameter!);
    //Uri.parse(resource.url)

    final response = await http.post(uri, headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'MRApiKey': Constants.kMrApiKey
    });
    if (response.statusCode == 200) {
      return resource.parse!(response);
    } else {
      throw Exception('Failed to load data!');
    }
  }

  Future<T> loadCab<T>(ResourceFindCab<T> resource) async {
    final queryParameter = {
      'aseg': resource.aseg,
      'ramo': resource.ramo,
      'tipaseg': resource.tipaseg
    };

    final uri =
        Uri.parse(resource.url!).replace(queryParameters: queryParameter);
    //Uri.parse(resource.url)

    final response = await http.post(uri, headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'MRApiKey': Constants.kMrApiKey
    });
    if (response.statusCode == 200) {
      return resource.parse!(response);
    } else {
      throw Exception('Failed to load data!');
    }
  }
}
