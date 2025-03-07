import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather_app/models/weather_model.dart';

/// Service permettant de récupérer les informations météorologiques
class WeatherService {
  // URLs des API utilisées
  static const String _weatherUrl = 'https://api.open-meteo.com/v1/forecast';
  static const String _geocodingUrl = 'https://nominatim.openstreetmap.org/reverse?format=json';

  /// Méthode principale pour obtenir la météo à la position actuelle
  Future<Weather> getWeatherFromCurrentLocation() async {
    // 1. Obtenir la position GPS
    Position position = await _determinePosition();
    
    // 2. Obtenir le nom de la ville à partir des coordonnées
    String cityName = await _getCityNameFromCoordinates(
      position.latitude, 
      position.longitude
    );
    
    // 3. Obtenir les données météo
    return _getWeatherFromCoordinates(
      position.latitude, 
      position.longitude, 
      cityName
    );
  }

  /// Récupère les données météo à partir des coordonnées GPS
  Future<Weather> _getWeatherFromCoordinates(
    double latitude, 
    double longitude, 
    String locationName
  ) async {
    // Création de l'URL avec les paramètres
    final url = '$_weatherUrl?latitude=$latitude&longitude=$longitude&current=weather_code&hourly=temperature_2m,weather_code&timezone=auto';
    
    // Appel à l'API météo
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      
      return Weather(
        cityName: locationName,
        temperature: _getCurrentHourlyTemperature(data),
        weatherCode: _getCurrentHourlyWeatherCode(data),
      );
    } else {
      throw Exception('Impossible de récupérer les données météo');
    }
  }

  /// Vérifie et demande les permissions de localisation
  Future<Position> _determinePosition() async {
    // Vérification si le GPS est activé
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw Exception('Le service de localisation est désactivé');
    }

    // Vérification des permissions
    LocationPermission permission = await Geolocator.checkPermission();
    
    // Si pas de permission, on la demande
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Permission de localisation refusée');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Les permissions de localisation sont définitivement refusées');
    }

    // Récupération de la position
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high
    );
  }

  /// Convertit les coordonnées GPS en nom de ville
  Future<String> _getCityNameFromCoordinates(double lat, double lon) async {
    final response = await http.get(Uri.parse('$_geocodingUrl&lat=$lat&lon=$lon'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data.containsKey('address')) {
        return data['address']['city'] ??
               data['address']['town'] ??
               data['address']['village'] ??
               data['address']['county'] ??
               'Lieu inconnu';
      }
    }
    throw Exception('Impossible de récupérer le nom de la ville');
  }

  /// Helpers pour extraire les données météo
  int _getCurrentHourlyWeatherCode(Map<String, dynamic> data) {
    final times = data['hourly']['time'];
    final weatherCodes = data['hourly']['weather_code'];
    final currentTime = _getCurrentUtcTime();

    final index = times.indexOf(currentTime);
    return index != -1 ? weatherCodes[index] : weatherCodes.last;
  }

  double _getCurrentHourlyTemperature(Map<String, dynamic> data) {
    final times = data['hourly']['time'];
    final temperatures = data['hourly']['temperature_2m'];
    final currentTime = _getCurrentUtcTime();

    final index = times.indexOf(currentTime);
    return index != -1 ? temperatures[index].toDouble() : temperatures.last.toDouble();
  }

  /// Retourne l'heure actuelle au format UTC
  String _getCurrentUtcTime() {
    return DateFormat("yyyy-MM-ddTHH:00").format(DateTime.now().toUtc());
  }
}