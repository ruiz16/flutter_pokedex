import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/pokemon_repository.dart';

class GetFavorites {
  final PokemonRepository repository;

  GetFavorites(this.repository);

  Future<Either<Failure, List<int>>> call() {
    return repository.getFavorites();
  }
}
