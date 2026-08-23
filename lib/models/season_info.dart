//lib/models/season_info.dart
import 'package:flutter/material.dart';

/// Bir ayın hangi mevsime ait olduğunu ve buna dair görsel/metinsel
/// bilgiyi tutan basit veri sınıfı.
class SeasonInfo {
  final String name;
  final Color color;
  final String description;

  const SeasonInfo(this.name, this.color, this.description);
}