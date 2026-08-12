/// Convierte `#RRGGBB` o `#AARRGGBB` en un entero ARGB.
///
/// Devuelve null ante cualquier otra cosa para que quien llama decida el
/// respaldo. Sin `#` también vale: es el error de tipeo más común al editar el
/// JSON a mano.
int? parseArgb(String? hex) {
  if (hex == null) return null;
  final String clean = hex.trim().replaceFirst('#', '').toUpperCase();
  if (clean.length != 6 && clean.length != 8) return null;
  final int? value = int.tryParse(clean, radix: 16);
  if (value == null) return null;
  return clean.length == 6 ? 0xFF000000 | value : value;
}
