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

final favoritesProvider = AsyncNotifierProvider<FavoritesNotifier, List<int>>(
  FavoritesNotifier.new,
);

class FavoritesNotifier extends AsyncNotifier<List<int>> {
  @override
  Future<List<int>> build() async {
    final local = ref.read(pokemonLocalProvider);
    return local.getFavorites();
  }

  Future<void> toggle(int id) async {
    final local = ref.read(pokemonLocalProvider);
    await local.toggleFavorite(id);
    ref.invalidateSelf();
  }
}

final historyProvider = AsyncNotifierProvider<HistoryNotifier, List<int>>(
  HistoryNotifier.new,
);

class HistoryNotifier extends AsyncNotifier<List<int>> {
  @override
  Future<List<int>> build() async {
    final local = ref.read(pokemonLocalProvider);
    return (await local.getHistory()).reversed.toList();
  }

  Future<void> add(int id) async {
    final local = ref.read(pokemonLocalProvider);
    await local.addToHistory(id);
    ref.invalidateSelf();
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

    if (typeFilter != null) {
      // Con filtro: buscar en API con paginación
      final remote = ref.read(pokemonRemoteProvider);
      var pokemons = await remote.getPokemonByType(
        typeFilter.toLowerCase(),
        offset: offset,
        limit: 20,
      );

      // Filtrar por query localmente
      if (query.isNotEmpty) {
        pokemons = pokemons
            .where((p) => p.name.toLowerCase().contains(query))
            .toList();
      }

      return pokemons;
    } else {
      // Sin filtro: usar lista local (ya tiene loadMore)
      final pokemons = ref.read(pokemonListProvider).value ?? [];
      if (query.isEmpty) return pokemons;
      return pokemons
          .where((p) => p.name.toLowerCase().contains(query))
          .toList();
    }
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
  final favoriteIds = await ref.watch(favoritesProvider.future);
  final list = await ref.watch(pokemonListProvider.future);
  return list.where((p) => favoriteIds.contains(p.id)).toList();
});

final historyPokemonsProvider = FutureProvider<List<PokemonModel>>((ref) async {
  final historyIds = await ref.watch(historyProvider.future);
  final list = await ref.watch(pokemonListProvider.future);
  // Maintain order from history
  final result = <PokemonModel>[];
  for (final id in historyIds) {
    final pokemon = list.where((p) => p.id == id).firstOrNull;
    if (pokemon != null) result.add(pokemon);
  }
  return result;
});
