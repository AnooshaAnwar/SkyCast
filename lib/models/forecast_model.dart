
class ForecastModel {
  final String date;
  final int weatherCode;
  final double maxTemperature;
  final double minTemperature;

  ForecastModel({
    required this.date,
    required this.weatherCode,
    required this.maxTemperature,
    required this.minTemperature,
  });

  factory ForecastModel.fromJson(
    Map<String, dynamic> json,
    int index,
  ) {
    return ForecastModel(
      date: json['time'][index],
      weatherCode: json['weather_code'][index],
      maxTemperature:
          (json['temperature_2m_max'][index] as num).toDouble(),
      minTemperature:
          (json['temperature_2m_min'][index] as num).toDouble(),
    );
  }
}
