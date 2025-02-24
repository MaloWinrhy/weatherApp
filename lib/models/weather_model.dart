class Weather {
  final String cityName;
  final double temperature;
  final int weatherCode;

  Weather({
    required this.cityName,
    required this.temperature,
    required this.weatherCode,
  });

  factory Weather.fromJson(Map<String, dynamic> json, String cityName) {
    return Weather(
      cityName: cityName,
      temperature: json['temperature'],
      weatherCode: json['weathercode'],
    );
  }
}