class LoginViewState {
  const LoginViewState();

  bool isValidCredentials({required String email, required String password}) {
    return email.trim().isNotEmpty && password.trim().isNotEmpty;
  }
}