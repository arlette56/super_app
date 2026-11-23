import 'package:flutter/foundation.dart';

import '../../../dominio/excepciones.dart';
import '../../../dominio/mensajeria.dart';
import '../../../dominio/plataforma.dart';

class ChatVm extends ChangeNotifier {
  final Plataforma _p;
  String _usuarioId;
  String? _conUsuario;
  String? error;
  int _claveSeq = 0;

  ChatVm(this._p, this._usuarioId) {
    final otros = _p.perfiles.where((x) => x.id != _usuarioId).toList();
    _conUsuario = otros.isNotEmpty ? otros.first.id : null;
  }

  String get usuarioId => _usuarioId;
  String? get conUsuario => _conUsuario;
  List<ResumenConversacion> get resumenes => _p.mensajes.resumenes(_usuarioId);
  List<Mensaje> get mensajesSistema => _p.mensajes.deSistema(_usuarioId);

  List<Mensaje> get mensajesActivos {
    final otro = _conUsuario;
    if (otro == null) return const [];
    return _p.mensajes.conversacion(_usuarioId, otro);
  }

  void cambiarUsuario(String nuevoUsuarioId) {
    _usuarioId = nuevoUsuarioId;
    final otros = _p.perfiles.where((x) => x.id != _usuarioId).toList();
    if (_conUsuario == _usuarioId || _conUsuario == null) {
      _conUsuario = otros.isNotEmpty ? otros.first.id : null;
    }
    error = null;
    if (_conUsuario != null) {
      _p.mensajes.marcarLeidos(_usuarioId, _conUsuario!);
    }
    notifyListeners();
  }

  void seleccionarConversacion(String con) {
    _conUsuario = con;
    error = null;
    _p.mensajes.marcarLeidos(_usuarioId, con);
    notifyListeners();
  }

  bool enviarTexto(String texto) {
    error = null;
    final otro = _conUsuario;
    if (otro == null) return false;
    try {
      final ctx = _p.contextoPara(Plataforma.miniChat, _usuarioId);
      ctx.mensajes.enviar(otro, texto);
      notifyListeners();
      return true;
    } catch (e) {
      error = mensajeSeguro(e);
      notifyListeners();
      return false;
    }
  }

  bool enviarDinero(int montoCentavos) {
    error = null;
    final otro = _conUsuario;
    if (otro == null) return false;
    try {
      final ctx = _p.contextoPara(Plataforma.miniChat, _usuarioId);
      ctx.pagos.enviarDinero(otro, montoCentavos, clave: 'vm-chat-${++_claveSeq}');
      notifyListeners();
      return true;
    } catch (e) {
      error = mensajeSeguro(e);
      notifyListeners();
      return false;
    }
  }
}
