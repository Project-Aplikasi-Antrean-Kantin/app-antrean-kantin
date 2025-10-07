import 'package:flutter/material.dart';
import 'package:flutter_thermal_printer/utils/printer.dart';

class PrinterProvider extends ChangeNotifier {
  List<Printer> printer = [];
  Printer? selectedPrinter;
  bool isLoading = false;

  void selectPrinter(Printer printer) {
    selectedPrinter = printer;
    notifyListeners();
  }

  void setPrinters(List<Printer> printer) {
    this.printer = printer;
    notifyListeners();
  }

  void setPrinting(bool value) {
    isLoading = value;
    notifyListeners();
  }
}
