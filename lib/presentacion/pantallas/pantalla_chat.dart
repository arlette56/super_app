import 'package:flutter/material.dart';

import '../../../dominio/dinero.dart';
import '../../../dominio/mensajeria.dart';
import '../vm/chat_vm.dart';
import 'widgets.dart';

class PantallaChat extends StatefulWidget {
  final ChatVm vm;
  final VoidCallback onCambioEstado;

  const PantallaChat({super.key, required this.vm, required this.onCambioEstado});

  @override
  State<PantallaChat> createState() => _PantallaChatState();
}

class _PantallaChatState extends State<PantallaChat> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _enviar() {
    if (widget.vm.enviarTexto(_ctrl.text)) {
      _ctrl.clear();
      widget.onCambioEstado();
    }
  }

  void _mandarDinero(int centavos) {
    if (widget.vm.enviarDinero(centavos)) {
      widget.onCambioEstado();
    }
  }

  @override
  Widget build(BuildContext context) {
    final otro = widget.vm.conUsuario;
    final otrosPerfiles = ['ana', 'luis', 'marta'].where((id) => id != widget.vm.usuarioId).toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          BannerError(mensaje: widget.vm.error),
          Row(
            children: [
              const Text('Conversar con: '),
              const SizedBox(width: 8),
              for (final id in otrosPerfiles)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(id[0].toUpperCase() + id.substring(1)),
                    selected: otro == id,
                    onSelected: (_) {
                      widget.vm.seleccionarConversacion(id);
                      widget.onCambioEstado();
                    },
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView(
              children: [
                for (final m in widget.vm.mensajesActivos)
                  Align(
                    alignment: m.de == widget.vm.usuarioId ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: m.tipo == TipoMensaje.dinero
                            ? Theme.of(context).colorScheme.secondaryContainer
                            : (m.de == widget.vm.usuarioId
                                ? Theme.of(context).colorScheme.primaryContainer
                                : Theme.of(context).colorScheme.surfaceContainerHighest),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text('${m.de}: ${m.texto}'),
                    ),
                  ),
              ],
            ),
          ),
          Wrap(
            spacing: 8,
            children: [
              OutlinedButton(onPressed: () => _mandarDinero(2000), child: Text('Enviar ${formatearPesos(2000)}')),
              OutlinedButton(onPressed: () => _mandarDinero(5000), child: Text('Enviar ${formatearPesos(5000)}')),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  decoration: const InputDecoration(labelText: 'Escribe un mensaje...', border: OutlineInputBorder()),
                  onSubmitted: (_) => _enviar(),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(onPressed: _enviar, child: const Text('Enviar')),
            ],
          ),
        ],
      ),
    );
  }
}