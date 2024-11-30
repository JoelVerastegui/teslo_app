import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:formz/formz.dart';
import 'package:teslo_shop/features/auth/presentation/providers/providers.dart';
import 'package:teslo_shop/features/shared/infrastructure/inputs/inputs.dart';

//Todo: StateNotifierProvider
final registerFormProvider = StateNotifierProvider<RegisterFormNotifier, RegisterFormState>((ref) {
  final registerUser = ref.watch(authProvider.notifier).registerUser;
  return RegisterFormNotifier(registerUser: registerUser);
});

//Todo: Notifier
class RegisterFormNotifier extends StateNotifier<RegisterFormState> {
  final Future<void> Function(String, String, String) registerUser;

  RegisterFormNotifier({
    required this.registerUser
  }): super(RegisterFormState());
  
  void onEmailChange(String value) {
    final email = Email.dirty(value);
    state = state.copyWith(
      email: email,
      isValid: Formz.validate([ email, state.password, state.fullname ])
    );
  }

  void onPasswordChange(String value) {
    final password = Password.dirty(value);
    state = state.copyWith(
      password: password,
      isPasswordVerified: false,
      isValid: Formz.validate([ password, state.email, state.fullname ])
    );
  }

  void onPasswordVerify(String value) {
    final isPasswordVerified = state.password.value == value;
    state = state.copyWith(
      isPasswordVerified: isPasswordVerified
    );
  }

  void onFullnameChange(String value) {
    final fullname = Fullname.dirty(value);
    state = state.copyWith(
      fullname: fullname,
      isValid: Formz.validate([ fullname, state.email, state.password ])
    );
  }

  void _touchFields() {
    final email = Email.dirty(state.email.value);
    final password = Password.dirty(state.password.value);
    final fullname = Fullname.dirty(state.fullname.value);

    state = state.copyWith(
      email: email,
      password: password,
      fullname: fullname,
      isFormPosted: true,
      isValid: Formz.validate([ email, password, fullname ])
    );
  }

  Future<void> onFormPosting() async {
    _touchFields();
    if(!state.isValid || !state.isPasswordVerified) return;

    await registerUser(state.email.value, state.password.value, state.fullname.value);

    print(state);
  }
}

//Todo: State
class RegisterFormState {
  final bool isPosting;
  final bool isFormPosted;
  final bool isValid;
  final bool isPasswordVerified;
  final Email email;
  final Password password;
  final Fullname fullname;

  RegisterFormState({
    this.isPosting = false, 
    this.isFormPosted = false, 
    this.isValid = false, 
    this.isPasswordVerified = false,
    this.email = const Email.pure(), 
    this.password = const Password.pure(), 
    this.fullname = const Fullname.pure()
  });

  RegisterFormState copyWith({
    bool? isPosting,
    bool? isFormPosted,
    bool? isValid,
    bool? isPasswordVerified,
    Email? email,
    Password? password,
    Fullname? fullname,
  }) => RegisterFormState(
    isPosting: isPosting ?? this.isPosting,
    isFormPosted: isFormPosted ?? this.isFormPosted,
    isValid: isValid ?? this.isValid,
    isPasswordVerified: isPasswordVerified ?? this.isPasswordVerified,
    email: email ?? this.email,
    password: password ?? this.password,
    fullname: fullname ?? this.fullname,
  );
}