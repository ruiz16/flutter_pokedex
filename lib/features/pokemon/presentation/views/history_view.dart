import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/pokemon_providers.dart';
import '../widgets/pokemon_grid.dart';
import '../widgets/empty_state.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/error_widget.dart';

class HistoryView extends ConsumerWidget {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyPokemons = ref.watch(historyPokemonsProvider);

    return historyPokemons.when(
      data: (pokemons) {
        if (pokemons.isEmpty) {
          return const EmptyState(
            message: 'No history yet.\nStart exploring Pokemon!',
            icon: Icons.history,
          );
        }

        final favoriteIds = ref.watch(favoritesProvider);

        return PokemonGrid(
          pokemons: pokemons,
          favoriteIds: favoriteIds,
          onPokemonTap: (pokemon) => context.push('/pokemon/${pokemon.id}'),
          onFavoriteToggle: (id) =>
              ref.read(favoritesProvider.notifier).toggleFavorite(id),
        );
      },
      loading: () => const LoadingIndicator(),
      error: (error, _) => ErrorDisplay(
        message: error.toString(),
        onRetry: () => ref.invalidate(historyProvider),
      ),
    );
  }
}
