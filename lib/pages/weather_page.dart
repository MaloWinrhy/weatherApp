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

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    try {
      final weather = await _weatherService.getWeather('Paris');
      setState(() {
        _weather = weather;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

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
      backgroundColor: Colors.grey[900],
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : _weather != null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _weather!.cityName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 30,
                        ),
                      ),
                      Lottie.asset(getWeatherAnimation(_weather!.weatherCode)),
                      Text(
                        '${_weather!.temperature.round()}°C',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 30,
                        ),
                      ),
                    ],
                  )
                : const Text(
                    'No Data',
                    style: TextStyle(color: Colors.white),
                  ),
      ),
    );
  }
}