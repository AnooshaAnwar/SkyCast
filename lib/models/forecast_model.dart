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

  factory ForecastModel.fromJson(Map<String, dynamic> json, int index) {
    final dates = json['time'] as List;
    final codes = json['weather_code'] as List;
    final maximums = json['temperature_2m_max'] as List;
    final minimums = json['temperature_2m_min'] as List;

    return ForecastModel(
      date: dates[index].toString(),
      weatherCode: (codes[index] as num).toInt(),
      maxTemperature: (maximums[index] as num).toDouble(),
      minTemperature: (minimums[index] as num).toDouble(),
    );
  }
}
