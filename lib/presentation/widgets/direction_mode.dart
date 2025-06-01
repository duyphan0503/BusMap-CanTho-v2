import 'package:flutter/material.dart';

class DirectionMode {
  final String key;
  final IconData icon;
  final String label;
  final bool? isDefault;

  const DirectionMode(this.key, this.icon, this.label, {this.isDefault = false});
}

