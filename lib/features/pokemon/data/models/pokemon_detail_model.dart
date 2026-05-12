import '../../domain/entities/pokemon_detail.dart';
import '../../domain/entities/pokemon_type.dart';

class StatModel extends Stat {
  const StatModel({
    required super.name,
    required super.value,
  });

  factory StatModel.fromJson(Map<String, dynamic> json) {
    final statName = _formatStatName(json['stat']['name'] as String);
    final value = json['base_stat'] as int;
    return StatModel(name: statName, value: value);
  }

  static String _formatStatName(String name) {
    switch (name) {
      case 'hp':
        return 'HP';
      case 'attack':
        return 'Attack';
      case 'defense':
        return 'Defense';
      case 'special-attack':
        return 'Sp. Atk';
      case 'special-defense':
        return 'Sp. Def';
      case 'speed':
        return 'Speed';
      default:
        return name;
    }
  }
}

class AbilityModel extends Ability {
  const AbilityModel({
    required super.name,
    required super.isHidden,
  });

  factory AbilityModel.fromJson(Map<String, dynamic> json) {
    final abilityName = (json['ability']['name'] as String).replaceAll('-', ' ');
    return AbilityModel(
      name: abilityName,
      isHidden: json['is_hidden'] as bool,
    );
  }
}

class PokemonDetailModel extends PokemonDetail {
  const PokemonDetailModel({
    required super.id,
    required super.name,
    required super.imageUrl,
    required super.types,
    required super.height,
    required super.weight,
    required super.stats,
    required super.abilities,
    required super.speciesUrl,
  });

  factory PokemonDetailModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as int;
    final imageUrl =
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';

    final types = (json['types'] as List).map((typeData) {
      final typeName = typeData['type']['name'] as String;
      return PokemonType(
        name: typeName,
        color: PokemonType.getColor(typeName),
      );
    }).toList();

    final stats = (json['stats'] as List)
        .map((statData) => StatModel.fromJson(statData as Map<String, dynamic>))
        .toList();

    final abilities = (json['abilities'] as List)
        .map((abilityData) => AbilityModel.fromJson(abilityData as Map<String, dynamic>))
        .toList();

    final speciesUrl = json['species']['url'] as String;

    return PokemonDetailModel(
      id: id,
      name: json['name'] as String,
      imageUrl: imageUrl,
      types: types,
      height: json['height'] as int,
      weight: json['weight'] as int,
      stats: stats,
      abilities: abilities,
      speciesUrl: speciesUrl,
    );
  }
}
