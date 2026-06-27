import 'package:flutter/material.dart';
import 'package:shabakti/models/package.dart';
import 'package:shabakti/services/package_service.dart';

class PackageProvider extends ChangeNotifier {
  final PackageService _service;

  List<InternetPackage> _packages = [];
  bool _isLoading = false;

  List<InternetPackage> get packages => _packages;
  bool get isLoading => _isLoading;

  PackageProvider(this._service);

  Future<void> loadPackages() async {
    _isLoading = true;
    notifyListeners();
    try {
      _packages = await _service.getPackages();
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
  }
}
