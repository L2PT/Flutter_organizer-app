import 'package:dio/dio.dart';
import 'package:venturiautospurghi/utils/global_constants.dart';

Future<List<String>> getLocationAddresses(String text) async {
  if (text.isNotEmpty) {
    String baseURL = 'https://maps.googleapis.com/maps/api/place/autocomplete/json';
    String language = 'it';
    String type = 'address';
    String key = Constants.googleMapsApiKey;
    String request = '$baseURL?input=$text&key=$key&type=$type&language=$language';

    Response response = await Dio().get(request);

    final predictions = response.data['predictions'];

    List<String> _results = [];
    for (var i = 0; i < 3; i++) {
      String name = predictions[i]['description'];
      _results.add(name);
    }
    return _results;
  } else return List<String>.empty();
}