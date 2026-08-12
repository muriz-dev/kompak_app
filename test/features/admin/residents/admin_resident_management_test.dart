import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kompak_app/core/theme/app_theme.dart';
import 'package:kompak_app/features/admin/residents/data/datasources/admin_residents_remote_data_source.dart';
import 'package:kompak_app/features/admin/residents/data/repositories/admin_residents_repository_impl.dart';
import 'package:kompak_app/features/admin/residents/domain/entities/resident.dart';
import 'package:kompak_app/features/admin/residents/presentation/bloc/admin_resident_form_cubit.dart';
import 'package:kompak_app/features/admin/residents/presentation/pages/admin_resident_detail_page.dart';
import 'package:kompak_app/features/admin/residents/presentation/pages/admin_resident_form_page.dart';

void main() {
  late _ResidentManagementAdapter adapter;
  late AdminResidentsRepositoryImpl repository;

  setUp(() {
    adapter = _ResidentManagementAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'http://kompak.test'))
      ..httpClientAdapter = adapter;
    repository = AdminResidentsRepositoryImpl(
      AdminResidentsRemoteDataSourceImpl(dio),
    );
  });

  test(
    'uses the resident detail, edit, create, and deactivate contracts',
    () async {
      final resident = await repository.getResident('resident-1');
      expect(resident.name, 'Siti Rahma');
      expect(adapter.requests.last.path, '/users/resident-1');

      final updated = await repository.updateResident(
        residentId: resident.id,
        name: 'Siti Rahmawati',
        phoneNumber: '081211112222',
        birthDate: '1994-10-08',
        email: 'siti.baru@example.com',
      );
      expect(updated.name, 'Siti Rahmawati');
      expect(adapter.requests.last.method, 'PATCH');

      final inactive = await repository.updateStatus(
        resident.id,
        ResidentStatus.inactive,
      );
      expect(inactive.status, ResidentStatus.inactive);
      expect(adapter.requests.last.data, {'status': 'INACTIVE'});

      final directory = await Directory.systemTemp.createTemp(
        'kompak-resident-test-',
      );
      addTearDown(() => directory.delete(recursive: true));
      final face = File('${directory.path}/face.jpg');
      await face.writeAsBytes([0xFF, 0xD8, 0xFF, 0xD9]);

      final created = await repository.createResident(
        name: 'Warga Baru',
        phoneNumber: '081233344455',
        birthDate: '1998-03-12',
        email: 'baru@example.com',
        password: 'rahasia123',
        faceImagePath: face.path,
      );
      expect(created.status, ResidentStatus.active);
      final form = adapter.requests.last.data as FormData;
      expect(form.fields.toMap()['email'], 'baru@example.com');
      expect(form.files.single.key, 'faceImage');
    },
  );

  testWidgets('renders resident detail actions on a narrow phone', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 700);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    var edited = false;
    ResidentStatus? requestedStatus;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: AdminResidentDetailView(
            resident: adapter.resident,
            updatingStatus: false,
            onRefresh: () async {},
            onEdit: () => edited = true,
            onStatusChange: (status) => requestedStatus = status,
          ),
        ),
      ),
    );

    expect(find.text('Siti Rahma'), findsOneWidget);
    expect(find.text('siti@example.com'), findsOneWidget);
    expect(find.text('Saldo Poin'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.drag(
      find.byKey(const ValueKey('admin-resident-detail-scroll')),
      const Offset(0, -500),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('edit-resident-button')));
    expect(edited, isTrue);

    await tester.ensureVisible(
      find.byKey(const ValueKey('deactivate-resident-button')),
    );
    await tester.tap(find.byKey(const ValueKey('deactivate-resident-button')));
    expect(requestedStatus, ResidentStatus.inactive);
  });

  testWidgets('prefills and submits the resident edit form', (tester) async {
    var completed = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: BlocProvider(
          create: (_) => AdminResidentFormCubit(repository),
          child: AdminResidentFormView(
            resident: adapter.resident,
            onComplete: () => completed = true,
          ),
        ),
      ),
    );

    expect(
      tester
          .widget<TextFormField>(
            find.byKey(const ValueKey('resident-name-field')),
          )
          .controller
          ?.text,
      'Siti Rahma',
    );
    await tester.enterText(
      find.byKey(const ValueKey('resident-name-field')),
      'Siti Rahmawati',
    );
    await tester.tap(find.byKey(const ValueKey('save-resident-button')));
    await tester.pumpAndSettle();

    expect(completed, isTrue);
    expect(adapter.resident.name, 'Siti Rahmawati');
    expect(
      adapter.requests.any(
        (request) =>
            request.method == 'PATCH' && request.path == '/users/resident-1',
      ),
      isTrue,
    );
  });
}

extension on List<MapEntry<String, String>> {
  Map<String, String> toMap() => Map.fromEntries(this);
}

class _ResidentManagementAdapter implements HttpClientAdapter {
  Map<String, dynamic> data = {
    'id': 'resident-1',
    'name': 'Siti Rahma',
    'phoneNumber': '+6281298765432',
    'birthDate': '1994-10-08',
    'email': 'siti@example.com',
    'balance': 850,
    'leaderboardPoints': 55,
    'status': 'ACTIVE',
    'role': 'CITIZEN',
  };

  final requests = <RequestOptions>[];

  Resident get resident => Resident.fromJson(data);

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);

    if (options.method == 'GET' && options.path == '/users/resident-1') {
      return _response({'success': true, 'data': data}, 200);
    }

    if (options.method == 'PATCH' &&
        options.path == '/users/resident-1/status') {
      final body = Map<String, dynamic>.from(options.data as Map);
      data = {...data, 'status': body['status']};
      return _response({'success': true, 'data': data}, 200);
    }

    if (options.method == 'PATCH' && options.path == '/users/resident-1') {
      data = {...data, ...Map<String, dynamic>.from(options.data as Map)};
      return _response({'success': true, 'data': data}, 200);
    }

    if (options.method == 'POST' && options.path == '/users') {
      final form = options.data as FormData;
      final fields = form.fields.toMap();
      return _response({
        'success': true,
        'data': {
          'id': 'resident-new',
          'name': fields['name'],
          'phoneNumber': fields['phoneNumber'],
          'birthDate': fields['birthDate'],
          'email': fields['email'],
          'balance': 0,
          'leaderboardPoints': 0,
          'status': 'ACTIVE',
          'role': 'CITIZEN',
        },
      }, 201);
    }

    return _response({'success': false, 'message': 'Not found'}, 404);
  }

  ResponseBody _response(Map<String, dynamic> body, int status) {
    return ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }
}
