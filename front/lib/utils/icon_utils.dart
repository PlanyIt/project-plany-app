import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

IconData getIconData(String iconName) {
  switch (iconName) {
    case 'fitness_center':
      return FontAwesomeIcons.dumbbell;
    case 'flight':
      return FontAwesomeIcons.plane;
    case 'restaurant':
      return FontAwesomeIcons.utensils;
    case 'book':
      return FontAwesomeIcons.book;
    case 'music_note':
      return FontAwesomeIcons.music;
    case 'movie':
      return FontAwesomeIcons.film;
    case 'shopping_cart':
      return FontAwesomeIcons.cartShopping;
    case 'local_hospital':
      return FontAwesomeIcons.hospital;
    case 'school':
      return FontAwesomeIcons.school;
    case 'computer':
      return FontAwesomeIcons.laptop;
    case 'nature':
      return FontAwesomeIcons.tree;
    case 'brush':
      return FontAwesomeIcons.paintbrush;
    default:
      return Icons.category;
  }
}
