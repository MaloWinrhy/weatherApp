import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:weather_app/models/weather_model.dart';

class WeatherService {
  static const String geocodingUrl = 'https://geocoding-api.open-meteo.com/v1/search';
  static const String weatherUrl = 'https://api.open-meteo.com/v1/forecast';

  Future<Weather> getWeather(String cityName) async {
    final coordinates = await _getCoordinates(cityName);
    final lat = coordinates['latitude'];
    final lon = coordinates['longitude'];

    final response = await http.get(Uri.parse(
      '$weatherUrl?latitude=$lat&longitude=$lon&current=weather_code&hourly=temperature_2m,weather_code&timezone=auto',
    ));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      int weatherCode = _getCurrentHourlyWeatherCode(data);
      double currentTemperature = _getCurrentHourlyTemperature(data);

      return Weather(
        cityName: coordinates['name'],
        temperature: currentTemperature,
        weatherCode: weatherCode,
      );
    } else {
      throw Exception('noWeatherFound');
    }
  }

  Future<Map<String, dynamic>> _getCoordinates(String cityName) async {
    final response = await http.get(Uri.parse('$geocodingUrl?name=$cityName'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['results'] != null && data['results'].isNotEmpty) {
        return {
          'latitude': data['results'][0]['latitude'],
          'longitude': data['results'][0]['longitude'],
          'name': data['results'][0]['name'],
        };
      } else {
        throw Exception('noCityFound');
      }
    } else {
      throw Exception('noCityFound');
    }
  }

  int _getCurrentHourlyWeatherCode(Map<String, dynamic> data) {
    List<dynamic> times = data['hourly']['time'];
    List<dynamic> weatherCodes = data['hourly']['weather_code'];

    // Obtenir l'heure actuelle formatée en UTC (car Open-Meteo fonctionne en UTC)
    String currentTime = DateFormat("yyyy-MM-ddTHH:00").format(DateTime.now().toUtc());

    // Trouver l'index de l'heure actuelle dans les données horaires
    int index = times.indexOf(currentTime);
    if (index != -1) {
      return weatherCodes[index];
    } else {
      return weatherCodes.last;
    }
  }

  double _getCurrentHourlyTemperature(Map<String, dynamic> data) {
    List<dynamic> times = data['hourly']['time'];
    List<dynamic> temperatures = data['hourly']['temperature_2m'];

    String currentTime = DateFormat("yyyy-MM-ddTHH:00").format(DateTime.now().toUtc());

    int index = times.indexOf(currentTime);
    if (index != -1) {
      return temperatures[index].toDouble();
    } else {
      return temperatures.last.toDouble();
    }
  }
}