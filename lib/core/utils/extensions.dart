extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  String toPokemonId() {
    return padLeft(3, '0');
  }
}

extension ColorExtension on int {
  String toHexString() {
    return '#${toRadixString(16).padLeft(6, '0').toUpperCase()}';
  }
}
