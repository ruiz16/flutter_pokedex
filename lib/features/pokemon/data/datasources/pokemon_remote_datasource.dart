import '../../../../core/network/api_client.dart';
import '../models/pokemon_model.dart';
import '../models/pokemon_detail_model.dart';

class PokemonRemoteDataSource {
  final ApiClient apiClient;

  PokemonRemoteDataSource(this.apiClient);

  Future<List<PokemonModel>> getPokemonList(int offset, int limit) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      '/pokemon',
      queryParameters: {'offset': offset, 'limit': limit},
    );

    final results = response.data!['results'] as List;
    final List<PokemonModel> pokemons = [];

    for (int i = 0; i < results.length; i++) {
      final url = results[i]['url'] as String;
      final id = int.parse(url.split('/').where((s) => s.isNotEmpty).last);
      final detailResponse = await apiClient.get<Map<String, dynamic>>(
        '/pokemon/$id',
      );
      pokemons.add(PokemonModel.fromJson(detailResponse.data!));
    }

    return pokemons;
  }

  Future<PokemonDetailModel> getPokemonDetail(int id) async {
    final response = await apiClient.get<Map<String, dynamic>>('/pokemon/$id');
    return PokemonDetailModel.fromJson(response.data!);
  }

  Future<PokemonDetailModel> getPokemonByName(String name) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      '/pokemon/$name',
    );
    return PokemonDetailModel.fromJson(response.data!);
  }

  Future<List<PokemonModel>> getPokemonByType(
    String type, {
    int offset = 0,
    int limit = 20,
  }) async {
    final response = await apiClient.get<Map<String, dynamic>>('/type/$type');
    final pokemonList = response.data!['pokemon'] as List;

    final List<PokemonModel> pokemons = [];
    final paginatedList = pokemonList.skip(offset).take(limit).toList();

    for (final entry in paginatedList) {
      final url = entry['pokemon']['url'] as String;
      final id = int.parse(url.split('/').where((s) => s.isNotEmpty).last);
      final detailResponse = await apiClient.get<Map<String, dynamic>>(
        '/pokemon/$id',
      );
      pokemons.add(PokemonModel.fromJson(detailResponse.data!));
    }

    return pokemons;
  }
}
