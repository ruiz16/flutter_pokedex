import '../../domain/entities/pokemon.dart';
import '../../domain/entities/pokemon_type.dart';

class PokemonModel extends Pokemon {
  const PokemonModel({
    required super.id,
    required super.name,
    required super.imageUrl,
    required super.types,
  });

  factory PokemonModel.fromJson(Map<String, dynamic> json) {
    final types = (json['types'] as List).map((typeData) {
      final typeName = typeData['type']['name'] as String;
      return PokemonType(
        name: typeName,
        color: PokemonType.getColor(typeName),
      );
    }).toList();

    final id = json['id'] as int;
    final imageUrl =
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';

    return PokemonModel(
      id: id,
      name: json['name'] as String,
      imageUrl: imageUrl,
      types: types,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'types': types.map((t) => {'name': t.name, 'color': t.color.toARGB32()}).toList(),
    };
  }
}
