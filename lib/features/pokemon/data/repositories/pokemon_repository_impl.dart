import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/pokemon.dart';
import '../../domain/entities/pokemon_detail.dart';
import '../../domain/repositories/pokemon_repository.dart';
import '../datasources/pokemon_local_datasource.dart';
import '../datasources/pokemon_remote_datasource.dart';

class PokemonRepositoryImpl implements PokemonRepository {
  final PokemonRemoteDataSource remoteDataSource;
  final PokemonLocalDataSource localDataSource;

  PokemonRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<Pokemon>>> getPokemonList(int offset, int limit) async {
    try {
      final pokemons = await remoteDataSource.getPokemonList(offset, limit);
      return Right(pokemons);
    } catch (e) {
      return const Left(ServerFailure('Failed to load Pokemon list'));
    }
  }

  @override
  Future<Either<Failure, PokemonDetail>> getPokemonDetail(int id) async {
    try {
      final pokemon = await remoteDataSource.getPokemonDetail(id);
      return Right(pokemon);
    } catch (e) {
      return const Left(ServerFailure('Failed to load Pokemon detail'));
    }
  }

  @override
  Future<Either<Failure, List<Pokemon>>> searchPokemon(String query) async {
    try {
      final pokemon = await remoteDataSource.getPokemonByName(query.toLowerCase());
      return Right([pokemon]);
    } catch (e) {
      return const Left(NotFoundFailure('Pokemon not found'));
    }
  }

  @override
  Future<Either<Failure, List<Pokemon>>> filterByType(String type) async {
    try {
      final response = await remoteDataSource.getPokemonList(0, 151);
      final filtered = response.where((p) => 
        p.types.any((t) => t.name.toLowerCase() == type.toLowerCase())
      ).toList();
      return Right(filtered);
    } catch (e) {
      return const Left(ServerFailure('Failed to filter by type'));
    }
  }

  @override
  Future<Either<Failure, List<int>>> getFavorites() async {
    try {
      final favorites = await localDataSource.getFavorites();
      return Right(favorites);
    } catch (e) {
      return const Left(CacheFailure('Failed to load favorites'));
    }
  }

  @override
  Future<Either<Failure, void>> toggleFavorite(int id) async {
    try {
      await localDataSource.toggleFavorite(id);
      return const Right(null);
    } catch (e) {
      return const Left(CacheFailure('Failed to toggle favorite'));
    }
  }

  @override
  Future<Either<Failure, List<int>>> getHistory() async {
    try {
      final history = await localDataSource.getHistory();
      return Right(history);
    } catch (e) {
      return const Left(CacheFailure('Failed to load history'));
    }
  }

  @override
  Future<Either<Failure, void>> addToHistory(int id) async {
    try {
      await localDataSource.addToHistory(id);
      return const Right(null);
    } catch (e) {
      return const Left(CacheFailure('Failed to add to history'));
    }
  }
}
