import 'equipo.dart';

class FiltroInventario {
  const FiltroInventario({
    this.texto = '',
    this.estado,
    this.categoria,
    this.soloFavoritos = false,
  });

  final String texto;
  final String? estado;
  final String? categoria;
  final bool soloFavoritos;

  List<Equipo> aplicar(
    Iterable<Equipo> equipos, {
    bool Function(String codigo)? esFavorito,
  }) {
    final textoNormalizado = _normalizar(texto.trim());

    return equipos
        .where((equipo) {
          if (soloFavoritos && !(esFavorito?.call(equipo.codigo) ?? false)) {
            return false;
          }

          if (estado != null && equipo.estado != estado) return false;
          if (categoria != null && equipo.categoria != categoria) return false;

          if (textoNormalizado.isEmpty) return true;

          return [
            equipo.codigo,
            equipo.nombre,
            equipo.ubicacion,
          ].map(_normalizar).any((valor) => valor.contains(textoNormalizado));
        })
        .toList(growable: false);
  }

  static String _normalizar(String valor) {
    return valor
        .toLowerCase()
        .replaceAll(RegExp('[áàäâã]'), 'a')
        .replaceAll(RegExp('[éèëê]'), 'e')
        .replaceAll(RegExp('[íìïî]'), 'i')
        .replaceAll(RegExp('[óòöôõ]'), 'o')
        .replaceAll(RegExp('[úùüû]'), 'u')
        .replaceAll('ñ', 'n');
  }
}
