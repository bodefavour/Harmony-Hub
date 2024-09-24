import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FFAppState extends ChangeNotifier {
  static FFAppState _instance = FFAppState._internal();

  factory FFAppState() {
    return _instance;
  }

  FFAppState._internal();

  static void reset() {
    _instance = FFAppState._internal();
  }

  Future initializePersistedState() async {
    prefs = await SharedPreferences.getInstance();
    _safeInit(() {
      _Favorites = prefs.getBool('ff_Favorites') ?? _Favorites;
    });
  }

  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }

  late SharedPreferences prefs;

  bool _Favorites = true;
  bool get Favorites => _Favorites;
  set Favorites(bool value) {
    _Favorites = value;
    prefs.setBool('ff_Favorites', value);
  }

  int _Logindetails = 0;
  int get Logindetails => _Logindetails;
  set Logindetails(int value) {
    _Logindetails = value;
  }
}

void _safeInit(Function() initializeField) {
  try {
    initializeField();
  } catch (_) {}
}

Future _safeInitAsync(Function() initializeField) async {
  try {
    await initializeField();
  } catch (_) {}
}
