import 'package:shared_preferences/shared_preferences.dart';

class PokemonLocalDataSource {
  static const String _favoritesKey = 'favorites';
  static const String _historyKey = 'history';
  static const int _maxHistoryItems = 20;

  final SharedPreferences sharedPreferences;

  PokemonLocalDataSource(this.sharedPreferences);

  Future<List<int>> getFavorites() async {
    final favorites = sharedPreferences.getStringList(_favoritesKey) ?? [];
    return favorites.map(int.parse).toList();
  }

  Future<void> setFavorites(List<int> favorites) async {
    await sharedPreferences.setStringList(
      _favoritesKey,
      favorites.map((e) => e.toString()).toList(),
    );
  }

  Future<List<int>> getHistory() async {
    final history = sharedPreferences.getStringList(_historyKey) ?? [];
    return history.map(int.parse).toList();
  }

  Future<void> setHistory(List<int> history) async {
    if (history.length > _maxHistoryItems) {
      history = history.sublist(history.length - _maxHistoryItems);
    }
    await sharedPreferences.setStringList(
      _historyKey,
      history.map((e) => e.toString()).toList(),
    );
  }

  Future<void> addToHistory(int id) async {
    final history = await getHistory();
    history.remove(id);
    history.add(id);
    await setHistory(history);
  }

  Future<void> toggleFavorite(int id) async {
    final favorites = await getFavorites();
    if (favorites.contains(id)) {
      favorites.remove(id);
    } else {
      favorites.add(id);
    }
    await setFavorites(favorites);
  }
}
