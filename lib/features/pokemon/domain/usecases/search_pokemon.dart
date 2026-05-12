import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/pokemon.dart';
import '../repositories/pokemon_repository.dart';

class SearchPokemon {
  final PokemonRepository repository;

  SearchPokemon(this.repository);

  Future<Either<Failure, List<Pokemon>>> call(String query) {
    return repository.searchPokemon(query);
  }
}
