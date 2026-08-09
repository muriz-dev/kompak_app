class RegistrationFailure implements Exception {
  final String message;
  final Map<String, String> fieldErrors;

  const RegistrationFailure(this.message, [this.fieldErrors = const {}]);

  @override
  String toString() => message;
}
