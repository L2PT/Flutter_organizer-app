import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:venturiautospurghi/utils/global_constants.dart';

Future<List<String>> getLocationAddresses(String text) async {
  var predictions;
  if (text.isNotEmpty) {
    String baseURL = 'https://maps.googleapis.com/maps/api/place/autocomplete/json';
    String language = 'it';
    String type = 'address';
    String key = Constants.googleMapsApiKey;
    String url = '$baseURL?input=$text&key=$key&type=$type&language=$language';
    try {
      var response = await http.get(url,headers: {"Access-Control-Allow-Origin": "*"});
      if (response.statusCode == 200) {
        var jsonResponse = convert.jsonDecode(response.body);
        predictions = jsonResponse['data']['predictions'];

        List<String> _results = [];
        for (var i = 0; i < 3; i++) {
          String name = predictions[i]['description'];
          _results.add(name);
        }
        return _results;
      }
    } catch (e) {
      print(e);
    }
    return ["ciao","come","stai"];
  }
}