# Flutter Pokedex 2026 — Riverpod Moderno Refactor

**Date**: 2026-05-12
**Status**: Approved
**Type**: Refactorización radical

---

## 1. Overview

Refactorización completa del proyecto Pokedex para usar patrones Riverpod 3.x modernos (sin code generation), GoRouter para navegación shell-based, y eliminar capas innecesarias.

**Goals**:
- Reducir código de 213 líneas de providers a ~80 líneas
- Eliminar use cases y capa domain intermedia
- Implementar navegación declarativa con GoRouter
- Usar `@riverpod` annotation sin generation (manual)
- Aprender patrones Riverpod 2026

---

## 2. Architecture

### Antes vs Ahora

```
ANTES (CLEAN ARCHITECTURE sobre-ingenieril):
┌─────────────────────────────────────────────────────────┐
│ presentation/                                           │
│   providers/ ← 213 líneas de providers inflados        │
│   views/                                                │
│   widgets/                                              │
├─────────────────────────────────────────────────────────┤
│ domain/                                                 │
│   entities/                                             │
│   repositories/ ← interfaz + implementación redundante   │
│   usecases/ ← clases innecesarias (1 método cada una)   │
├─────────────────────────────────────────────────────────┤
│ data/                                                   │
│   models/                                               │
│   datasources/                                          │
│   repositories/ ← implementación que solo delega        │
└─────────────────────────────────────────────────────────┘

AHORA (LEAN & MODERNO):
┌─────────────────────────────────────────────────────────┐
│ features/pokemon/                                        │
│   data/                                                 │
│     datasources/  ← API client directo (Dio)            │
│     models/       ← JSON parsing                       │
│   presentation/                                           │
│     providers/   ← ~80 líneas, limpios                 │
│     views/        ← Screens                           │
│     widgets/      ← Componentes UI                     │
│   domain/         ← Solo entities (data classes)       │
│   core/           ← API client, errors, theme          │
└─────────────────────────────────────────────────────────┘
```

---

## 3. Provider Architecture

### Pattern: Functional Providers + Notifier Classes

```
┌─────────────────────────────────────────────────────────┐
│ DEPENDENCY PROVIDERS (1-liners, inline)                  │
├─────────────────────────────────────────────────────────┤
│ final sharedPrefsProvider = Provider<SharedPreferences> │
│ final apiClientProvider = Provider<ApiClient>           │
│ final pokemonRemoteProvider = Provider<PokemonRemote>   │
│ final pokemonLocalProvider = Provider<PokemonLocal>     │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│ DATA PROVIDERS (AsyncNotifier / Notifier)                │
├─────────────────────────────────────────────────────────┤
│ final pokemonListProvider = AsyncNotifierProvider       │
│ final pokemonDetailProvider = FutureProvider.family     │
│ final favoritesProvider = AsyncNotifierProvider         │
│ final historyProvider = AsyncNotifierProvider           │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│ UI STATE PROVIDERS (StateProvider simplificado)          │
├─────────────────────────────────────────────────────────┤
│ final searchQueryProvider = StateProvider<String>       │
│ final typeFilterProvider = StateProvider<String?>      │
│ final isLoadingMoreProvider = StateProvider<bool>      │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│ DERIVED PROVIDERS (Provider con computed value)         │
├─────────────────────────────────────────────────────────┤
│ final filteredPokemonProvider = Provider<AsyncValue>    │
└─────────────────────────────────────────────────────────┘
```

---

## 4. Navigation Structure

### Routes

```dart
/                     → HomeScreen (index 0)
/favorites            → FavoritesScreen (index 1)
/history              → HistoryScreen (index 2)
/pokemon/:id          → PokemonDetailScreen (modal/overlay)
```

### Shell Layout

```
┌─────────────────────────────────────────┐
│ AppBar (con título dinámico)              │
├─────────────────────────────────────────┤
│                                         │
│          Content Area                   │
│     (Home/Favorites/History)            │
│                                         │
├─────────────────────────────────────────┤
│ BottomNavBar (always visible)           │
│ [Home] [Favorites] [History]            │
└─────────────────────────────────────────┘

Cuando se navega a /pokemon/:id:
- Aparece sobre el shell como modal/push
- BottomNavBar se oculta
- Back button en AppBar
```

---

## 5. File Changes

### ELIMINAR (código basura):
- `domain/repositories/pokemon_repository.dart` — interfaz innecesaria
- `domain/usecases/` — todas las clases (9 archivos)
- `data/repositories/pokemon_repository_impl.dart` — solo delega

### MANTENER:
- `data/datasources/` — lógica real de API/storage
- `data/models/` — parsing de JSON
- `domain/entities/` — data classes

### MODIFICAR:
- `presentation/providers/pokemon_providers.dart` — reescribir limpio
- `app.dart` — reemplazar por GoRouter
- `main.dart` — ProviderScope con overrides mínimos

### CREAR:
- `core/router/app_router.dart` — configuración GoRouter
- `features/pokemon/presentation/providers/providers.dart` — providers limpios

---

## 6. Provider Implementation Details

### PokemonListProvider (antes vs después)

**ANTES (90 líneas con use case):**
```dart
final getPokemonListUseCaseProvider = Provider<GetPokemonList>((ref) {...});
final pokemonListProvider = AsyncNotifierProvider<PokemonListNotifier, List<Pokemon>>(
  PokemonListNotifier.new,
);
class PokemonListNotifier extends AsyncNotifier<List<Pokemon>> {
  @override
  Future<List<Pokemon>> build() async {
    final useCase = ref.read(getPokemonListUseCaseProvider);
    final result = await useCase.call(offset, limit);
    return result.fold((f) => throw, (p) => p);
  }
}
```

**AHORA (40 líneas, directo al datasource):**
```dart
final pokemonListProvider = AsyncNotifierProvider<PokemonListNotifier, List<Pokemon>>(
  PokemonListNotifier.new,
);

class PokemonListNotifier extends AsyncNotifier<List<Pokemon>> {
  @override
  Future<List<Pokemon>> build() async {
    return _fetch(0);
  }

  Future<List<Pokemon>> _fetch(int offset) async {
    final remote = ref.read(pokemonRemoteProvider);
    return remote.getPokemonList(offset, 20);
  }

  Future<void> loadMore() async {
    if (state.isLoading) return;
    final current = state.value ?? [];
    final newPokemons = await _fetch(current.length);
    state = AsyncData([...current, ...newPokemons]);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetch(0));
  }
}
```

---

## 7. State Management Pattern

### Simplification Summary

| Antes | Ahora | Reducción |
|-------|-------|-----------|
| 11 providers de configuración | 4 providers de config | -7 |
| 9 use case providers | 0 | -9 |
| 3 clases notifier | 3 notifiers | 0 |
| 213 líneas | ~80 líneas | -133 |

### StateProvider vs Notifier

- **StateProvider**: UI state simple (search query, selected type, loading flag)
- **Notifier/AsyncNotifier**: State complejo con lógica (pokemon list, favorites, history)

---

## 8. GoRouter Configuration

```dart
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return MainShell(child: child);
        },
        routes: [
          GoRoute(path: '/', ...),
          GoRoute(path: '/favorites', ...),
          GoRoute(path: '/history', ...),
        ],
      ),
      GoRoute(
        path: '/pokemon/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return PokemonDetailScreen(pokemonId: id);
        },
      ),
    ],
  );
});
```

---

## 9. Dependencies (pubspec.yaml)

**Mantener:**
- `flutter_riverpod: ^3.3.1`
- `riverpod: ^3.3.1`
- `dio: ^5.8.0`
- `shared_preferences: ^2.5.3`
- `go_router: ^14.8.1`
- `cached_network_image: ^3.4.1`
- `shimmer: ^3.0.0`
- `equatable: ^2.0.7`

**Eliminar:**
- `dartz` (no más Either, exceptions directas)
- `json_annotation` + `json_serializable` (parsing manual simple)

**Agregar:**
- Ninguno nuevo

---

## 10. Testing Strategy

1. **Unit tests** en providers con `provider_container`
2. **Widget tests** en components principales
3. **Integration tests** para flujos críticos

---

## 11. Implementation Order

1. Crear router con GoRouter
2. Refactorizar providers (eliminar use cases, inline dependencies)
3. Reemplazar app.dart StatefulWidget por app con ConsumerWidget + GoRouter
4. Actualizar views para usar nueva navegación
5. Eliminar archivos innecesarios
6. Verificar con `flutter analyze`

---

## 12. Success Criteria

- [ ] `flutter analyze` sin errores ni warnings
- [ ] Providers reducidos de 213 a ~80 líneas
- [ ] Navegación funcional con BottomNav + Detail
- [ ] Sin código duplicado o innecesario
- [ ] Patrones Riverpod 2026 evidentes