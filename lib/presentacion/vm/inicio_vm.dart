import 'package:flutter/foundation.dart';

import '../../../dominio/eventos.dart';
import '../../../dominio/lealtad.dart';
import '../../../dominio/notificaciones.dart';
import '../../../dominio/plataforma.dart';
import '../../../dominio/sugerencias.dart';

class InicioVm extends ChangeNotifier {
  final Plataforma _p;
  String _usuarioId;
  final Set<String> _sinPromoUsuarios = {};

  InicioVm(this._p, this._usuarioId);

  String get usuarioId => _usuarioId;
  String get nombreUsuario => _p.perfiles.firstWhere((x) => x.id == _usuarioId).nombre;
  int get saldoCentavos => _p.monedero.saldo(_usuarioId);
  int get puntos => _p.lealtad.puntos(_usuarioId);
  NivelLealtad get nivel => _p.lealtad.nivel(_usuarioId);
  int get racha => _p.lealtad.racha(_usuarioId);
  int get noLeidos => _p.mensajes.noLeidos(_usuarioId);
  List<Notificacion> get notificaciones => _p.notificador.de(_usuarioId);

  bool get promocionesActivas => !_sinPromoUsuarios.contains(_usuarioId);

  Sugerencia get sugerencia {
    final hace30 = _p.reloj().subtract(const Duration(days: 30));
    final conteo = <Servicio, int>{};
    for (final r in _p.analitica.registros) {
      if (r.usuarioId == _usuarioId && !r.fecha.isBefore(hace30)) {
        conteo[r.servicio] = (conteo[r.servicio] ?? 0) + 1;
      }
    }
    return sugerirServicio(usosUltimos30Dias: conteo, ahora: _p.reloj());
  }

  void cambiarUsuario(String nuevoUsuarioId) {
    _usuarioId = nuevoUsuarioId;
    notifyListeners();
  }

  void togglePromociones(bool activas) {
    if (activas) {
      _sinPromoUsuarios.remove(_usuarioId);
    } else {
      _sinPromoUsuarios.add(_usuarioId);
    }
    _p.notificador.configurarPromociones(_usuarioId, activas: activas);
    notifyListeners();
  }

  void refrescar() => notifyListeners();
}
