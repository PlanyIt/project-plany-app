## Migration Guide: StatefulWidget vers ConsumerStatefulWidget

Ce guide décrit comment migrer les widgets existants vers Riverpod dans le projet Plany.

### Étapes de migration pour chaque StatefulWidget:

1. **Imports**:

   ```dart
   // Ajouter Riverpod
   import 'package:flutter_riverpod/flutter_riverpod.dart';
   ```

2. **Classe Widget**:

   ```dart
   // Ancien
   class MonWidget extends StatefulWidget {

   // Nouveau
   class MonWidget extends ConsumerStatefulWidget {
   ```

3. **State Class**:

   ```dart
   // Ancien
   class _MonWidgetState extends State<MonWidget> {

   // Nouveau
   class _MonWidgetState extends ConsumerState<MonWidget> {
   ```

4. **CreateState**:

   ```dart
   // Ancien
   @override
   State<MonWidget> createState() => _MonWidgetState();

   // Nouveau
   @override
   ConsumerState<MonWidget> createState() => _MonWidgetState();
   ```

5. **Build Method**:

   ```dart
   // Ancien
   @override
   Widget build(BuildContext context) {

   // Nouveau
   @override
   Widget build(BuildContext context, WidgetRef ref) {
   ```

6. **Utilisation des Providers**:

   ```dart
   // Dans build method
   final state = ref.watch(providerName);
   final notifier = ref.read(providerName.notifier);

   // Dans initState/méthodes
   ref.read(providerName.notifier).method();
   ```

### Widgets à migrer:

#### Create Plan:

- [x] StepOneContent
- [x] StepTwoContent
- [x] StepThreeContent
- [x] StepModal
- [x] ChooseLocation

#### Dashboard:

- [x] DashboardScreen
- [x] SearchScreen

#### Details Plan:

- [x] DetailScreen
- [x] CommentSection
- [x] CommentCard
- [x] ResponseCard
- [x] PlanInfoSection
- [x] StepsCarousel
- [x] MapView
- [x] StepInfoCard
- [x] DetailsHeader

#### Profil:

- [x] ProfilScreen
- [x] ProfileHeader
- [x] MyPlansSection
- [x] FavoritesSection
- [x] FollowersSection
- [x] FollowingSection
- [x] SettingsSection
- [x] ProfileAvatar
- [x] ProfileCategories
- [x] AccountSettings
- [x] GeneralSettings
- [x] ProfileSettings

#### Widgets Common:

- [x] CustomTextField (commun)
- [x] CustomTextField (textfield)
- [x] PlanyLogo (partie animée)
- [x] GlassButton

### Priorité de migration:

1. **Haute**: Login/Signup screens (déjà fait)
2. **Haute**: Dashboard et navigation principale
3. **Moyenne**: Create Plan flows
4. **Moyenne**: Profile management
5. **Basse**: Détails et composants secondaires

### Notes importantes:

- Remplacer tous les `setState()` par l'utilisation des providers Riverpod
- Supprimer les listeners manuels (addListener/removeListener)
- Utiliser `ref.watch()` pour écouter les changements d'état
- Utiliser `ref.read()` pour déclencher des actions

### État de la migration:

✅ **MIGRATION TERMINÉE** - Tous les widgets listés ont été migrés vers Riverpod

**Widgets migrés avec succès:**

- **Create Plan**: 5/5 widgets ✅
- **Dashboard**: 2/2 widgets ✅
- **Details Plan**: 9/9 widgets ✅
- **Profil**: 12/12 widgets ✅
- **Widgets Common**: 4/4 widgets ✅

**Total**: 32/32 widgets migrés vers Riverpod

### Prochaines étapes:

1. Tester le bon fonctionnement de tous les widgets migrés
2. Vérifier que les providers Riverpod sont correctement utilisés
3. Supprimer les anciens ViewModels si ils ne sont plus utilisés
4. Optimiser les providers pour éviter les rebuilds inutiles
