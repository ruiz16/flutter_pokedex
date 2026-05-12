# Pokedex Riverpod Modern Refactor — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Refactorizar el proyecto Pokedex a patrones Riverpod 3.x modernos con GoRouter, eliminando código innecesario (use cases, repository interface) y reduciendo providers de 213 a ~80 líneas.

**Architecture:** Estructura simplificada con datasource directo en providers, navegación shell-based con BottomNav persistente, y estado manejado con AsyncNotifier/Notifier pattern.

**Tech Stack:** Flutter 3.x, Riverpod 3.3.1, GoRouter 14.8.1, Dio 5.8.0

---

## File Structure Changes

```
ELIMINAR:
- lib/features/pokemon/domain/repositories/pokemon_repository.dart
- lib/features/pokemon/domain/usecases/*.dart (9 archivos)
- lib/features/pokemon/data/repositories/pokemon_repository_impl.dart

MANTENER:
- lib/core/
- lib/features/pokemon/data/datasources/
- lib/features/pokemon/data/models/
- lib/features/pokemon/domain/entities/
- lib/features/pokemon/presentation/views/ (actualizar)
- lib/features/pokemon/presentation/widgets/
- lib/shared/

CREAR:
- lib/core/router/app_router.dart
```

---

## Task 1: Crear GoRouter con Shell Navigation

**Files:**
- Create: `lib/core/router/app_router.dart`

- [ ] **Step 1: Crear archivo con la configuración del router**

```dart
// lib/core/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/pokemon/presentation/views/home_view.dart';
import '../../features/pokemon/presentation/views/favorites_view.dart';
import '../../features/pokemon/presentation/views/history_view.dart';
import '../../features/pokemon/presentation/views/pokemon_detail_view.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return MainShell(child: child);
      },
      routes: [
        GoRoute(
          path: '/',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: HomeView(),
          ),
        ),
        GoRoute(
          path: '/favorites',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: FavoritesView(),
          ),
        ),
        GoRoute(
          path: '/history',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: HistoryView(),
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/pokemon/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return PokemonDetailView(pokemonId: id);
      },
    ),
  ],
);

class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: const _BottomNavBar(),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar();

  int _getCurrentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/favorites')) return 1;
    if (location.startsWith('/history')) return 2;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _getCurrentIndex(context);

    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (index) {
        switch (index) {
          case 0:
            context.go('/');
            break;
          case 1:
            context.go('/favorites');
            break;
          case 2:
            context.go('/history');
            break;
        }
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.favorite_outline),
          selectedIcon: Icon(Icons.favorite),
          label: 'Favorites',
        ),
        NavigationDestination(
          icon: Icon(Icons.history_outlined),
          selectedIcon: Icon(Icons.history),
          label: 'History',
        ),
      ],
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/core/router/app_router.dart
git commit -m "feat(router): add GoRouter with shell navigation"
```

---

## Task 2: Refactorizar providers (núcleo de la refactorización)

**Files:**
- Modify: `lib/features/pokemon/presentation/providers/pokemon_providers.dart` (reemplazar todo el contenido)

- [ ] **Step 1: Reemplazar providers con versión limpia**

```dart
// lib/features/pokemon/presentation/providers/pokemon_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/network/api_client.dart';
import '../../data/datasources/pokemon_local_datasource.dart';
import '../../data/datasources/pokemon_remote_datasource.dart';
import '../../data/models/pokemon_model.dart';
import '../../data/models/pokemon_detail_model.dart';

// ═══════════════════════════════════════════════════════════════════
// DEPENDENCY PROVIDERS (inline, simples)
// ═══════════════════════════════════════════════════════════════════

final sharedPrefsProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences not initialized');
});

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final pokemonRemoteProvider = Provider<PokemonRemoteDataSource>((ref) {
  return PokemonRemoteDataSource(ref.read(apiClientProvider));
});

final pokemonLocalProvider = Provider<PokemonLocalDataSource>((ref) {
  return PokemonLocalDataSource(ref.read(sharedPrefsProvider));
});

// ═══════════════════════════════════════════════════════════════════
// UI STATE PROVIDERS (StateProvider simplificado)
// ═══════════════════════════════════════════════════════════════════

final searchQueryProvider = StateProvider<String>((ref) => '');

final typeFilterProvider = StateProvider<String?>((ref) => null);

final isLoadingMoreProvider = StateProvider<bool>((ref) => false);

// ═══════════════════════════════════════════════════════════════════
// DATA PROVIDERS (AsyncNotifier - lógica de negocio)
// ═══════════════════════════════════════════════════════════════════

final pokemonListProvider = AsyncNotifierProvider<PokemonListNotifier, List<PokemonModel>>(
  PokemonListNotifier.new,
);

class PokemonListNotifier extends AsyncNotifier<List<PokemonModel>> {
  @override
  Future<List<PokemonModel>> build() async {
    return _fetch(0);
  }

  Future<List<PokemonModel>> _fetch(int offset) async {
    final remote = ref.read(pokemonRemoteProvider);
    return remote.getPokemonList(offset, 20);
  }

  Future<void> loadMore() async {
    if (ref.read(isLoadingMoreProvider)) return;

    final current = state.value ?? [];
    ref.read(isLoadingMoreProvider.notifier).state = true;

    try {
      final newPokemons = await _fetch(current.length);
      state = AsyncData([...current, ...newPokemons]);
    } finally {
      ref.read(isLoadingMoreProvider.notifier).state = false;
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetch(0));
  }
}

final pokemonDetailProvider = FutureProvider.family<PokemonDetailModel, int>((ref, id) async {
  final remote = ref.read(pokemonRemoteProvider);
  return remote.getPokemonDetail(id);
});

final favoritesProvider = AsyncNotifierProvider<FavoritesNotifier, List<int>>(
  FavoritesNotifier.new,
);

class FavoritesNotifier extends AsyncNotifier<List<int>> {
  @override
  Future<List<int>> build() async {
    final local = ref.read(pokemonLocalProvider);
    return local.getFavorites();
  }

  Future<void> toggle(int id) async {
    final local = ref.read(pokemonLocalProvider);
    await local.toggleFavorite(id);
    ref.invalidateSelf();
  }
}

final historyProvider = AsyncNotifierProvider<HistoryNotifier, List<int>>(
  HistoryNotifier.new,
);

class HistoryNotifier extends AsyncNotifier<List<int>> {
  @override
  Future<List<int>> build() async {
    final local = ref.read(pokemonLocalProvider);
    return (await local.getHistory()).reversed.toList();
  }

  Future<void> add(int id) async {
    final local = ref.read(pokemonLocalProvider);
    await local.addToHistory(id);
    ref.invalidateSelf();
  }
}

// ═══════════════════════════════════════════════════════════════════
// DERIVED PROVIDER (computado)
// ═══════════════════════════════════════════════════════════════════

final filteredPokemonProvider = Provider<AsyncValue<List<PokemonModel>>>((ref) {
  final listState = ref.watch(pokemonListProvider);
  final query = ref.watch(searchQueryProvider);
  final type = ref.watch(typeFilterProvider);

  return listState.whenData((pokemons) {
    var filtered = pokemons;

    if (query.isNotEmpty) {
      filtered = filtered.where((p) => p.name.toLowerCase().contains(query.toLowerCase())).toList();
    }

    if (type != null) {
      filtered = filtered.where((p) => p.types.any((t) => t.name.toLowerCase() == type.toLowerCase())).toList();
    }

    return filtered;
  });
});

// ═══════════════════════════════════════════════════════════════════
// FAVORITES/HISTORY POKEMON PROVIDERS (para mostrar pokemon completo)
// ═══════════════════════════════════════════════════════════════════

final favoritePokemonsProvider = FutureProvider<List<PokemonModel>>((ref) async {
  final favoriteIds = await ref.watch(favoritesProvider.future);
  final list = await ref.watch(pokemonListProvider.future);
  return list.where((p) => favoriteIds.contains(p.id)).toList();
});

final historyPokemonsProvider = FutureProvider<List<PokemonModel>>((ref) async {
  final historyIds = await ref.watch(historyProvider.future);
  final list = await ref.watch(pokemonListProvider.future);
  return historyIds.map((id) => list.firstWhere((p) => p.id == id, orElse: () => list.first)).toList();
});
```

- [ ] **Step 2: Commit**

```bash
git add lib/features/pokemon/presentation/providers/pokemon_providers.dart
git commit -m "refactor(providers): simplify to modern Riverpod 3.x patterns"
```

---

## Task 3: Actualizar main.dart con nuevo router

**Files:**
- Modify: `lib/main.dart`

- [ ] **Step 1: Actualizar main.dart**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'features/pokemon/presentation/providers/pokemon_providers.dart';
import 'shared/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final sharedPrefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPrefsProvider.overrideWithValue(sharedPrefs),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Pokedex',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/main.dart
git commit -m "refactor(main): use GoRouter instead of setState navigation"
```

---

## Task 4: Actualizar views para usar nueva navegación

**Files:**
- Modify: `lib/features/pokemon/presentation/views/home_view.dart`
- Modify: `lib/features/pokemon/presentation/views/favorites_view.dart`
- Modify: `lib/features/pokemon/presentation/views/history_view.dart`
- Modify: `lib/features/pokemon/presentation/views/pokemon_detail_view.dart`

- [ ] **Step 1: Actualizar HomeView (quitar StatefulWidget, usar ConsumerWidget)**

```dart
// lib/features/pokemon/presentation/views/home_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/pokemon_providers.dart';
import '../widgets/pokemon_grid.dart';
import '../widgets/search_bar.dart';
import '../widgets/type_filter_chips.dart';
import '../widgets/empty_state.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/error_widget.dart';

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredPokemons = ref.watch(filteredPokemonProvider);
    final isLoadingMore = ref.watch(isLoadingMoreProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: SearchInput(
            onChanged: (value) {
              ref.read(searchQueryProvider.notifier).state = value;
            },
            onClear: () {
              ref.read(searchQueryProvider.notifier).state = '';
            },
          ),
        ),
        TypeFilterChips(
          selectedType: ref.watch(typeFilterProvider),
          onTypeSelected: (type) {
            ref.read(typeFilterProvider.notifier).state = type;
          },
        ),
        const SizedBox(height: 8),
        Expanded(
          child: filteredPokemons.when(
            data: (pokemons) {
              if (pokemons.isEmpty) {
                return const EmptyState(
                  message: 'No Pokemon found.\nTry a different search or filter.',
                  icon: Icons.search_off,
                );
              }

              return PokemonGrid(
                pokemons: pokemons,
                favoriteIds: ref.watch(favoritesProvider).value ?? [],
                onPokemonTap: (pokemon) => context.push('/pokemon/${pokemon.id}'),
                onFavoriteToggle: (id) => ref.read(favoritesProvider.notifier).toggle(id),
                onLoadMore: () => ref.read(pokemonListProvider.notifier).loadMore(),
                isLoading: isLoadingMore,
              );
            },
            loading: () => const ShimmerGrid(),
            error: (error, _) => ErrorDisplay(
              message: error.toString(),
              onRetry: () => ref.invalidate(pokemonListProvider),
            ),
          ),
        ),
      ],
    );
  }
}
```

- [ ] **Step 2: Actualizar FavoritesView**

```dart
// lib/features/pokemon/presentation/views/favorites_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/pokemon_providers.dart';
import '../widgets/pokemon_grid.dart';
import '../widgets/empty_state.dart';
import '../../../../shared/widgets/error_widget.dart';

class FavoritesView extends ConsumerWidget {
  const FavoritesView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritePokemons = ref.watch(favoritePokemonsProvider);

    return favoritePokemons.when(
      data: (pokemons) {
        if (pokemons.isEmpty) {
          return const EmptyState(
            message: 'No favorites yet.\nStart adding Pokemon to your favorites!',
            icon: Icons.favorite_outline,
          );
        }

        return PokemonGrid(
          pokemons: pokemons,
          favoriteIds: pokemons.map((p) => p.id).toList(),
          onPokemonTap: (pokemon) => context.push('/pokemon/${pokemon.id}'),
          onFavoriteToggle: (id) => ref.read(favoritesProvider.notifier).toggle(id),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => ErrorDisplay(
        message: error.toString(),
        onRetry: () => ref.invalidate(favoritesProvider),
      ),
    );
  }
}
```

- [ ] **Step 3: Actualizar HistoryView**

```dart
// lib/features/pokemon/presentation/views/history_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/pokemon_providers.dart';
import '../widgets/pokemon_grid.dart';
import '../widgets/empty_state.dart';
import '../../../../shared/widgets/error_widget.dart';

class HistoryView extends ConsumerWidget {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyPokemons = ref.watch(historyPokemonsProvider);

    return historyPokemons.when(
      data: (pokemons) {
        if (pokemons.isEmpty) {
          return const EmptyState(
            message: 'No history yet.\nStart exploring Pokemon!',
            icon: Icons.history,
          );
        }

        return PokemonGrid(
          pokemons: pokemons,
          favoriteIds: ref.watch(favoritesProvider).value ?? [],
          onPokemonTap: (pokemon) => context.push('/pokemon/${pokemon.id}'),
          onFavoriteToggle: (id) => ref.read(favoritesProvider.notifier).toggle(id),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => ErrorDisplay(
        message: error.toString(),
        onRetry: () => ref.invalidate(historyProvider),
      ),
    );
  }
}
```

- [ ] **Step 4: Actualizar PokemonDetailView**

```dart
// lib/features/pokemon/presentation/views/pokemon_detail_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/pokemon_providers.dart';
import '../widgets/stat_bar.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../data/models/pokemon_detail_model.dart';

class PokemonDetailView extends ConsumerWidget {
  final int pokemonId;

  const PokemonDetailView({super.key, required this.pokemonId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pokemonAsync = ref.watch(pokemonDetailProvider(pokemonId));
    final isFavorite = ref.watch(favoritesProvider).value?.contains(pokemonId) ?? false;

    // Agregar a historial al ver
    ref.listen(pokemonDetailProvider(pokemonId), (prev, next) {
      next.whenData((_) => ref.read(historyProvider.notifier).add(pokemonId));
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Pokemon #$pokemonId'),
        actions: [
          IconButton(
            icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_outline),
            onPressed: () => ref.read(favoritesProvider.notifier).toggle(pokemonId),
          ),
        ],
      ),
      body: pokemonAsync.when(
        data: (pokemon) => _buildContent(context, pokemon),
        loading: () => const LoadingIndicator(),
        error: (error, _) => ErrorDisplay(
          message: error.toString(),
          onRetry: () => ref.invalidate(pokemonDetailProvider(pokemonId)),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, PokemonDetailModel pokemon) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Pokemon image
          Container(
            width: double.infinity,
            height: 200,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Center(
              child: Image.network(
                pokemon.imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 100),
              ),
            ),
          ),
          // Types
          Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 8,
              children: pokemon.types.map((type) => Chip(
                label: Text(type.name.toUpperCase()),
                backgroundColor: _getTypeColor(type.name),
              )).toList(),
            ),
          ),
          // Stats
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Stats', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                ...pokemon.stats.map((stat) => StatBar(
                  name: stat.name,
                  value: stat.value,
                  maxValue: 255,
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(String type) {
    const colors = {
      'fire': Colors.orange,
      'water': Colors.blue,
      'grass': Colors.green,
      'electric': Colors.yellow,
      'psychic': Colors.purple,
      'normal': Colors.grey,
    };
    return colors[type.toLowerCase()] ?? Colors.grey;
  }
}
```

- [ ] **Step 5: Commit**

```bash
git add lib/features/pokemon/presentation/views/*.dart
git commit -m "refactor(views): update to ConsumerWidget and GoRouter navigation"
```

---

## Task 5: Actualizar widgets para usar PokemonModel

**Files:**
- Modify: `lib/features/pokemon/presentation/widgets/pokemon_card.dart`
- Modify: `lib/features/pokemon/presentation/widgets/pokemon_grid.dart`

- [ ] **Step 1: Revisar y actualizar PokemonGrid y PokemonCard si es necesario**

Revisar que los widgets acepten `List<PokemonModel>` en lugar de `List<Pokemon>` (que era del domain). Si hay imports que referencian `domain/entities/pokemon.dart`, actualizar a `data/models/pokemon_model.dart`.

- [ ] **Step 2: Commit (si hay cambios)**

```bash
git add lib/features/pokemon/presentation/widgets/*.dart
git commit -m "fix(widgets): update imports to use PokemonModel"
```

---

## Task 6: Eliminar archivos innecesarios

**Files:**
- Delete: `lib/features/pokemon/domain/repositories/pokemon_repository.dart`
- Delete: `lib/features/pokemon/domain/usecases/get_pokemon_list.dart`
- Delete: `lib/features/pokemon/domain/usecases/get_pokemon_detail.dart`
- Delete: `lib/features/pokemon/domain/usecases/toggle_favorite.dart`
- Delete: `lib/features/pokemon/domain/usecases/get_favorites.dart`
- Delete: `lib/features/pokemon/domain/usecases/add_to_history.dart`
- Delete: `lib/features/pokemon/domain/usecases/get_history.dart`
- Delete: `lib/features/pokemon/domain/usecases/filter_by_type.dart`
- Delete: `lib/features/pokemon/domain/usecases/search_pokemon.dart`
- Delete: `lib/features/pokemon/data/repositories/pokemon_repository_impl.dart`
- Delete: `lib/app.dart` (ya no se usa, fue reemplazado por main.dart con router)

- [ ] **Step 1: Eliminar todos los archivos innecesarios**

```bash
rm lib/features/pokemon/domain/repositories/pokemon_repository.dart
rm lib/features/pokemon/domain/usecases/*.dart
rm lib/features/pokemon/data/repositories/pokemon_repository_impl.dart
rm lib/app.dart
```

- [ ] **Step 2: Commit**

```bash
git add -A
git commit -m "chore: remove unused code (use cases, repository impl, app.dart)"
```

---

## Task 7: Actualizar pubspec.yaml

**Files:**
- Modify: `pubspec.yaml`

- [ ] **Step 1: Eliminar dartz (ya no se usa Either)**

```yaml
# Eliminar esta línea:
dartz: ^0.10.1
```

- [ ] **Step 2: Commit**

```bash
git add pubspec.yaml
git commit -m "chore: remove dartz dependency (no longer using Either)"
```

---

## Task 8: Verificación final

- [ ] **Step 1: Ejecutar flutter pub get**

```bash
flutter pub get
```

- [ ] **Step 2: Ejecutar flutter analyze**

```bash
flutter analyze
```

Esperado: 0 errors, 0 warnings

- [ ] **Step 3: Commit final**

```bash
git add -A
git commit -m "chore: final verification - flutter analyze clean"
```

---

## Success Verification Checklist

- [ ] GoRouter funcionando con shell navigation
- [ ] BottomNav visible en todas las pantallas
- [ ] Detail screen accesible desde cualquier tab
- [ ] Providers reducidos a ~80 líneas
- [ ] Sin use cases
- [ ] Sin repository interface
- [ ] flutter analyze = 0 errors
- [ ] Navegación por URL funcional (/, /favorites, /history, /pokemon/:id)