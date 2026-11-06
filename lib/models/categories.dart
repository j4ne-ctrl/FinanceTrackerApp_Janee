import 'package:flutter/material.dart';

enum TxType { income, expense }

class Cat {
  final String name;
  final IconData icon;
  final Color color;
  const Cat(this.name, this.icon, this.color);
}

class Categories {
  static const expense = <Cat>[
    Cat('Makan & Minum', Icons.restaurant_rounded, Color(0xFFEF5B6B)),
    Cat('Transport', Icons.directions_bus_rounded, Color(0xFF4DA3FF)),
    Cat('Tagihan', Icons.receipt_long_rounded, Color(0xFFF5A623)),
    Cat('Belanja', Icons.shopping_bag_rounded, Color(0xFFB36BE8)),
    Cat('Rumah', Icons.home_rounded, Color(0xFF8B7BE8)),
    Cat('Hiburan', Icons.movie_rounded, Color(0xFFFF7EB6)),
    Cat('Kesehatan', Icons.favorite_rounded, Color(0xFF2EB67D)),
    Cat('Lainnya', Icons.more_horiz_rounded, Color(0xFF8A8A99)),
  ];

  static const income = <Cat>[
    Cat('Gaji', Icons.payments_rounded, Color(0xFF2EB67D)),
    Cat('Bonus', Icons.card_giftcard_rounded, Color(0xFFF5A623)),
    Cat('Usaha', Icons.storefront_rounded, Color(0xFF4DA3FF)),
    Cat('Lainnya', Icons.more_horiz_rounded, Color(0xFF8A8A99)),
  ];

  static List<Cat> of(TxType type) =>
      type == TxType.income ? income : expense;

  static Cat find(String name, TxType type) {
    final list = of(type);
    return list.firstWhere((c) => c.name == name, orElse: () => list.last);
  }
}
