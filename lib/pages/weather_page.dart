import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:weather_app/models/weather_model.dart';
import 'package:weather_app/services/weather_service.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({Key? key}) : super(key: key);

  @override
  _WeatherPageState createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final WeatherService _weatherService = WeatherService();
  Weather? _weather;
  bool _isLoading = true;
  String _errorMessage = '';
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _setInitialTheme();
    _fetchWeatherFromLocation();
  }

  // Cette méthode définit le thème initial en fonction de l'heure actuelle.
  void _setInitialTheme() {
    int hour = DateTime.now().hour;
    setState(() {
      _isDarkMode = (hour < 7 || hour > 19);
    });
  }

  // Cette méthode récupère les informations météorologiques à partir de la localisation actuelle.
  Future<void> _fetchWeatherFromLocation() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final weather = await _weatherService.getWeatherFromCurrentLocation();
      setState(() {
        _weather = weather;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  // Cette méthode retourne l'animation appropriée en fonction du code météo.
  String getWeatherAnimation(int weatherCode) {
    if (weatherCode >= 0 && weatherCode <= 3) {
      return 'assets/sun.json';
    } else if (weatherCode >= 45 && weatherCode <= 48) {
      return 'assets/halfsun.json';
    } else if (weatherCode >= 51 && weatherCode <= 82) {
      return 'assets/cloud.json';
    } else if (weatherCode >= 95 && weatherCode <= 99) {
      return 'assets/thunder.json';
    } else {
      return 'assets/cloud.json';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.location_on, color: Colors.white),
          onPressed: _fetchWeatherFromLocation,
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isDarkMode ? Icons.dark_mode : Icons.light_mode,
              color: _isDarkMode ? Colors.white : Colors.black,
            ),
            onPressed: () {
              setState(() {
                _isDarkMode = !_isDarkMode;
              });
            },
          ),
        ],
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : _errorMessage.isNotEmpty
                ? Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.red, fontSize: 18),
                    textAlign: TextAlign.center,
                  )
                : _weather != null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _weather!.cityName,
                            style: TextStyle(
                              color: _isDarkMode ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 30,
                            ),
                          ),
                          Lottie.asset(getWeatherAnimation(_weather!.weatherCode)),
                          Text(
                            '${_weather!.temperature.round()}°C',
                            style: TextStyle(
                              color: _isDarkMode ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 30,
                            ),
                          ),
                        ],
                      )
                    : const Text(
                        'No data available',
                        style: TextStyle(color: Colors.white),
                      ),
      ),
    );
  }
}
