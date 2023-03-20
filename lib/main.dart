import 'dart:js';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/provider/cart_provider.dart';
import 'views/list_tenant.dart';
import 'package:testgetdata/views/cart.dart';
import '';

void main() {
  runApp(ChangeNotifierProvider(
    create: (context) => CartProvider(),
      child: Cart(),
    )
  );
}