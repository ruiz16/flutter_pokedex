import 'package:equatable/equatable.dart';
import 'pokemon_type.dart';

class Pokemon extends Equatable {
  final int id;
  final String name;
  final String imageUrl;
  final List<PokemonType> types;

  const Pokemon({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.types,
  });

  @override
  List<Object?> get props => [id, name, imageUrl, types];
}
