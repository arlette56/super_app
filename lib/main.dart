import 'package:flutter/material.dart';

import 'dominio/mini_app.dart';
import 'dominio/plataforma.dart';
import 'presentacion/pantallas/pantalla_chat.dart';
import 'presentacion/pantallas/pantalla_horoscopo.dart';
import 'presentacion/pantallas/pantalla_inicio.dart';
import 'presentacion/pantallas/pantalla_metricas.dart';
import 'presentacion/pantallas/pantalla_monedero.dart';
import 'presentacion/pantallas/pantalla_tienda.dart';
import 'presentacion/pantallas/pantalla_viajes.dart';
import 'presentacion/pantallas/widgets.dart';
import 'presentacion/vm/chat_vm.dart';
import 'presentacion/vm/inicio_vm.dart';
import 'presentacion/vm/metricas_vm.dart';
import 'presentacion/vm/monedero_vm.dart';
import 'presentacion/vm/tienda_vm.dart';
import 'presentacion/vm/viajes_vm.dart';

void main() {
  runApp(const SuperDoloresApp());
}

class SuperDoloresApp extends StatefulWidget {
  const SuperDoloresApp({super.key});

  @override
  State<SuperDoloresApp> createState() => _SuperDoloresAppState();
}

class _SuperDoloresAppState extends State<SuperDoloresApp> {
  late final Plataforma _plataforma;
  late final InicioVm _inicioVm;
  late final ChatVm _chatVm;
  late final MonederoVm _monederoVm;
  late final TiendaVm _tiendaVm;
  late final ViajesVm _viajesVm;
  late final MetricasVm _metricasVm;

  String _usuarioId = 'ana';

  @override
  void initState() {
    super.initState();
    _plataforma = Plataforma(reloj: DateTime.now)..cargarDatosDemo();
    _inicioVm = InicioVm(_plataforma, _usuarioId);
    _chatVm = ChatVm(_plataforma, _usuarioId);
    _monederoVm = MonederoVm(_plataforma, _usuarioId);
    _tiendaVm = TiendaVm(_plataforma, _usuarioId);
    _viajesVm = ViajesVm(_plataforma, _usuarioId);
    _metricasVm = MetricasVm(_plataforma);
  }

  void _cambiarUsuario(String nuevoId) {
    setState(() {
      _usuarioId = nuevoId;
      _inicioVm.cambiarUsuario(nuevoId);
      _chatVm.cambiarUsuario(nuevoId);
      _monederoVm.cambiarUsuario(nuevoId);
      _tiendaVm.cambiarUsuario(nuevoId);
      _viajesVm.cambiarUsuario(nuevoId);
    });
  }

  void _refrescarTodo() {
    setState(() {
      _inicioVm.refrescar();
      _metricasVm.refrescar();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Super Dolores',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
      home: _ConchaPrincipal(
        plataforma: _plataforma,
        usuarioId: _usuarioId,
        onCambiarUsuario: _cambiarUsuario,
        onRefrescarTodo: _refrescarTodo,
        inicioVm: _inicioVm,
        chatVm: _chatVm,
        monederoVm: _monederoVm,
        tiendaVm: _tiendaVm,
        viajesVm: _viajesVm,
        metricasVm: _metricasVm,
      ),
    );
  }
}

class _ConchaPrincipal extends StatefulWidget {
  final Plataforma plataforma;
  final String usuarioId;
  final ValueChanged<String> onCambiarUsuario;
  final VoidCallback onRefrescarTodo;
  final InicioVm inicioVm;
  final ChatVm chatVm;
  final MonederoVm monederoVm;
  final TiendaVm tiendaVm;
  final ViajesVm viajesVm;
  final MetricasVm metricasVm;

  const _ConchaPrincipal({
    required this.plataforma,
    required this.usuarioId,
    required this.onCambiarUsuario,
    required this.onRefrescarTodo,
    required this.inicioVm,
    required this.chatVm,
    required this.monederoVm,
    required this.tiendaVm,
    required this.viajesVm,
    required this.metricasVm,
  });

  @override
  State<_ConchaPrincipal> createState() => _ConchaPrincipalState();
}

class _ConchaPrincipalState extends State<_ConchaPrincipal> {
  int _indiceNav = 0;

  void _abrirMiniApp(BuildContext context, MiniApp app) {
    switch (app.id) {
      case 'chat':
        setState(() => _indiceNav = 1);
      case 'monedero':
        setState(() => _indiceNav = 2);
      case 'tienda':
        setState(() => _indiceNav = 3);
      case 'viajes':
        setState(() => _indiceNav = 4);
      case 'horoscopo':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PantallaHoroscopo(ctx: widget.plataforma.contextoPara(app, widget.usuarioId)),
          ),
        );
    }
  }

  void _abrirMetricas(BuildContext context) {
    widget.metricasVm.refrescar();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PantallaMetricas(vm: widget.metricasVm)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activas = widget.plataforma.registro.activas;
    final pantallas = <Widget>[
      PantallaInicio(
        vm: widget.inicioVm,
        miniAppsActivas: activas,
        onAbrirMiniApp: (app) => _abrirMiniApp(context, app),
        onAbrirMetricas: () => _abrirMetricas(context),
      ),
      PantallaChat(vm: widget.chatVm, onCambioEstado: widget.onRefrescarTodo),
      PantallaMonedero(vm: widget.monederoVm, onCambioEstado: widget.onRefrescarTodo),
      PantallaTienda(vm: widget.tiendaVm, onCambioEstado: widget.onRefrescarTodo),
      PantallaViajes(vm: widget.viajesVm, onCambioEstado: widget.onRefrescarTodo),
    ];

    final indiceSeguro = _indiceNav < pantallas.length ? _indiceNav : 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Super Dolores'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(54),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10, left: 12, right: 12),
            child: SelectorUsuario(
              perfiles: widget.plataforma.perfiles,
              usuarioActivo: widget.usuarioId,
              onCambiar: widget.onCambiarUsuario,
            ),
          ),
        ),
      ),
      body: pantallas[indiceSeguro],
      bottomNavigationBar: NavigationBar(
        selectedIndex: indiceSeguro,
        onDestinationSelected: (i) => setState(() => _indiceNav = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Inicio'),
          NavigationDestination(icon: Icon(Icons.chat_bubble_outline), selectedIcon: Icon(Icons.chat_bubble), label: 'Chat'),
          NavigationDestination(icon: Icon(Icons.account_balance_wallet_outlined), selectedIcon: Icon(Icons.account_balance_wallet), label: 'Monedero'),
          NavigationDestination(icon: Icon(Icons.storefront_outlined), selectedIcon: Icon(Icons.storefront), label: 'Tienda'),
          NavigationDestination(icon: Icon(Icons.local_taxi_outlined), selectedIcon: Icon(Icons.local_taxi), label: 'Viajes'),
        ],
      ),
    );
  }
}
