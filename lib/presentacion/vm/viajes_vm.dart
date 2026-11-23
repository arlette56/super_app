import 'package:flutter/foundation.dart';

import '../../../dominio/excepciones.dart';
import '../../../dominio/plataforma.dart';
import '../../../dominio/transporte.dart';
import '../../../dominio/contexto.dart';

class DestinoDemo {
  final String nombre;
  final Punto punto;
  const DestinoDemo(this.nombre, this.punto);
}

class ViajesVm extends ChangeNotifier {
  static const origenDemo = DestinoDemo('Jardín Principal', Punto(21.1561, -100.9333));
  static const destinosDemo = [
    DestinoDemo('Parroquia de Dolores', Punto(21.1565, -100.9339)),
    DestinoDemo('Casa de Hidalgo', Punto(21.1572, -100.9325)),
    DestinoDemo('Salida a San Miguel', Punto(21.1480, -100.9250)),
  ];

  final Plataforma _p;
  String _usuarioId;
  DestinoDemo _destino = destinosDemo.first;
  String? error;

  ViajesVm(this._p, this._usuarioId);

  String get usuarioId => _usuarioId;
  DestinoDemo get destino => _destino;
  List<Viaje> get misViajes => _p.viajes.deUsuario(_usuarioId);
  int get estimadoCentavos => _p.viajes.estimar(origenDemo.punto, _destino.punto);

  void cambiarUsuario(String nuevoUsuarioId) {
    _usuarioId = nuevoUsuarioId;
    error = null;
    notifyListeners();
  }

  void seleccionarDestino(DestinoDemo d) {
    _destino = d;
    error = null;
    notifyListeners();
  }

  bool solicitar() {
    error = null;
    try {
      final ctx = _p.contextoPara(Plataforma.miniViajes, _usuarioId);
      ctx.viajes.solicitar(origenDemo.punto, _destino.punto);
      notifyListeners();
      return true;
    } catch (e) {
      error = mensajeSeguro(e);
      notifyListeners();
      return false;
    }
  }

  bool aceptar(String viajeId) => _ejecutar((v) => v.aceptar(viajeId, Plataforma.conductoresDemo.first));
  bool iniciar(String viajeId) => _ejecutar((v) => v.iniciar(viajeId));
  bool finalizar(String viajeId) => _ejecutar((v) => v.finalizar(viajeId, km: 2.4, minutos: 8));
  bool cancelar(String viajeId) => _ejecutar((v) => v.cancelar(viajeId));

  bool _ejecutar(void Function(ApiViajes api) accion) {
    error = null;
    try {
      final ctx = _p.contextoPara(Plataforma.miniViajes, _usuarioId);
      accion(ctx.viajes);
      notifyListeners();
      return true;
    } catch (e) {
      error = mensajeSeguro(e);
      notifyListeners();
      return false;
    }
  }
}
