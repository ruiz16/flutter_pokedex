import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/entities/pokemon.dart';
import '../../domain/entities/pokemon_type.dart' as pt;

class PokemonCard extends StatelessWidget {
  final Pokemon pokemon;
  final VoidCallback onTap;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;

  const PokemonCard({
    super.key,
    required this.pokemon,
    required this.onTap,
    this.isFavorite = false,
    this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    final primaryType = pokemon.types.isNotEmpty ? pokemon.types.first : null;
    final backgroundColor = primaryType != null
        ? pt.PokemonType.getColor(primaryType.name).withAlpha(51)
        : Colors.grey.shade100;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(26),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Hero(
                      tag: 'pokemon-${pokemon.id}',
                      child: CachedNetworkImage(
                        imageUrl: pokemon.imageUrl,
                        fit: BoxFit.contain,
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        errorWidget: (context, url, error) => const Icon(
                          Icons.error,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '#${pokemon.id.toString().padLeft(3, '0')}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.grey,
                          fontSize: 10,
                        ),
                  ),
                  const SizedBox(height: 0),
                  Text(
                    pokemon.name[0].toUpperCase() + pokemon.name.substring(1),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 2,
                    runSpacing: 2,
                    children: pokemon.types.map((type) {
                      return TypeChip(type: type, small: true);
                    }).toList(),
                  ),
                ],
              ),
            ),
            if (onFavoriteToggle != null)
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: onFavoriteToggle,
                  child: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : Colors.grey,
                    size: 24,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class TypeChip extends StatelessWidget {
  final pt.PokemonType type;
  final bool small;

  const TypeChip({
    super.key,
    required this.type,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 6 : 10,
        vertical: small ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: type.color.withAlpha(204),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        type.name[0].toUpperCase() + type.name.substring(1),
        style: TextStyle(
          color: Colors.white,
          fontSize: small ? 9 : 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
