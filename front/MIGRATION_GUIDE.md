# Guide de Migration vers l'Architecture d'État Unifié

## Vue d'ensemble

Cette architecture unifie la gestion d'état dans votre application Flutter en utilisant :

- **BaseViewModel** : Classe de base pour tous les ViewModels
- **ListState** : Gestion unifiée des états de liste
- **ViewModelProvider** : Provider simplifié pour l'injection de dépendances
- **Command** : Pattern pour les actions asynchrones

## 1. Migration d'un ViewModel existant

### Avant (Ancien)

```dart
class MyViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  List<Item> _items = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Item> get items => _items;

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await repository.getData();
      _items = result;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
```

### Après (Nouveau)

```dart
class MyViewModel extends BaseViewModel {
  MyViewModel({required Repository repository}) : _repository = repository {
    loadData = Command0(_loadData);
  }

  final Repository _repository;
  late Command0 loadData;

  ListState<Item> _itemsState = ListState.initial();
  ListState<Item> get itemsState => _itemsState;
  List<Item> get items => _itemsState.items;

  Future<Result> _loadData() async {
    _itemsState = ListState.loading();
    notifyListeners();

    try {
      final result = await _repository.getData();
      if (result is Ok<List<Item>>) {
        _itemsState = ListState.success(items: result.value);
      } else {
        _itemsState = ListState.error('Failed to load data');
      }
      notifyListeners();
      return const Result.ok(null);
    } catch (e) {
      _itemsState = ListState.error(e.toString());
      notifyListeners();
      return Result.error(Exception(e.toString()));
    }
  }
}
```

## 2. Migration d'un écran

### Avant

```dart
class MyScreen extends StatefulWidget {
  @override
  _MyScreenState createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  @override
  void initState() {
    super.initState();
    context.read<MyViewModel>().loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MyViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return CircularProgressIndicator();
        }

        if (viewModel.error != null) {
          return Text('Error: ${viewModel.error}');
        }

        return ListView.builder(
          itemCount: viewModel.items.length,
          itemBuilder: (context, index) {
            return ListTile(title: Text(viewModel.items[index].name));
          },
        );
      },
    );
  }
}
```

### Après

```dart
class MyScreen extends StatefulWidget {
  @override
  _MyScreenState createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen>
    with ViewModelMixin<MyScreen, MyViewModel> {

  @override
  void onViewModelReady(MyViewModel viewModel) {
    viewModel.loadData.execute();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MyViewModel>(
      builder: (context, viewModel, child) {
        return viewModel.itemsState.when(
          initial: () => Text('Initialisation...'),
          loading: () => CircularProgressIndicator(),
          success: (items) => ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              return ListTile(title: Text(items[index].name));
            },
          ),
          empty: () => Text('Aucun élément'),
          error: (error) => Text('Erreur: $error'),
        );
      },
    );
  }
}
```

## 3. Avantages de la nouvelle architecture

### Consistance

- Tous les ViewModels héritent du même comportement de base
- États de chargement et d'erreur gérés uniformément
- Pattern uniforme pour les opérations asynchrones

### Simplicité

- Moins de code boilerplate
- Gestion automatique des états loading/error
- Extension `when` pour simplifier l'affichage

### Robustesse

- Gestion centralisée des erreurs
- Protection contre les fuites mémoire
- Pattern Command pour les opérations asynchrones

### Testabilité

- ViewModels plus faciles à tester
- États mockables
- Separation of concerns claire

## 4. Checklist de migration

- [ ] Créer les nouveaux fichiers de base (BaseViewModel, ListState, etc.)
- [ ] Migrer un ViewModel à la fois
- [ ] Tester chaque ViewModel migré
- [ ] Mettre à jour les écrans correspondants
- [ ] Supprimer l'ancien code après validation
- [ ] Documenter les patterns pour l'équipe

## 5. Patterns recommandés

### Pour les listes simples

```dart
ListState<Item> _itemsState = ListState.initial();
ListState<Item> get itemsState => _itemsState;
```

### Pour les opérations avec loading global

```dart
Future<Result> _operation() async {
  return await executeWithLoading(() => repository.doSomething());
}
```

### Pour les opérations avec gestion d'erreur personnalisée

```dart
Future<Result> _operation() async {
  final result = await repository.doSomething();
  handleResult(result,
    onSuccess: (value) => print('Success: $value'),
    onError: (error) => print('Error: $error'),
  );
  return result;
}
```
