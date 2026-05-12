import 'package:flutter/material.dart';
import '../../domain/entities/pokemon_type.dart' as pt;

class TypeFilterChips extends StatelessWidget {
  final String? selectedType;
  final ValueChanged<String?> onTypeSelected;

  const TypeFilterChips({
    super.key,
    required this.selectedType,
    required this.onTypeSelected,
  });

  static const List<String> allTypes = [
    'normal',
    'fire',
    'water',
    'electric',
    'grass',
    'ice',
    'fighting',
    'poison',
    'ground',
    'flying',
    'psychic',
    'bug',
    'rock',
    'ghost',
    'dragon',
    'dark',
    'steel',
    'fairy',
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: allTypes.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: const Text('All'),
                selected: selectedType == null,
                onSelected: (_) => onTypeSelected(null),
              ),
            );
          }

          final type = allTypes[index - 1];
          final typeColor = pt.PokemonType.getColor(type);

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(
                type[0].toUpperCase() + type.substring(1),
                style: TextStyle(
                  color: selectedType == type ? Colors.white : Colors.black,
                  fontSize: 12,
                ),
              ),
              selected: selectedType == type,
              selectedColor: typeColor,
              backgroundColor: typeColor.withAlpha(51),
              onSelected: (_) => onTypeSelected(
                selectedType == type ? null : type,
              ),
            ),
          );
        },
      ),
    );
  }
}
