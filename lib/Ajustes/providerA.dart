import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Gestiona el estado global de la app. Se encarga de manejar el tema y el idioma
class ProviderA extends ChangeNotifier {
  bool _modoOscuro = false;
  Locale _idioma = Locale('es');

  /// Constructor que carga las preferencias guardadas al iniciar la app
  ProviderA() {
    _cargarPreferencias();
  }

  /// Obtiene el estado actual del modo oscuro
  bool get modoOscuro => _modoOscuro;

  /// Obtiene el idioma actual
  Locale get idioma => _idioma;

  /// Cambia el modo oscuro y guarda la preferencia
  Future<void> cambiarModoOscuro(bool valor) async {
    try {
      _modoOscuro = valor;
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('modoOscuro', valor);
    } catch (e) {
      print("Error al guardar el modo oscuro: $e");
    }
  }

  /// Cambia el idioma de la app y guarda la preferencia
  Future<void> cambiarIdioma(String codigoIdioma) async {
    try {
      _idioma = Locale(codigoIdioma);
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('idioma', codigoIdioma);
    } catch (e) {
      print("Error al cambiar el idioma: $e");
    }
  }

  /// Carga las preferencias guardadas en el dispositivo.
  Future<void> _cargarPreferencias() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final nuevoModoOscuro = prefs.getBool('modoOscuro') ?? false;
      final nuevoIdioma = Locale(prefs.getString('idioma') ?? 'es');

      if (nuevoModoOscuro != _modoOscuro || nuevoIdioma != _idioma) {
        _modoOscuro = nuevoModoOscuro;
        _idioma = nuevoIdioma;
        notifyListeners();
      }
    } catch (e) {
      print("Error al cargar las preferencias: $e");
    }
  }
}
