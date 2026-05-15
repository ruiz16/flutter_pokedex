import 'package:shared_preferences/shared_preferences.dart';

class PokemonLocalDataSource {
  static const String _favoritesKey = 'favorites';
  static const String _historyKey = 'history';

  final SharedPreferences sharedPreferences;
  PokemonLocalDataSource(this.sharedPreferences);

  List<int> getFavorites() {
    final favorites = sharedPreferences.getStringList(_favoritesKey) ?? [];
    return favorites.map(int.parse).toList();
  }

  void setFavorites(List<int> favorites) {
    sharedPreferences.setStringList(
      _favoritesKey,
      favorites.map((e) => e.toString()).toList(),
    );
  }

  List<int> getHistory() {
    final history = sharedPreferences.getStringList(_historyKey) ?? [];
    return history.map(int.parse).toList();
  }

  void setHistory(List<int> history) {
    sharedPreferences.setStringList(
      _historyKey,
      history.map((e) => e.toString()).toList(),
    );
  }

  void addToHistory(int id) {
    final history = getHistory();
    if (!history.contains(id)) {
      history.add(id);
    }
    setHistory(history);
  }
}
