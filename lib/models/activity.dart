import 'package:equatable/equatable.dart';

class Activity extends Equatable {
  final String key;
  final String name;
  final String type;
  final int participants;
  final double price;
  final String? link;
  final double accessibility;

  const Activity({
    required this.key,
    required this.name,
    required this.type,
    required this.participants,
    required this.price,
    this.link,
    required this.accessibility,
  });

  factory Activity.fromJSON(Map<String, dynamic> json) {
    return Activity(
      key: json['key'],
      name: json['activity'],
      type: json['type'],
      participants: json['participants'],
      price: double.parse(json['price'].toString()),
      link: json['link'],
      accessibility: double.parse(json['accessibility'].toString()),
    );
  }

  @override
  List<Object?> get props => [
        key,
        name,
        type,
        participants,
        price,
        link,
        accessibility,
      ];
}
