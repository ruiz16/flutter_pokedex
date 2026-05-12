import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/pokemon_providers.dart';
import '../widgets/stat_bar.dart';
import '../widgets/pokemon_card.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/error_widget.dart';

class PokemonDetailView extends ConsumerWidget {
  final int pokemonId;

  const PokemonDetailView({super.key, required this.pokemonId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pokemonAsync = ref.watch(pokemonDetailProvider(pokemonId));
    final isFavorite = ref.watch(favoritesProvider).value?.contains(pokemonId) ?? false;

    ref.listen(pokemonDetailProvider(pokemonId), (prev, next) {
      next.whenData((_) => ref.read(historyProvider.notifier).add(pokemonId));
    });

    return Scaffold(
      body: pokemonAsync.when(
        data: (pokemon) {
          final primaryType = pokemon.types.isNotEmpty ? pokemon.types.first : null;
          final backgroundColor = primaryType != null
              ? primaryType.color.withAlpha(51)
              : Colors.grey.shade100;

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => context.pop(),
                ),
                backgroundColor: primaryType?.color ?? Theme.of(context).primaryColor,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          (primaryType?.color ?? Theme.of(context).primaryColor)
                              .withAlpha(128),
                          backgroundColor,
                        ],
                      ),
                    ),
                    child: SafeArea(
                      child: Hero(
                        tag: 'pokemon-${pokemon.id}',
                        child: CachedNetworkImage(
                          imageUrl: pokemon.imageUrl,
                          fit: BoxFit.contain,
                          height: 250,
                        ),
                      ),
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : Colors.white,
                    ),
                    onPressed: () {
                      ref.read(favoritesProvider.notifier).toggleFavorite(pokemon.id);
                    },
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Column(
                          children: [
                            Text(
                              '#${pokemon.id.toString().padLeft(3, '0')}',
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: Colors.grey,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              pokemon.name[0].toUpperCase() + pokemon.name.substring(1),
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              children: pokemon.types.map((type) {
                                return TypeChip(type: type);
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _InfoColumn(
                            label: 'Height',
                            value: pokemon.formattedHeight,
                          ),
                          _InfoColumn(
                            label: 'Weight',
                            value: pokemon.formattedWeight,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Base Stats',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      ...pokemon.stats.map((stat) => StatBar(
                            stat: stat,
                            color: primaryType?.color ?? Colors.grey,
                          )),
                      const SizedBox(height: 24),
                      Text(
                        'Abilities',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: pokemon.abilities.map((ability) {
                          return Chip(
                            label: Text(
                              ability.name[0].toUpperCase() +
                                  ability.name.substring(1) +
                                  (ability.isHidden ? ' (Hidden)' : ''),
                              style: TextStyle(
                                fontSize: 12,
                                color: ability.isHidden ? Colors.grey : null,
                              ),
                            ),
                            backgroundColor: ability.isHidden
                                ? Colors.grey.shade200
                                : primaryType?.color.withAlpha(51),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const LoadingIndicator(message: 'Loading Pokemon details...'),
        error: (error, _) => ErrorDisplay(
          message: error.toString(),
          onRetry: () => ref.invalidate(pokemonDetailProvider(pokemonId)),
        ),
      ),
    );
  }
}

class _InfoColumn extends StatelessWidget {
  final String label;
  final String value;

  const _InfoColumn({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Colors.grey,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }
}