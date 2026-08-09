import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kompak_app/core/di/injection.dart';
import 'package:kompak_app/core/theme/app_theme.dart';
import 'package:kompak_app/features/auth/data/models/login_request.dart';
import 'package:kompak_app/features/auth/data/models/register_request.dart';
import 'package:kompak_app/features/auth/data/models/registration_receipt.dart';
import 'package:kompak_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:kompak_app/features/auth/domain/entities/session_user.dart';
import 'package:kompak_app/features/auth/domain/usecases/register_usecase.dart';
import 'package:kompak_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:kompak_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:kompak_app/features/auth/presentation/pages/register_page.dart';

class _FakeAuthRepository implements AuthRepository {
  @override
  Future<SessionUser?> restoreSession() async => null;

  @override
  Future<SessionUser> login(LoginRequest request) => throw UnimplementedError();

  @override
  Future<SessionUser?> refreshSession() => throw UnimplementedError();

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
  late AuthBloc authBloc;

  setUp(() async {
    await getIt.reset();
    repository = _FakeAuthRepository();
    getIt.registerFactory<AuthBloc>(() {
      authBloc = AuthBloc(RegisterUseCase(repository));
      return authBloc;
    });
  });

  tearDown(() async {
    await getIt.reset();
  });

  testWidgets('shows the agreed personal data fields without address', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const RegisterPage()),
    );

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
      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.light, home: const RegisterPage()),
      );

      await tester.tap(find.text('Lanjut ke pemindaian wajah'));
      await tester.pump();

      expect(find.text('Nama lengkap wajib diisi'), findsOneWidget);
      expect(find.text('Nomor WhatsApp wajib diisi'), findsOneWidget);
      expect(find.text('Email aktif wajib diisi'), findsOneWidget);
      expect(find.text('Data Diri & Verifikasi'), findsOneWidget);
      expect(find.text('Pemindaian Wajah'), findsNothing);
    },
  );

  testWidgets('shows registration success as the Figma modal', (tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const RegisterPage()),
    );

    authBloc.add(
      const RegisterSubmitted(
        RegisterRequest(
          name: 'Subowo',
          phoneNumber: '081234567890',
          email: 'subowo@example.com',
          birthDate: '1996-06-06',
          password: 'password',
          faceImagePath: '/tmp/face.jpg',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('registration-success-dialog')),
      findsOneWidget,
    );
    expect(find.text('Berhasil Terdaftar'), findsOneWidget);
    expect(find.text('Login Sekarang'), findsOneWidget);
    expect(find.text('Pendaftaran Terkirim'), findsNothing);
    expect(find.text('Menunggu persetujuan'), findsNothing);
  });
}
