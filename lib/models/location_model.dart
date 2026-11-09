
class LocationModel {
  final String name;
  final String country;
  final double latitude;
  final double longitude;
  final String timezone;

  LocationModel({
    required this.name,
    required this.country,
    required this.latitude,
    required this.longitude,
    required this.timezone,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      name: json['name'] ?? '',
      country: json['country'] ?? '',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      timezone: json['timezone'] ?? '',
    );
  }
}
