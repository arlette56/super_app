import 'package:flutter/material.dart';

import '../../../dominio/dinero.dart';
import '../../../dominio/mini_app.dart';
import '../../../dominio/plataforma.dart';

class BannerError extends StatelessWidget {
  final String? mensaje;
  const BannerError({super.key, this.mensaje});

  @override
  Widget build(BuildContext context) {
    final msg = mensaje;
    if (msg == null || msg.isEmpty) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        msg,
        style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class SelectorUsuario extends StatelessWidget {
  final List<PerfilDemo> perfiles;
  final String usuarioActivo;
  final ValueChanged<String> onCambiar;

  const SelectorUsuario({
    super.key,
    required this.perfiles,
    required this.usuarioActivo,
    required this.onCambiar,
  });

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<String>(
      segments: [
        for (final p in perfiles) ButtonSegment<String>(value: p.id, label: Text(p.nombre)),
      ],
      selected: {usuarioActivo},
      onSelectionChanged: (s) {
        if (s.isNotEmpty) onCambiar(s.first);
      },
    );
  }
}

class TarjetaResumenUsuario extends StatelessWidget {
  final String nombre;
  final int saldoCentavos;
  final int puntos;
  final String nivelNombre;
  final int racha;

  const TarjetaResumenUsuario({
    super.key,
    required this.nombre,
    required this.saldoCentavos,
    required this.puntos,
    required this.nivelNombre,
    required this.racha,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hola, $nombre', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text('Saldo: ${formatearPesos(saldoCentavos)}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('$puntos pts · $nivelNombre'),
                const SizedBox(height: 4),
                Text('🔥 Racha: $racha días'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class TileMiniApp extends StatelessWidget {
  final MiniApp app;
  final VoidCallback onTap;

  const TileMiniApp({super.key, required this.app, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Text(app.emoji, style: const TextStyle(fontSize: 26)),
        title: Text(app.nombre),
        subtitle: Text('Permisos: ${app.permisos.map((p) => p.name).join(', ')}'),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}