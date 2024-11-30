import 'package:formz/formz.dart';

// Define input validation errors
enum FullnameError { empty, length }

// Extend FormzInput and provide the input type and error type.
class Fullname extends FormzInput<String, FullnameError> {
  // Call super.pure to represent an unmodified form input.
  const Fullname.pure() : super.pure('');

  // Call super.dirty to represent a modified form input.
  const Fullname.dirty(super.value) : super.dirty();

  String? get errorMessage {
    if(displayError == FullnameError.empty) return 'El nombre completo está vacío';
    if(displayError == FullnameError.length) return 'Debe tener 10 caracteres como mínimo';
    return null;
  }

  // Override validator to handle validating a given input value.
  @override
  FullnameError? validator(String value) {
    if(value.isEmpty || value.trim().isEmpty) return FullnameError.empty;
    if(value.length < 10) return FullnameError.length;
    return null;
  }
}