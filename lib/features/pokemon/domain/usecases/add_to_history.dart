import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/pokemon_repository.dart';

class AddToHistory {
  final PokemonRepository repository;

  AddToHistory(this.repository);

  Future<Either<Failure, void>> call(int id) {
    return repository.addToHistory(id);
  }
}
