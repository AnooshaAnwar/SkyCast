
class WeatherModel {
  final double temperature;
  final double feelsLike;
  final int weatherCode;
  final double windSpeed;
  final String observationTime;

  WeatherModel({
    required this.temperature,
    required this.feelsLike,
    required this.weatherCode,
    required this.windSpeed,
    required this.observationTime,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      temperature: (json['temperature_2m'] as num).toDouble(),
      feelsLike: (json['apparent_temperature'] as num).toDouble(),
      weatherCode: json['weather_code'] as int,
      windSpeed: (json['wind_speed_10m'] as num).toDouble(),
      observationTime: json['time'] as String,
    );
  }
}
