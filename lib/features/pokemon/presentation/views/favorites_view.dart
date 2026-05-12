import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/pokemon_providers.dart';
import '../widgets/pokemon_card.dart';
import '../widgets/empty_state.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/error_widget.dart';

class FavoritesView extends ConsumerWidget {
  final Function(int) onPokemonTap;

  const FavoritesView({super.key, required this.onPokemonTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesNotifierProvider);
    final pokemonList = ref.watch(pokemonListNotifierProvider);

    return favorites.when(
      data: (favoriteIds) {
        if (favoriteIds.isEmpty) {
          return const EmptyState(
            message: 'No favorites yet.\nTap the heart icon on Pokemon to add them here.',
            icon: Icons.favorite_border,
          );
        }

        return pokemonList.when(
          data: (allPokemons) {
            final favoritePokemons = allPokemons
                .where((p) => favoriteIds.contains(p.id))
                .toList();

            if (favoritePokemons.isEmpty) {
              return const EmptyState(
                message: 'Loading favorites...',
                icon: Icons.hourglass_empty,
              );
            }

            return GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.75,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: favoritePokemons.length,
              itemBuilder: (context, index) {
                final pokemon = favoritePokemons[index];
                return PokemonCard(
                  pokemon: pokemon,
                  onTap: () => onPokemonTap(pokemon.id),
                  isFavorite: true,
                  onFavoriteToggle: () {
                    ref
                        .read(favoritesNotifierProvider.notifier)
                        .toggleFavorite(pokemon.id);
                  },
                );
              },
            );
          },
          loading: () => const LoadingIndicator(),
          error: (e, _) => ErrorDisplay(
            message: e.toString(),
            onRetry: () => ref.refresh(pokemonListNotifierProvider),
          ),
        );
      },
      loading: () => const LoadingIndicator(),
      error: (e, _) => ErrorDisplay(
        message: e.toString(),
        onRetry: () => ref.refresh(favoritesNotifierProvider),
      ),
    );
  }
}
