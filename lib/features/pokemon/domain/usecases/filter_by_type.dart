import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/pokemon.dart';
import '../repositories/pokemon_repository.dart';

class FilterByType {
  final PokemonRepository repository;

  FilterByType(this.repository);

  Future<Either<Failure, List<Pokemon>>> call(String type) {
    return repository.filterByType(type);
  }
}
