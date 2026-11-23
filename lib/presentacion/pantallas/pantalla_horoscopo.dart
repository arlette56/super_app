import 'package:flutter/material.dart';

import '../../../dominio/contexto.dart';
import '../../../dominio/excepciones.dart';

class PantallaHoroscopo extends StatefulWidget {
  final ContextoMiniApp ctx;

  const PantallaHoroscopo({super.key, required this.ctx});

  @override
  State<PantallaHoroscopo> createState() => _PantallaHoroscopoState();
}

class _PantallaHoroscopoState extends State<PantallaHoroscopo> {
  String resultado = 'Mini-app de tercero (solo permiso de identidad).';

  void _probarAcceso(String nombre, void Function() accion) {
    try {
      accion();
      setState(() => resultado = '$nombre: permitido (inesperado).');
    } catch (e) {
      setState(() => resultado = '$nombre bloqueado: ${mensajeSeguro(e)}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.ctx.app.emoji} ${widget.ctx.app.nombre}')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Usuario: ${widget.ctx.usuarioId}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  const Text('Hoy es buen día para probar límites de seguridad sin exponer datos privados.'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton(
                onPressed: () => _probarAcceso('Leer saldo', () => widget.ctx.monedero.saldo()),
                child: const Text('Intentar leer saldo'),
              ),
              OutlinedButton(
                onPressed: () => _probarAcceso('Cobrar', () => widget.ctx.pagos.pagar(100, 'Prueba', clave: 'h1')),
                child: const Text('Intentar cobrar'),
              ),
              OutlinedButton(
                onPressed: () => _probarAcceso('Leer chats', () => widget.ctx.mensajes.resumenes()),
                child: const Text('Intentar leer chats'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Text(resultado),
            ),
          ),
        ],
      ),
    );
  }
}