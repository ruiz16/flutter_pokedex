// lib/features/pokemon/presentation/providers/pokemon_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/network/api_client.dart';
import '../../data/datasources/pokemon_local_datasource.dart';
import '../../data/datasources/pokemon_remote_datasource.dart';
import '../../data/models/pokemon_model.dart';
import '../../data/models/pokemon_detail_model.dart';

// ═══════════════════════════════════════════════════════════════════
// DEPENDENCY PROVIDERS (inline, simples)
// ═══════════════════════════════════════════════════════════════════

final sharedPrefsProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences not initialized');
});

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final pokemonRemoteProvider = Provider<PokemonRemoteDataSource>((ref) {
  return PokemonRemoteDataSource(ref.read(apiClientProvider));
});

final pokemonLocalProvider = Provider<PokemonLocalDataSource>((ref) {
  return PokemonLocalDataSource(ref.read(sharedPrefsProvider));
});

// ═══════════════════════════════════════════════════════════════════
// UI STATE PROVIDERS (Notifier moderno)
// ═══════════════════════════════════════════════════════════════════

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(
  SearchQueryNotifier.new,
);

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String query) => state = query;
}

final typeFilterProvider = NotifierProvider<TypeFilterNotifier, String?>(
  TypeFilterNotifier.new,
);

class TypeFilterNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void setType(String? type) => state = type;
}

final isLoadingMoreProvider = NotifierProvider<IsLoadingMoreNotifier, bool>(
  IsLoadingMoreNotifier.new,
);

class IsLoadingMoreNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void setLoading(bool loading) => state = loading;
}

// ═══════════════════════════════════════════════════════════════════
// DATA PROVIDERS (AsyncNotifier - lógica de negocio)
// ═══════════════════════════════════════════════════════════════════

final pokemonListProvider =
    AsyncNotifierProvider<PokemonListNotifier, List<PokemonModel>>(
      PokemonListNotifier.new,
    );

class PokemonListNotifier extends AsyncNotifier<List<PokemonModel>> {
  @override
  Future<List<PokemonModel>> build() async {
    return _fetch(0);
  }

  Future<List<PokemonModel>> _fetch(int offset) async {
    final remote = ref.read(pokemonRemoteProvider);
    return remote.getPokemonList(offset, 20);
  }

  Future<void> loadMore() async {
    if (ref.read(isLoadingMoreProvider)) return;

    final current = state.value ?? [];
    ref.read(isLoadingMoreProvider.notifier).setLoading(true);

    try {
      final newPokemons = await _fetch(current.length);
      state = AsyncData([...current, ...newPokemons]);
    } finally {
      ref.read(isLoadingMoreProvider.notifier).setLoading(false);
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetch(0));
  }
}

final pokemonDetailProvider = FutureProvider.family<PokemonDetailModel, int>((
  ref,
  id,
) async {
  final remote = ref.read(pokemonRemoteProvider);
  return remote.getPokemonDetail(id);
});

class FavoritesNotifier extends Notifier<List<int>> {
  @override
  List<int> build() {
    final local = ref.read(pokemonLocalProvider);
    return local.getFavorites();
  }

  void toggleFavorite(int id) {
    final local = ref.read(pokemonLocalProvider);
    List<int> favorites = [...state];
    favorites.contains(id) ? favorites.remove(id) : favorites.add(id);
    local.setFavorites(favorites);
    state = favorites;
  }
}

final favoritesProvider = NotifierProvider<FavoritesNotifier, List<int>>(
  FavoritesNotifier.new,
);

final historyProvider = Provider((ref) {
  final local = ref.read(pokemonLocalProvider);
  return local.getHistory().reversed.toList();
});

class HistoryNotifier extends Notifier<List<int>> {
  @override
  List<int> build() {
    final local = ref.read(pokemonLocalProvider);
    return local.getHistory().reversed.toList();
  }

  void add(int id) {
    final local = ref.read(pokemonLocalProvider);
    local.addToHistory(id);
    state = [...state, id];
  }
}

// ═══════════════════════════════════════════════════════════════════
// FILTERED POKEMON PROVIDER (con paginación)
// ═══════════════════════════════════════════════════════════════════

final filteredPokemonProvider =
    AsyncNotifierProvider<FilteredPokemonNotifier, List<PokemonModel>>(
      FilteredPokemonNotifier.new,
    );

class FilteredPokemonNotifier extends AsyncNotifier<List<PokemonModel>> {
  @override
  Future<List<PokemonModel>> build() async {
    return _fetch(0);
  }

  Future<List<PokemonModel>> _fetch(int offset) async {
    final typeFilter = ref.watch(typeFilterProvider);
    final query = ref.watch(searchQueryProvider).toLowerCase();

    // Primero buscar en local
    final localPokemons = await ref.watch(pokemonListProvider.future);

    // Si hay filtro de tipo: SIEMPRE buscar en API (no en local)
    if (typeFilter != null) {
      final remote = ref.read(pokemonRemoteProvider);
      var apiPokemons = await remote.getPokemonByType(
        typeFilter.toLowerCase(),
        offset: offset,
        limit: 20,
      );

      // Filtrar por query si existe
      if (query.isNotEmpty) {
        apiPokemons = apiPokemons
            .where((p) => p.name.toLowerCase().contains(query))
            .toList();
      }

      return apiPokemons;
    }

    // Sin filtro de tipo: buscar en local por nombre
    if (query.isNotEmpty) {
      // Buscar en local
      final localFiltered = localPokemons
          .where((p) => p.name.toLowerCase().contains(query))
          .toList();

      if (localFiltered.isNotEmpty) {
        return localFiltered;
      }

      // Si no está en local, buscar en API por nombre
      try {
        final remote = ref.read(pokemonRemoteProvider);
        final detail = await remote.getPokemonByName(query);
        return [PokemonModel.fromDetail(detail)];
      } catch (e) {
        // Si no existe en API, retornar lista vacía
        return [];
      }
    }

    // Sin query y sin filtro: retornar lista local
    return localPokemons;
  }

  Future<void> loadMore() async {
    final typeFilter = ref.watch(typeFilterProvider);
    if (typeFilter == null) {
      // Sin filtro, delegar al provider principal
      await ref.read(pokemonListProvider.notifier).loadMore();
      return;
    }

    if (ref.read(isLoadingMoreProvider)) return;

    final current = state.value ?? [];
    ref.read(isLoadingMoreProvider.notifier).setLoading(true);

    try {
      final newPokemons = await _fetch(current.length);
      // Agregar solo los nuevos (evitar duplicados si la API devuelve overlaps)
      final existingIds = current.map((p) => p.id).toSet();
      final uniqueNew = newPokemons
          .where((p) => !existingIds.contains(p.id))
          .toList();
      state = AsyncData([...current, ...uniqueNew]);
    } finally {
      ref.read(isLoadingMoreProvider.notifier).setLoading(false);
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetch(0));
  }
}

// ═══════════════════════════════════════════════════════════════════
// FAVORITES/HISTORY POKEMON PROVIDERS (para mostrar pokemon completo)
// ═══════════════════════════════════════════════════════════════════

final favoritePokemonsProvider = FutureProvider<List<PokemonModel>>((
  ref,
) async {
  final favoriteIds = ref.watch(favoritesProvider);
  final list = await ref.watch(pokemonListProvider.future);
  return list.where((p) => favoriteIds.contains(p.id)).toList();
});

final historyPokemonsProvider = FutureProvider<List<PokemonModel>>((ref) async {
  final historyIds = ref.watch(historyProvider);
  final list = await ref.watch(pokemonListProvider.future);
  // Maintain order from history
  final result = <PokemonModel>[];
  for (final id in historyIds) {
    final pokemon = list.where((p) => p.id == id).firstOrNull;
    if (pokemon != null) result.add(pokemon);
  }
  return result;
});
