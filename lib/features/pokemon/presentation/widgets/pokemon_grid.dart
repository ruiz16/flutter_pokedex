import 'package:flutter/material.dart';
import '../../domain/entities/pokemon.dart';
import 'pokemon_card.dart';

class PokemonGrid extends StatelessWidget {
  final List<Pokemon> pokemons;
  final List<int> favoriteIds;
  final Function(Pokemon) onPokemonTap;
  final Function(int) onFavoriteToggle;
  final VoidCallback? onLoadMore;
  final bool isLoading;

  const PokemonGrid({
    super.key,
    required this.pokemons,
    required this.favoriteIds,
    required this.onPokemonTap,
    required this.onFavoriteToggle,
    this.onLoadMore,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        NotificationListener<ScrollNotification>(
          onNotification: (scrollInfo) {
            if (scrollInfo.metrics.pixels >=
                    scrollInfo.metrics.maxScrollExtent - 200 &&
                !isLoading &&
                onLoadMore != null) {
              onLoadMore?.call();
            }
            return false;
          },
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 60),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.75,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: pokemons.length,
            itemBuilder: (context, index) {
              final pokemon = pokemons[index];
              return PokemonCard(
                pokemon: pokemon,
                onTap: () => onPokemonTap(pokemon),
                isFavorite: favoriteIds.contains(pokemon.id),
                onFavoriteToggle: () => onFavoriteToggle(pokemon.id),
              );
            },
          ),
        ),
        if (isLoading)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.grey.shade100.withAlpha(0),
                    Colors.grey.shade100,
                  ],
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 12),
                  Text('Loading more...'),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
