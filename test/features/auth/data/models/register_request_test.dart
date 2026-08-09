import 'package:flutter_test/flutter_test.dart';
import 'package:kompak_app/features/auth/data/models/register_request.dart';

void main() {
  test('serializes only persisted registration fields', () {
    const request = RegisterRequest(
      name: 'Olivia Rhye',
      phoneNumber: '081234567890',
      email: 'olivia@example.com',
      birthDate: '1995-06-12',
      password: 'secret123',
      faceImagePath: '/tmp/face.jpg',
    );

    expect(request.toFields(), {
      'name': 'Olivia Rhye',
      'phoneNumber': '081234567890',
      'email': 'olivia@example.com',
      'birthDate': '1995-06-12',
      'password': 'secret123',
    });
    expect(request.toFields(), isNot(contains('address')));
    expect(request.toFields(), isNot(contains('confirmPassword')));
    expect(request.toFields(), isNot(contains('faceEmbeddingId')));
  });
}
