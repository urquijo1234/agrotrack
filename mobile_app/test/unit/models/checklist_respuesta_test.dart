import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/informes/domain/models/checklist_respuesta.dart';

void main() {
  group('ChecklistRespuesta', () {
    // ==========================================
    // SECCIÓN V — 3 columnas
    // ==========================================
    group('Sección V — toMap y fromMap', () {
      final respuestaSeccionV = ChecklistRespuesta(
        numeroItem: 35,
        seccion: 'V',
        cumple: true,
        estado: 'B',
        senalizado: true,
        observacion: null,
      );

      test('toMap serializa correctamente sección V', () {
        final map = respuestaSeccionV.toMap();

        expect(map['numeroItem'], 35);
        expect(map['seccion'], 'V');
        expect(map['cumple'], true);
        expect(map['estado'], 'B');
        expect(map['senalizado'], true);
        expect(map['observacion'], isNull);
      });

      test('fromMap reconstruye sección V correctamente', () {
        final map = {
          'numeroItem': 35,
          'seccion': 'V',
          'cumple': true,
          'estado': 'B',
          'senalizado': true,
          'observacion': null,
        };

        final respuesta = ChecklistRespuesta.fromMap(map);

        expect(respuesta.numeroItem, 35);
        expect(respuesta.seccion, 'V');
        expect(respuesta.cumple, true);
        expect(respuesta.estado, 'B');
        expect(respuesta.senalizado, true);
        expect(respuesta.observacion, isNull);
      });

      test('estado puede ser B o M', () {
        final respuestaB = ChecklistRespuesta(
          numeroItem: 36,
          seccion: 'V',
          estado: 'B',
        );
        final respuestaM = ChecklistRespuesta(
          numeroItem: 37,
          seccion: 'V',
          estado: 'M',
        );

        expect(respuestaB.estado, 'B');
        expect(respuestaM.estado, 'M');
      });

      test('cumple false se serializa correctamente', () {
        final respuesta = ChecklistRespuesta(
          numeroItem: 38,
          seccion: 'V',
          cumple: false,
          estado: 'M',
          senalizado: false,
        );

        final map = respuesta.toMap();
        expect(map['cumple'], false);
        expect(map['estado'], 'M');
        expect(map['senalizado'], false);
      });
    });

    // ==========================================
    // SECCIÓN VI y VII — solo CUMPLE
    // ==========================================
    group('Sección VI/VII — solo cumple', () {
      test('toMap serializa sección VI correctamente', () {
        final respuesta = ChecklistRespuesta(
          numeroItem: 44,
          seccion: 'VI',
          cumple: true,
          estado: null,
          senalizado: null,
          observacion: null,
        );

        final map = respuesta.toMap();

        expect(map['numeroItem'], 44);
        expect(map['seccion'], 'VI');
        expect(map['cumple'], true);
        expect(map['estado'], isNull);
        expect(map['senalizado'], isNull);
      });

      test('fromMap reconstruye sección VII correctamente', () {
        final map = {
          'numeroItem': 57,
          'seccion': 'VII',
          'cumple': false,
          'estado': null,
          'senalizado': null,
          'observacion': null,
        };

        final respuesta = ChecklistRespuesta.fromMap(map);

        expect(respuesta.numeroItem, 57);
        expect(respuesta.seccion, 'VII');
        expect(respuesta.cumple, false);
        expect(respuesta.estado, isNull);
        expect(respuesta.senalizado, isNull);
      });
    });

    // ==========================================
    // SECCIÓN INFO — cumple + observacion
    // ==========================================
    group('Sección INFO — cumple y observacion', () {
      test('toMap serializa sección INFO con observacion', () {
        final respuesta = ChecklistRespuesta(
          numeroItem: 92,
          seccion: 'INFO',
          cumple: null,
          estado: null,
          senalizado: null,
          observacion: 'Plan fitosanitario PCO vigente',
        );

        final map = respuesta.toMap();

        expect(map['numeroItem'], 92);
        expect(map['seccion'], 'INFO');
        expect(map['cumple'], isNull);
        expect(map['observacion'], 'Plan fitosanitario PCO vigente');
      });

      test('fromMap reconstruye sección INFO con observacion', () {
        final map = {
          'numeroItem': 97,
          'seccion': 'INFO',
          'cumple': null,
          'estado': null,
          'senalizado': null,
          'observacion': '19-09-2025',
        };

        final respuesta = ChecklistRespuesta.fromMap(map);
        expect(respuesta.observacion, '19-09-2025');
        expect(respuesta.cumple, isNull);
      });
    });

    // ==========================================
    // TESTS copyWith
    // ==========================================
    group('copyWith', () {
      final base = ChecklistRespuesta(
        numeroItem: 35,
        seccion: 'V',
        cumple: null,
        estado: null,
        senalizado: null,
      );

      test('actualiza cumple correctamente', () {
        final actualizado = base.copyWith(cumple: true);
        expect(actualizado.cumple, true);
        expect(actualizado.numeroItem, base.numeroItem);
        expect(actualizado.seccion, base.seccion);
      });

      test('actualiza estado correctamente', () {
        final actualizado = base.copyWith(estado: 'B');
        expect(actualizado.estado, 'B');
        expect(actualizado.cumple, base.cumple);
      });

      test('actualiza senalizado correctamente', () {
        final actualizado = base.copyWith(senalizado: false);
        expect(actualizado.senalizado, false);
      });

      test('actualiza observacion correctamente', () {
        final actualizado =
            base.copyWith(observacion: 'Observación de prueba');
        expect(actualizado.observacion, 'Observación de prueba');
      });

      test('mantiene campos no modificados intactos', () {
        final actualizado = base.copyWith(cumple: true);
        expect(actualizado.estado, base.estado);
        expect(actualizado.senalizado, base.senalizado);
        expect(actualizado.observacion, base.observacion);
      });
    });

    // ==========================================
    // TESTS respuesta vacía
    // ==========================================
    group('Respuesta vacía', () {
      test('todos los campos opcionales son null por defecto', () {
        final respuesta = ChecklistRespuesta(
          numeroItem: 44,
          seccion: 'VI',
        );

        expect(respuesta.cumple, isNull);
        expect(respuesta.estado, isNull);
        expect(respuesta.senalizado, isNull);
        expect(respuesta.observacion, isNull);
      });

      test('ciclo toMap y fromMap preserva nulls', () {
        final respuesta = ChecklistRespuesta(
          numeroItem: 44,
          seccion: 'VI',
        );

        final map = respuesta.toMap();
        final reconstruida = ChecklistRespuesta.fromMap(map);

        expect(reconstruida.cumple, isNull);
        expect(reconstruida.estado, isNull);
        expect(reconstruida.senalizado, isNull);
        expect(reconstruida.observacion, isNull);
      });
    });
  });
}