import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/pokemon/presentation/views/home_view.dart';
import 'features/pokemon/presentation/views/pokemon_detail_view.dart';
import 'features/pokemon/presentation/views/favorites_view.dart';
import 'features/pokemon/presentation/views/history_view.dart';

class PokedexApp extends ConsumerStatefulWidget {
  const PokedexApp({super.key});

  @override
  ConsumerState<PokedexApp> createState() => _PokedexAppState();
}

class _PokedexAppState extends ConsumerState<PokedexApp> {
  int _currentIndex = 0;
  int? _selectedPokemonId;

  void _onPokemonTap(int id) {
    setState(() {
      _selectedPokemonId = id;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedPokemonId != null) {
      return PokemonDetailView(
        pokemonId: _selectedPokemonId!,
        onBack: () {
          setState(() {
            _selectedPokemonId = null;
          });
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokedex'),
        leading: _currentIndex == 0
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    _currentIndex = 0;
                  });
                },
              ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeView(onPokemonTap: _onPokemonTap),
          FavoritesView(onPokemonTap: _onPokemonTap),
          HistoryView(onPokemonTap: _onPokemonTap),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
        ],
      ),
    );
  }
}
