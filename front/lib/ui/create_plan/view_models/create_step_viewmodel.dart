import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';

class CreateStepViewModel extends ChangeNotifier {
  final ValueNotifier<String> title = ValueNotifier('');
  final ValueNotifier<String> description = ValueNotifier('');
  final ValueNotifier<int> duration = ValueNotifier(0);
  final ValueNotifier<String> cost = ValueNotifier('');
  final ValueNotifier<String> durationUnit = ValueNotifier('Heures');

  XFile? _image;
  LatLng? _location;
  String? _locationName;

  XFile? get image => _image;
  LatLng? get location => _location;
  String? get locationName => _locationName;

  bool _isEditing = false;
  int? _editingIndex;

  bool get isEditing => _isEditing;
  int? get editingIndex => _editingIndex;

  void setTitle(String value) => title.value = value;
  void setDescription(String value) => description.value = value;
  void setDuration(int value) => duration.value = value;
  void setCost(String value) => cost.value = value;
  void setDurationUnit(String value) => durationUnit.value = value;

  void setLocation(LatLng loc, String name) {
    _location = loc;
    _locationName = name;
    notifyListeners();
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final result = await picker.pickImage(source: ImageSource.gallery);
    if (result != null) {
      _image = result;
      notifyListeners();
    }
  }

  void removeImage() {
    _image = null;
    notifyListeners();
  }

  void startEditing(StepData step, int index) {
    title.value = step.title;
    description.value = step.description;
    duration.value = step.duration ?? 0;
    durationUnit.value = step.durationUnit ?? 'Heures';
    cost.value = step.cost?.toString() ?? '';
    _image = step.imageUrl.isNotEmpty ? XFile(step.imageUrl) : null;
    _location = step.location;
    _locationName = step.locationName;

    _isEditing = true;
    _editingIndex = index;
    notifyListeners();
  }

  void cancelEditing() {
    reset();
  }

  StepData? buildStepData() {
    if (title.value.trim().isEmpty || (_image == null)) return null;

    return StepData(
      title: title.value.trim(),
      description: description.value.trim(),
      imageUrl: _image!.path,
      duration: duration.value,
      durationUnit: durationUnit.value,
      cost: double.tryParse(cost.value.trim()),
      location: _location,
      locationName: _locationName,
    );
  }

  void reset() {
    title.value = '';
    description.value = '';
    duration.value = 0;
    cost.value = '';
    durationUnit.value = 'Heures';
    _image = null;
    _location = null;
    _locationName = null;
    _isEditing = false;
    _editingIndex = null;
    notifyListeners();
  }

  @override
  void dispose() {
    title.dispose();
    description.dispose();
    duration.dispose();
    cost.dispose();
    durationUnit.dispose();
    super.dispose();
  }
}

class StepData {
  final String title;
  final String description;
  final String imageUrl;
  final int? duration;
  final String? durationUnit;
  final double? cost;
  final LatLng? location;
  final String? locationName;

  const StepData({
    required this.title,
    required this.description,
    required this.imageUrl,
    this.duration,
    this.durationUnit,
    this.cost,
    this.location,
    this.locationName,
  });
}
