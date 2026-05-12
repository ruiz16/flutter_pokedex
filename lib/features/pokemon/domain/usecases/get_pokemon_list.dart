import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/pokemon.dart';
import '../repositories/pokemon_repository.dart';

class GetPokemonList {
  final PokemonRepository repository;

  GetPokemonList(this.repository);

  Future<Either<Failure, List<Pokemon>>> call(int offset, int limit) {
    return repository.getPokemonList(offset, limit);
  }
}
