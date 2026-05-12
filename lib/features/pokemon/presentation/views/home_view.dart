import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/pokemon_providers.dart';
import '../widgets/pokemon_grid.dart';
import '../widgets/search_bar.dart';
import '../widgets/type_filter_chips.dart';
import '../widgets/empty_state.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/error_widget.dart';

class HomeView extends ConsumerStatefulWidget {
  final Function(int) onPokemonTap;

  const HomeView({super.key, required this.onPokemonTap});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredPokemons = ref.watch(filteredPokemonProvider);
    final favorites = ref.watch(favoritesProvider);
    final isLoadingMore = ref.watch(isLoadingMoreProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: SearchInput(
            controller: _searchController,
            onChanged: (value) {
              ref.read(searchQueryProvider.notifier).setQuery(value);
            },
            onClear: () {
              ref.read(searchQueryProvider.notifier).clear();
            },
          ),
        ),
        TypeFilterChips(
          selectedType: ref.watch(typeFilterProvider),
          onTypeSelected: (type) {
            ref.read(typeFilterProvider.notifier).setType(type);
          },
        ),
        const SizedBox(height: 8),
        Expanded(
          child: filteredPokemons.when(
            data: (pokemons) {
              if (pokemons.isEmpty) {
                return const EmptyState(
                  message: 'No Pokemon found.\nTry a different search or filter.',
                  icon: Icons.search_off,
                );
              }

              return favorites.when(
                data: (favoriteIds) => PokemonGrid(
                  pokemons: pokemons,
                  favoriteIds: favoriteIds,
                  onPokemonTap: (pokemon) => widget.onPokemonTap(pokemon.id),
                  onFavoriteToggle: (id) {
                    ref.read(favoritesProvider.notifier).toggleFavorite(id);
                  },
                  onLoadMore: () {
                    ref.read(pokemonListProvider.notifier).loadMore();
                  },
                  isLoading: isLoadingMore,
                ),
                loading: () => const LoadingIndicator(),
                error: (e, _) => ErrorDisplay(
                  message: e.toString(),
                  onRetry: () => ref.invalidate(favoritesProvider),
                ),
              );
            },
            loading: () => const ShimmerGrid(),
            error: (error, _) => ErrorDisplay(
              message: error.toString(),
              onRetry: () => ref.invalidate(pokemonListProvider),
            ),
          ),
        ),
      ],
    );
  }
}
