class RegisterRequest {
  final String name;
  final String phoneNumber;
  final String email;
  final String birthDate;
  final String password;
  final String faceImagePath;

  const RegisterRequest({
    required this.name,
    required this.phoneNumber,
    required this.email,
    required this.birthDate,
    required this.password,
    required this.faceImagePath,
  });

  Map<String, String> toFields() => {
    'name': name,
    'phoneNumber': phoneNumber,
    'email': email,
    'birthDate': birthDate,
    'password': password,
  };
}
