import 'package:front/utils/result.dart';

extension ResultCast<T> on Result<T> {
  /// Convenience method to cast to Ok
  Ok<T> get asOk => this as Ok<T>;

  /// Convenience method to cast to Error
  Error get asError => this as Error<T>;
}

// Ajoute un getter isOk pour tous les Result<T>
extension ResultIsOk<T> on Result<T> {
  bool get isOk => this is Ok<T>;
}
