import 'package:flutter/material.dart';

class NavigationController extends ChangeNotifier {
  int index = 0;

  void change(int i) {
    index = i;
    notifyListeners();
  }
}
