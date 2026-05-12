import 'package:equatable/equatable.dart';
import 'pokemon.dart';

class Stat extends Equatable {
  final String name;
  final int value;

  const Stat({
    required this.name,
    required this.value,
  });

  @override
  List<Object?> get props => [name, value];
}

class Ability extends Equatable {
  final String name;
  final bool isHidden;

  const Ability({
    required this.name,
    required this.isHidden,
  });

  @override
  List<Object?> get props => [name, isHidden];
}

class PokemonDetail extends Pokemon {
  final int height;
  final int weight;
  final List<Stat> stats;
  final List<Ability> abilities;
  final String speciesUrl;

  const PokemonDetail({
    required super.id,
    required super.name,
    required super.imageUrl,
    required super.types,
    required this.height,
    required this.weight,
    required this.stats,
    required this.abilities,
    required this.speciesUrl,
  });

  String get formattedHeight => '${(height / 10).toStringAsFixed(1)}m';
  String get formattedWeight => '${(weight / 10).toStringAsFixed(1)}kg';

  @override
  List<Object?> get props => [
        ...super.props,
        height,
        weight,
        stats,
        abilities,
        speciesUrl,
      ];
}
