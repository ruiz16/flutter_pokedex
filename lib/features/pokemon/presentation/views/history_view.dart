import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/pokemon_providers.dart';
import '../widgets/pokemon_card.dart';
import '../widgets/empty_state.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/error_widget.dart';

class HistoryView extends ConsumerWidget {
  final Function(int) onPokemonTap;

  const HistoryView({super.key, required this.onPokemonTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(historyProvider);
    final pokemonList = ref.watch(pokemonListProvider);

    return history.when(
      data: (historyIds) {
        if (historyIds.isEmpty) {
          return const EmptyState(
            message: 'No history yet.\nPokemon you view will appear here.',
            icon: Icons.history,
          );
        }

        return pokemonList.when(
          data: (allPokemons) {
            final historyPokemons = historyIds
                .map((id) => allPokemons.where((p) => p.id == id).firstOrNull)
                .where((p) => p != null)
                .toList();

            if (historyPokemons.isEmpty) {
              return const EmptyState(
                message: 'Loading history...',
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
              itemCount: historyPokemons.length,
              itemBuilder: (context, index) {
                final pokemon = historyPokemons[index]!;
                return PokemonCard(
                  pokemon: pokemon,
                  onTap: () => onPokemonTap(pokemon.id),
                );
              },
            );
          },
          loading: () => const LoadingIndicator(),
          error: (e, _) => ErrorDisplay(
            message: e.toString(),
            onRetry: () => ref.invalidate(pokemonListProvider),
          ),
        );
      },
      loading: () => const LoadingIndicator(),
      error: (e, _) => ErrorDisplay(
        message: e.toString(),
        onRetry: () => ref.invalidate(historyProvider),
      ),
    );
  }
}
