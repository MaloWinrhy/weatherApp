import 'package:flutter/material.dart';
import 'package:weather_app/pages/weather_page.dart';

void main() {
  runApp(const WeatherAPP());
}

class WeatherAPP extends StatelessWidget {
  const WeatherAPP({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WeatherPage(),
    );
  }
}
