import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kompak_app/core/di/injection.dart';
import 'package:kompak_app/features/auth/data/models/login_request.dart';
import 'package:kompak_app/features/auth/data/models/register_request.dart';
import 'package:kompak_app/features/auth/data/models/registration_receipt.dart';
import 'package:kompak_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:kompak_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:kompak_app/features/auth/domain/usecases/register_usecase.dart';
import 'package:kompak_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:kompak_app/features/auth/presentation/pages/register_page.dart';

class _FakeAuthRepository implements AuthRepository {
  @override
  Future<bool> isLoggedIn() async => false;

  @override
  Future<void> login(LoginRequest request) async {}

  @override
  Future<void> logout() async {}

  @override
  Future<RegistrationReceipt> register(RegisterRequest request) async {
    return const RegistrationReceipt(
      id: 'resident-1',
      status: 'PENDING',
      role: 'CITIZEN',
    );
  }
}

void main() {
  late _FakeAuthRepository repository;

  setUp(() async {
    await getIt.reset();
    repository = _FakeAuthRepository();
    getIt.registerFactory<AuthBloc>(
      () => AuthBloc(
        LoginUseCase(repository),
        RegisterUseCase(repository),
        repository,
      ),
    );
  });

  tearDown(() async {
    await getIt.reset();
  });

  testWidgets('shows the agreed personal data fields without address', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: RegisterPage()));

    expect(find.text('Nama Lengkap'), findsOneWidget);
    expect(find.text('Nomor WhatsApp'), findsOneWidget);
    expect(find.text('Email Aktif'), findsOneWidget);
    expect(find.text('Tanggal Lahir'), findsOneWidget);
    expect(find.text('Buat Password'), findsOneWidget);
    expect(find.text('Konfirmasi Password'), findsOneWidget);
    expect(find.textContaining('Alamat Domisili'), findsNothing);
    expect(find.text('Lanjut ke pemindaian wajah'), findsOneWidget);
  });

  testWidgets(
    'keeps the user on personal data when required fields are empty',
    (tester) async {
      await tester.pumpWidget(const MaterialApp(home: RegisterPage()));

      await tester.tap(find.text('Lanjut ke pemindaian wajah'));
      await tester.pump();

      expect(find.text('Nama lengkap wajib diisi'), findsOneWidget);
      expect(find.text('Nomor WhatsApp wajib diisi'), findsOneWidget);
      expect(find.text('Email aktif wajib diisi'), findsOneWidget);
      expect(find.text('Data Diri & Verifikasi'), findsOneWidget);
      expect(find.text('Pemindaian Wajah'), findsNothing);
    },
  );
}
