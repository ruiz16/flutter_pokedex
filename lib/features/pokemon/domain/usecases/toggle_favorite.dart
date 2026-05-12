import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/pokemon_repository.dart';

class ToggleFavorite {
  final PokemonRepository repository;

  ToggleFavorite(this.repository);

  Future<Either<Failure, void>> call(int id) {
    return repository.toggleFavorite(id);
  }
}
