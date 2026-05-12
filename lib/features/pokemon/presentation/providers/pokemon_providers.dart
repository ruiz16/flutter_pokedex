import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/network/api_client.dart';
import '../../data/datasources/pokemon_local_datasource.dart';
import '../../data/datasources/pokemon_remote_datasource.dart';
import '../../data/repositories/pokemon_repository_impl.dart';
import '../../domain/entities/pokemon.dart';
import '../../domain/entities/pokemon_detail.dart';
import '../../domain/repositories/pokemon_repository.dart';
import '../../domain/usecases/get_favorites.dart';
import '../../domain/usecases/get_history.dart';
import '../../domain/usecases/get_pokemon_detail.dart';
import '../../domain/usecases/get_pokemon_list.dart';
import '../../domain/usecases/search_pokemon.dart';
import '../../domain/usecases/toggle_favorite.dart';
import '../../domain/usecases/add_to_history.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences not initialized');
});

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

final pokemonRemoteDataSourceProvider = Provider<PokemonRemoteDataSource>((ref) {
  return PokemonRemoteDataSource(ref.read(apiClientProvider));
});

final pokemonLocalDataSourceProvider = Provider<PokemonLocalDataSource>((ref) {
  return PokemonLocalDataSource(ref.read(sharedPreferencesProvider));
});

final pokemonRepositoryProvider = Provider<PokemonRepository>((ref) {
  return PokemonRepositoryImpl(
    remoteDataSource: ref.read(pokemonRemoteDataSourceProvider),
    localDataSource: ref.read(pokemonLocalDataSourceProvider),
  );
});

final getPokemonListUseCaseProvider = Provider<GetPokemonList>((ref) {
  return GetPokemonList(ref.read(pokemonRepositoryProvider));
});

final getPokemonDetailUseCaseProvider = Provider<GetPokemonDetail>((ref) {
  return GetPokemonDetail(ref.read(pokemonRepositoryProvider));
});

final searchPokemonUseCaseProvider = Provider<SearchPokemon>((ref) {
  return SearchPokemon(ref.read(pokemonRepositoryProvider));
});

final toggleFavoriteUseCaseProvider = Provider<ToggleFavorite>((ref) {
  return ToggleFavorite(ref.read(pokemonRepositoryProvider));
});

final getFavoritesUseCaseProvider = Provider<GetFavorites>((ref) {
  return GetFavorites(ref.read(pokemonRepositoryProvider));
});

final addToHistoryUseCaseProvider = Provider<AddToHistory>((ref) {
  return AddToHistory(ref.read(pokemonRepositoryProvider));
});

final getHistoryUseCaseProvider = Provider<GetHistory>((ref) {
  return GetHistory(ref.read(pokemonRepositoryProvider));
});

final searchQueryProvider = StateProvider<String>((ref) => '');

final typeFilterProvider = StateProvider<String?>((ref) => null);

final isLoadingMoreProvider = StateProvider<bool>((ref) => false);

final pokemonListNotifierProvider =
    AsyncNotifierProvider<PokemonListNotifier, List<Pokemon>>(
  PokemonListNotifier.new,
);

class PokemonListNotifier extends AsyncNotifier<List<Pokemon>> {
  @override
  Future<List<Pokemon>> build() async {
    return _fetchPokemonList(0);
  }

  Future<List<Pokemon>> _fetchPokemonList(int offset) async {
    final useCase = ref.read(getPokemonListUseCaseProvider);
    final result = await useCase.call(offset, 20);
    return result.fold(
      (failure) => throw Exception(failure.message),
      (pokemons) => pokemons,
    );
  }

  Future<void> loadMore() async {
    if (ref.read(isLoadingMoreProvider)) return;
    
    ref.read(isLoadingMoreProvider.notifier).state = true;

    final currentList = state.valueOrNull ?? [];
    final newPokemons = await _fetchPokemonList(currentList.length);
    ref.read(isLoadingMoreProvider.notifier).state = false;
    state = AsyncData([...currentList, ...newPokemons]);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchPokemonList(0));
  }
}

final pokemonDetailProvider =
    FutureProvider.family<PokemonDetail, int>((ref, id) async {
  final useCase = ref.read(getPokemonDetailUseCaseProvider);
  final result = await useCase.call(id);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (pokemon) => pokemon,
  );
});

final favoritesNotifierProvider =
    AsyncNotifierProvider<FavoritesNotifier, List<int>>(
  FavoritesNotifier.new,
);

class FavoritesNotifier extends AsyncNotifier<List<int>> {
  @override
  Future<List<int>> build() async {
    final useCase = ref.read(getFavoritesUseCaseProvider);
    final result = await useCase.call();
    return result.fold(
      (failure) => throw Exception(failure.message),
      (favorites) => favorites,
    );
  }

  Future<void> toggleFavorite(int id) async {
    final useCase = ref.read(toggleFavoriteUseCaseProvider);
    await useCase.call(id);
    ref.invalidateSelf();
  }
}

final historyNotifierProvider =
    AsyncNotifierProvider<HistoryNotifier, List<int>>(
  HistoryNotifier.new,
);

class HistoryNotifier extends AsyncNotifier<List<int>> {
  @override
  Future<List<int>> build() async {
    final useCase = ref.read(getHistoryUseCaseProvider);
    final result = await useCase.call();
    return result.fold(
      (failure) => throw Exception(failure.message),
      (history) => history.reversed.toList(),
    );
  }

  Future<void> addToHistory(int id) async {
    final useCase = ref.read(addToHistoryUseCaseProvider);
    await useCase.call(id);
    ref.invalidateSelf();
  }
}

final filteredPokemonProvider = Provider<AsyncValue<List<Pokemon>>>((ref) {
  final listState = ref.watch(pokemonListNotifierProvider);
  final searchQuery = ref.watch(searchQueryProvider);
  final typeFilter = ref.watch(typeFilterProvider);

  return listState.whenData((pokemons) {
    var filtered = pokemons;

    if (searchQuery.isNotEmpty) {
      filtered = filtered
          .where((p) => p.name.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    }

    if (typeFilter != null) {
      filtered = filtered
          .where((p) => p.types.any(
              (t) => t.name.toLowerCase() == typeFilter.toLowerCase()))
          .toList();
    }

    return filtered;
  });
});
