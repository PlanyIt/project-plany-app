import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:front/models/categorie.dart';
import 'package:front/models/plan.dart';
import 'package:front/models/tag.dart';
import 'package:front/screens/create-plan/stepModal.dart';
import 'package:front/services/categorie_service.dart';
import 'package:front/services/plan_service.dart';
import 'package:front/services/tag_service.dart';
import 'package:front/utils/icon_utils.dart';
import 'package:front/widgets/buttons/primarybutton.dart';
import 'package:front/widgets/buttons/secondarybutton.dart';
import 'package:front/widgets/buttons/selectbutton.dart';
import 'package:front/widgets/cards/p_plan-card.dart';
import 'package:front/widgets/dotted_line_painter.dart';
import 'package:image_picker/image_picker.dart';

class CreatePlansScreen extends StatefulWidget {
  const CreatePlansScreen({super.key});

  @override
  CreatePlansScreenState createState() => CreatePlansScreenState();
}

class CreatePlansScreenState extends State<CreatePlansScreen> {
  int _currentStep = 1;
  final TextEditingController _titreController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _tagSearchController = TextEditingController();
  final PlanService _planService = PlanService();
  final TagService _tagService = TagService();
  final CategorieService _categorieService = CategorieService();

  List<Category> _categories = [];
  List<Tag> _tags = [];
  List<Tag> _filteredTags = [];
  List<Tag> _selectedTags = [];
  Category? _selectedCategory;
  bool _showTagContainer = false;
  XFile? _image;
  List<PlanCard> _planCards = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadTags();
  }

  void _loadCategories() async {
    try {
      final categories = await _categorieService.getCategories();
      setState(() {
        _categories = categories;
      });
    } catch (e) {
      // Handle error
    }
  }

  void _loadTags() async {
    try {
      final tags = await _tagService.getCategories();
      setState(() {
        _tags = tags;
        _filteredTags = tags;
      });
    } catch (e) {
      // Handle error
    }
  }

  void _filterTags(String query) {
    final filteredTags = _tags.where((tag) {
      final tagName = tag.name.toLowerCase();
      final input = query.toLowerCase();
      return tagName.contains(input);
    }).toList();

    setState(() {
      _filteredTags = filteredTags;
      _showTagContainer = query.isNotEmpty;
    });
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image;
    });
  }

  void _addPlanCard(String title, String description, File? image) {
    setState(() {
      _planCards.add(
        PlanCard(
          imageUrl: image?.path ?? '',
          title: title,
          description: description,
        ),
      );
    });
  }

  void _nextStep() async {
    if (_currentStep < 4) {
      setState(() {
        _currentStep++;
      });
    } else {
      final plan = Plan(
        title: _titreController.text,
        description: _descriptionController.text,
      );

      try {
        await _planService.createPlan(plan);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Plan créé avec succès !')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Échec de la création du plan : $e')),
        );
      }
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  void _showCategoryBottomSheet(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Catégorie',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: _categories.map((cat) {
                    return Column(
                      children: [
                        IconButton(
                          icon: CircleAvatar(
                            radius: 30,
                            backgroundColor:
                                const Color.fromARGB(255, 227, 230, 231),
                            child: Icon(
                              getIconData(cat.icon),
                              color: Colors.black,
                              size: 20,
                              semanticLabel: 'Category icon',
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              _selectedCategory = cat;
                            });
                            Navigator.pop(context);
                          },
                        ),
                        const SizedBox(height: 5),
                        Text(cat.name),
                      ],
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget content() {
    switch (_currentStep) {
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Titre du plan',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _titreController,
              decoration: InputDecoration(
                labelText: 'Titre du plan',
                labelStyle: TextStyle(color: Colors.grey[600]),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Description',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _titreController,
              maxLines: 5,
              textAlignVertical: TextAlignVertical.top, // Add this line
              decoration: InputDecoration(
                alignLabelWithHint: true,
                labelText: 'Description du plan',
                labelStyle: TextStyle(color: Colors.grey[600]),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Catégorie',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            _selectedCategory == null
                ? SelectButton(
                    text: "Choisir une catégorie",
                    onPressed: () => _showCategoryBottomSheet(context),
                    leadingIcon: Icons.category,
                    trailingIcon: Icons.arrow_forward,
                  )
                : IconButton(
                    icon: CircleAvatar(
                      radius: 25,
                      backgroundColor: Theme.of(context).primaryColor,
                      child: Icon(
                        getIconData(_selectedCategory!.icon),
                        color: Colors.white,
                        size: 15,
                        semanticLabel: 'Category icon',
                      ),
                    ),
                    onPressed: () => _showCategoryBottomSheet(context),
                  ),
            const SizedBox(height: 20),
            const Text(
              'Tags',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: 300,
              child: TextField(
                controller: _tagSearchController,
                decoration: InputDecoration(
                  hintText: "Rechercher tags",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.vertical(
                      top: const Radius.circular(5),
                      bottom: Radius.circular(_showTagContainer ? 0 : 5),
                    ),
                  ),
                ),
                onChanged: _filterTags,
              ),
            ),
            if (_showTagContainer)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(5),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                width: 300,
                height: 150,
                child: ListView.builder(
                  itemCount:
                      _filteredTags.length > 5 ? 5 : _filteredTags.length,
                  itemBuilder: (context, index) {
                    final tag = _filteredTags[index];
                    return ListTile(
                      title: Text(tag.name),
                      onTap: () {
                        setState(() {
                          if (!_selectedTags.contains(tag)) {
                            _selectedTags.add(tag);
                          }
                          _showTagContainer = false;
                          _tagSearchController.clear();
                        });
                      },
                    );
                  },
                ),
              ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: _selectedTags.map((tag) {
                return Chip(
                  label: Text(tag.name),
                  onDeleted: () {
                    setState(() {
                      _selectedTags.remove(tag);
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 100),
          ],
        );
      case 2:
        return SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              _image == null
                  ? const Icon(
                      FontAwesomeIcons.image,
                      size: 150,
                      color: Colors.black12,
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(20.0),
                      child: Image.file(
                        File(_image!.path),
                        width: 250,
                        height: 250,
                        fit: BoxFit.cover,
                      ),
                    ),
              const SizedBox(height: 20),
              PrimaryButton(
                onPressed: _pickImage,
                text: "Ajouter une image",
              ),
              const SizedBox(height: 200),
            ],
          ),
        );
      case 3:
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Text(
                'Ajout des étapes',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // ReorderableListView pour permettre le glisser-déposer
              ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _planCards.length,
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) {
                      newIndex -= 1;
                    }
                    final item = _planCards.removeAt(oldIndex);
                    _planCards.insert(newIndex, item);
                  });
                },
                itemBuilder: (context, index) {
                  final isLastItem = index == _planCards.length - 1;

                  return Column(
                    key: Key('plan_step_$index'),
                    children: [
                      // Élément de la carte avec badge numéroté
                      Stack(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Colonne pour le badge numéroté
                              SizedBox(
                                width: 40,
                                child: CircleAvatar(
                                  backgroundColor:
                                      Theme.of(context).primaryColor,
                                  radius: 16,
                                  child: Text(
                                    '${index + 1}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                              // La carte du plan
                              Expanded(
                                child: _planCards[index],
                              ),
                            ],
                          ),

                          // Bouton de suppression en haut à droite
                          Positioned(
                            top: 10,
                            right: 10,
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _planCards.removeAt(index);
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.red[50],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.delete_outline,
                                  size: 20,
                                  color: Colors.red[700],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Ligne pointillée séparée, uniquement si ce n'est pas le dernier élément
                      if (!isLastItem)
                        SizedBox(
                          height: 30,
                          child: Row(
                            children: [
                              SizedBox(
                                width: 40,
                                child: Center(
                                  child: CustomPaint(
                                    size: const Size(2, 30),
                                    painter: DottedLinePainter(
                                      color: Theme.of(context).primaryColor,
                                      dashLength: 3,
                                      dashGap: 3,
                                    ),
                                  ),
                                ),
                              ),
                              const Expanded(child: SizedBox()),
                            ],
                          ),
                        ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(15)),
                    ),
                    context: context,
                    isScrollControlled: true,
                    builder: (BuildContext context) {
                      return StepModal(
                        onAddStep:
                            (String title, String description, File? image) {
                          _addPlanCard(title, description, image);
                        },
                      );
                    },
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(20),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(FontAwesomeIcons.plus,
                          color: Theme.of(context).primaryColor),
                      const SizedBox(width: 10),
                      Text(
                        'Ajouter une étape',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        );
      case 4:
        return const Text('Étape 4');
      default:
        return const Text('Étape inconnue');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 80,
        leading: _currentStep > 1
            ? IconButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(Colors.white),
                ),
                icon:
                    const Icon(Icons.chevron_left_rounded, color: Colors.black),
                iconSize: 30,
                onPressed: _previousStep,
              )
            : const SizedBox(),
        centerTitle: true,
        title: const Text(
          "Créer un plan",
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              // Add this line
              child: Column(
                children: [
                  // Text with step count
                  Text(
                    '$_currentStep/4',
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.5,
                      child: TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0, end: _currentStep / 4),
                        duration: const Duration(milliseconds: 300),
                        builder: (context, value, _) => ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: LinearProgressIndicator(
                            value: value,
                            backgroundColor: Colors.grey[300],
                            color: const Color(0xFF3425B5),
                            minHeight: 5,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 50),
                  content(),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 4,
                    blurRadius: 8,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 200,
                    child: PrimaryButton(
                      text: _currentStep != 4 ? "Suivant" : "Valider",
                      onPressed: _nextStep,
                    ),
                  ),
                  if (_currentStep > 1)
                    Column(
                      children: [
                        const SizedBox(height: 10),
                        SizedBox(
                          width: 200,
                          child: SecondaryButton(
                            text: "Annuler",
                            onPressed: _previousStep,
                          ),
                        ),
                      ],
                    )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _titreController.dispose();
    _descriptionController.dispose();
    _tagSearchController.dispose();
    super.dispose();
  }
}
