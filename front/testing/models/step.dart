import 'package:front/data/services/api/model/step/step_api_model.dart';
import 'package:front/domain/models/step/step.dart';

const kStep =
    Step(title: 'TITLE', description: 'DESCRIPTION', order: 1, image: 'IMAGE');

const stepApiModel = StepApiModel(
  title: 'Step 1',
  description: 'Desc 1',
  order: 1,
  image: 'image.png',
);
