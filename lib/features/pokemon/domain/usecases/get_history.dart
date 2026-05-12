import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/pokemon_repository.dart';

class GetHistory {
  final PokemonRepository repository;

  GetHistory(this.repository);

  Future<Either<Failure, List<int>>> call() {
    return repository.getHistory();
  }
}
