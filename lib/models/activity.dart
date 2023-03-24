import 'dart:math';

import 'package:equatable/equatable.dart';

class Activity extends Equatable {
  final String key;
  final String name;
  final String type;
  final int participants;
  final double price;
  final String? link;
  final double accessibility;

  /// random index for one of the preset asset photos
  final int photoIndex;

  const Activity({
    required this.key,
    required this.name,
    required this.type,
    required this.participants,
    required this.price,
    this.link,
    required this.accessibility,
    required this.photoIndex,
  });

  factory Activity.fromRandomJSON(Map<String, dynamic> json) {
    return Activity(
      key: json['key'],
      name: json['activity'],
      type: json['type'],
      participants: json['participants'],
      price: double.parse(json['price'].toString()),
      link: json['link'],
      accessibility: double.parse(json['accessibility'].toString()),
      photoIndex: Random().nextInt(4) + 1,
    );
  }

  factory Activity.fromFilteredJSON(Map<String, dynamic> json) {
    return Activity(
      key: json['key'],
      name: json['activity'],
      type: json['type'],
      participants: json['participants'],
      price: double.parse(json['price'].toString()),
      link: json['link'],
      accessibility: double.parse(json['accessibility'].toString()),
      photoIndex: Random().nextInt(4) + 1,
    );
  }

  String getImage() {
    switch (type) {
      case 'education':
        return 'assets/images/education_$photoIndex.jpg';
      case 'recreational':
        return 'assets/images/recreational_$photoIndex.jpg';
      case 'social':
        return 'assets/images/social_$photoIndex.jpg';
      case 'diy':
        return 'assets/images/diy_$photoIndex.jpg';
      case 'charity':
        return 'assets/images/charity_$photoIndex.jpg';
      case 'cooking':
        return 'assets/images/cooking_$photoIndex.jpg';
      case 'relaxation':
        return 'assets/images/relax_$photoIndex.jpg';
      case 'music':
        return 'assets/images/music_$photoIndex.jpg';
      case 'busywork':
        return 'assets/images/busy_$photoIndex.jpg';
      default:
        return 'assets/images/placeholder.jpg';
    }
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
