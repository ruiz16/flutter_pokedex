import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/pokemon_providers.dart';
import '../widgets/pokemon_grid.dart';
import '../widgets/empty_state.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/error_widget.dart';

class FavoritesView extends ConsumerWidget {
  const FavoritesView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritePokemons = ref.watch(favoritePokemonsProvider);

    return favoritePokemons.when(
      data: (pokemons) {
        if (pokemons.isEmpty) {
          return const EmptyState(
            message: 'No favorites yet.\nStart adding Pokemon to your favorites!',
            icon: Icons.favorite_outline,
          );
        }

        return PokemonGrid(
          pokemons: pokemons,
          favoriteIds: pokemons.map((p) => p.id).toList(),
          onPokemonTap: (pokemon) => context.push('/pokemon/${pokemon.id}'),
          onFavoriteToggle: (id) => ref.read(favoritesProvider.notifier).toggle(id),
        );
      },
      loading: () => const LoadingIndicator(),
      error: (error, _) => ErrorDisplay(
        message: error.toString(),
        onRetry: () => ref.invalidate(favoritesProvider),
      ),
    );
  }
}