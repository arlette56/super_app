import 'package:flutter_test/flutter_test.dart';
import 'package:super_dolores/dominio/dinero.dart';

void main() {
  group('dinero y fechas', () {
    test('formatearPesos', () {
      expect(formatearPesos(125000), r'$1,250.00');
      expect(formatearPesos(5), r'$0.05');
      expect(formatearPesos(0), r'$0.00');
      expect(formatearPesos(-5050), r'-$50.50');
      expect(formatearPesos(100000000), r'$1,000,000.00');
    });
    test('porcentaje redondea al más cercano', () {
      expect(porcentaje(9999, 5), 500);
      expect(porcentaje(5600, 5), 280);
    });
    test('lunesDe: toda la semana apunta al mismo lunes', () {
      final lunes = DateTime(2026, 11, 9);
      for (var d = 9; d <= 15; d++) {
        expect(lunesDe(DateTime(2026, 11, d, 23, 59)), lunes, reason: 'día $d');
      }
      expect(lunesDe(DateTime(2026, 11, 16)), DateTime(2026, 11, 16));
    });
    test('masDias cruza de mes', () => expect(masDias(DateTime(2026, 11, 28), 5), DateTime(2026, 12, 3)));
  });
}