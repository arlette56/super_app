import 'package:flutter/foundation.dart';

import '../../../dominio/excepciones.dart';
import '../../../dominio/monedero.dart';
import '../../../dominio/plataforma.dart';

class MonederoVm extends ChangeNotifier {
  final Plataforma _p;
  String _usuarioId;
  String? error;
  int _claveSeq = 0;

  MonederoVm(this._p, this._usuarioId);

  String get usuarioId => _usuarioId;
  int get saldoCentavos => _p.monedero.saldo(_usuarioId);
  int get puntos => _p.lealtad.puntos(_usuarioId);
  List<Movimiento> get movimientos => _p.monedero.movimientos(_usuarioId);

  void cambiarUsuario(String nuevoUsuarioId) {
    _usuarioId = nuevoUsuarioId;
    error = null;
    notifyListeners();
  }

  bool recargar(int montoCentavos, {String concepto = 'Recarga'}) {
    error = null;
    try {
      _p.monedero.depositar(_usuarioId, montoCentavos, clave: 'vm-dep-${++_claveSeq}', concepto: concepto);
      notifyListeners();
      return true;
    } catch (e) {
      error = mensajeSeguro(e);
      notifyListeners();
      return false;
    }
  }

  bool canjearPuntos(int puntosACanjear) {
    error = null;
    try {
      _p.lealtad.canjear(_usuarioId, puntosACanjear);
      notifyListeners();
      return true;
    } catch (e) {
      error = mensajeSeguro(e);
      notifyListeners();
      return false;
    }
  }
}