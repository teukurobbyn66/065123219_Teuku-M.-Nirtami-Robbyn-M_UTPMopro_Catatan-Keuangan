import 'package:flutter/material.dart';

class TxType {
  static const income = 'income';
  static const expense = 'expense';
}

class TxCategory {
  final String name;
  final IconData icon;
  const TxCategory(this.name, this.icon);
}

const expenseCategories = <TxCategory>[
  TxCategory('Makanan', Icons.restaurant_outlined),
  TxCategory('Transportasi', Icons.directions_bus_outlined),
  TxCategory('Belanja', Icons.shopping_bag_outlined),
  TxCategory('Tagihan', Icons.receipt_long_outlined),
  TxCategory('Hiburan', Icons.movie_outlined),
  TxCategory('Kesehatan', Icons.favorite_border),
  TxCategory('Pendidikan', Icons.school_outlined),
  TxCategory('Lainnya', Icons.more_horiz),
];

const incomeCategories = <TxCategory>[
  TxCategory('Gaji', Icons.payments_outlined),
  TxCategory('Bisnis', Icons.storefront_outlined),
  TxCategory('Lainnya', Icons.more_horiz),
];

final allCategories = <TxCategory>[
  ...expenseCategories,
  ...incomeCategories.where((c) => c.name != 'Lainnya'),
];

IconData categoryIcon(String name) => allCategories
    .firstWhere((c) => c.name == name, orElse: () => allCategories[7])
    .icon;

List<TxCategory> categoriesFor(String type) =>
    type == TxType.income ? incomeCategories : expenseCategories;
