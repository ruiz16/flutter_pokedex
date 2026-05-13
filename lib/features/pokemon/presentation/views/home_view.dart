import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/pokemon_providers.dart';
import '../widgets/pokemon_grid.dart';
import '../widgets/search_bar.dart';
import '../widgets/type_filter_chips.dart';
import '../widgets/empty_state.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/error_widget.dart';

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredPokemons = ref.watch(filteredPokemonProvider);
    final isLoadingMore = ref.watch(isLoadingMoreProvider);
    final favoriteIds = ref.watch(favoritesProvider).value ?? [];
    final hasTypeFilter = ref.watch(typeFilterProvider) != null;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: SearchInput(
            onChanged: (value) {
              ref.read(searchQueryProvider.notifier).setQuery(value);
            },
            onClear: () {
              ref.read(searchQueryProvider.notifier).setQuery('');
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
                  message:
                      'No Pokemon found.\nTry a different search or filter.',
                  icon: Icons.search_off,
                );
              }

              return PokemonGrid(
                pokemons: pokemons,
                favoriteIds: favoriteIds,
                onPokemonTap: (pokemon) =>
                    context.push('/pokemon/${pokemon.id}'),
                onFavoriteToggle: (id) =>
                    ref.read(favoritesProvider.notifier).toggle(id),
                onLoadMore: hasTypeFilter
                    ? () =>
                          ref.read(filteredPokemonProvider.notifier).loadMore()
                    : () => ref.read(pokemonListProvider.notifier).loadMore(),
                isLoading: isLoadingMore,
              );
            },
            loading: () => const LoadingIndicator(),
            error: (error, _) => ErrorDisplay(
              message: error.toString(),
              onRetry: () => ref.invalidate(filteredPokemonProvider),
            ),
          ),
        ),
      ],
    );
  }
}
