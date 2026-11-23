import 'package:flutter_test/flutter_test.dart';
import 'package:super_dolores/dominio/comercio.dart';
import 'package:super_dolores/dominio/dinero.dart';
import 'package:super_dolores/dominio/excepciones.dart';
import 'package:super_dolores/dominio/plataforma.dart';
import 'package:super_dolores/dominio/transporte.dart';

DateTime ahora = DateTime(2026, 11, 9, 10);
const _jardin = Punto(21.1561, -100.9333);
const _parroquia = Punto(21.1565, -100.9339);
const _lejos = Punto(21.2000, -100.9000);

Plataforma nueva() => Plataforma(reloj: () => ahora)..cargarDatosDemo();

void main() {
  setUp(() => ahora = DateTime(2026, 11, 9, 10));

  group('Comercio', () {
    test('cobra 5% de comisión y conserva el dinero total del sistema', () {
      final p = nueva();
      final totalAntes = p.monedero.saldo('ana') +
          p.monedero.saldo('dueno-tortilleria') +
          p.monedero.saldo(ServicioComercio.cuentaPlataforma);
      p.comercio.comprar(usuarioId: 'ana', tiendaId: 'tortilleria', items: {'kilo': 2}, clave: 'p1'); // $56.00
      expect(p.monedero.saldo('ana'), 100000 - 5600);
      expect(p.monedero.saldo('dueno-tortilleria'), 5600 - porcentaje(5600, 5));
      expect(p.monedero.saldo(ServicioComercio.cuentaPlataforma), porcentaje(5600, 5));
      final totalDespues = p.monedero.saldo('ana') +
          p.monedero.saldo('dueno-tortilleria') +
          p.monedero.saldo(ServicioComercio.cuentaPlataforma);
      expect(totalDespues, totalAntes);
    });
    test('descuenta existencias y es idempotente con la misma clave', () {
      final p = nueva()..monedero.depositar('ana', 50000, clave: 'extra-jarron');
      final a = p.comercio.comprar(usuarioId: 'ana', tiendaId: 'talavera', items: {'jarron': 1}, clave: 'k1');
      final b = p.comercio.comprar(usuarioId: 'ana', tiendaId: 'talavera', items: {'jarron': 1}, clave: 'k1');
      expect(identical(a, b), isTrue);
      expect(p.comercio.tiendas.firstWhere((t) => t.id == 'talavera').producto('jarron')!.existencias, 3);
    });
    test('si faltan existencias o saldo, no descuenta inventario ni mueve dinero', () {
      final p = nueva();
      expect(
        () => p.comercio.comprar(usuarioId: 'ana', tiendaId: 'talavera', items: {'jarron': 5}, clave: 'x'),
        throwsA(isA<ExistenciasInsuficientesException>()),
      );
      expect(p.monedero.saldo('ana'), 100000);
      expect(p.comercio.tiendas.firstWhere((t) => t.id == 'talavera').producto('jarron')!.existencias, 4);
    });
  });

  group('Transporte', () {
    test('distancia Haversine y tarifa mínima', () {
      expect(distanciaKm(_jardin, _jardin), 0);
      expect(distanciaKm(_jardin, _parroquia), greaterThan(0));
      expect(Tarifa.calcular(km: 0.1, minutos: 1), Tarifa.minimoCentavos);
      expect(Tarifa.calcular(km: 10, minutos: 20, multiplicador: 5.0), greaterThan(Tarifa.minimoCentavos));
      expect(distanciaKm(_jardin, _lejos), greaterThan(1));
    });
    test('máquina de estados: solo transiciones válidas', () {
      final p = nueva();
      final v = p.viajes.solicitar('ana', _jardin, _parroquia);
      expect(v.estado, EstadoViaje.solicitado);
      expect(() => p.viajes.iniciar(v.id), throwsA(isA<TransicionInvalidaException>()));
      p.viajes.aceptar(v.id, 'conductor1');
      p.viajes.iniciar(v.id);
      expect(() => p.viajes.cancelar(v.id), throwsA(isA<TransicionInvalidaException>()));
      p.viajes.finalizar(v.id, kmReal: 2.0, minutosReal: 6);
      expect(p.viajes.porId(v.id)!.estado, EstadoViaje.finalizado);
      expect(p.monedero.saldo('conductor1'), greaterThan(0));
    });
    test('cancelar tras aceptar cobra cancelación; antes es gratis', () {
      final p = nueva();
      final v1 = p.viajes.solicitar('ana', _jardin, _parroquia);
      p.viajes.cancelar(v1.id);
      expect(p.monedero.saldo('ana'), 100000);

      final v2 = p.viajes.solicitar('ana', _jardin, _parroquia);
      p.viajes.aceptar(v2.id, 'conductor1');
      p.viajes.cancelar(v2.id);
      expect(p.monedero.saldo('ana'), 100000 - Tarifa.cancelacionCentavos);
      expect(p.monedero.saldo('conductor1'), Tarifa.cancelacionCentavos);
    });
  });

  group('Integración: un día en la vida de Ana', () {
    test('chat, dinero, compra y viaje coordinados por eventos', () {
      final p = nueva();
      p.mensajes.enviar('ana', 'luis', '¿Vamos al centro?');
      p.mensajes.enviarDinero('ana', 'luis', 5000, clave: 'd1');
      p.comercio.comprar(usuarioId: 'ana', tiendaId: 'tortilleria', items: {'kilo': 1}, clave: 'c1');
      final v = p.viajes.solicitar('ana', _jardin, _parroquia);
      p.viajes.aceptar(v.id, 'conductor1');
      p.viajes.iniciar(v.id);
      p.viajes.finalizar(v.id, kmReal: 1.5, minutosReal: 5);

      expect(p.analitica.dau(ahora), 1);
      expect(p.lealtad.puntos('ana'), greaterThan(0));
      expect(p.bus.errores, isEmpty);
      expect(p.mensajes.noLeidos('luis'), 2);
      expect(p.notificador.de('luis').length, 1);
    });
  });
}
