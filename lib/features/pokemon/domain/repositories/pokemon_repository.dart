import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/pokemon.dart';
import '../entities/pokemon_detail.dart';

abstract class PokemonRepository {
  Future<Either<Failure, List<Pokemon>>> getPokemonList(int offset, int limit);
  Future<Either<Failure, PokemonDetail>> getPokemonDetail(int id);
  Future<Either<Failure, List<Pokemon>>> searchPokemon(String query);
  Future<Either<Failure, List<Pokemon>>> filterByType(String type);
  Future<Either<Failure, List<int>>> getFavorites();
  Future<Either<Failure, void>> toggleFavorite(int id);
  Future<Either<Failure, List<int>>> getHistory();
  Future<Either<Failure, void>> addToHistory(int id);
}
