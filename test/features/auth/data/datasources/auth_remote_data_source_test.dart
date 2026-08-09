import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kompak_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:kompak_app/features/auth/data/models/register_request.dart';

class _CapturingAdapter implements HttpClientAdapter {
  RequestOptions? request;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    request = options;
    return ResponseBody.fromString(
      '''{"success":true,"data":{"id":"resident-1","status":"PENDING","role":"CITIZEN"}}''',
      201,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }
}

void main() {
  test('sends registration as multipart with a face image', () async {
    final tempDirectory = await Directory.systemTemp.createTemp(
      'kompak-register-test-',
    );
    addTearDown(() => tempDirectory.delete(recursive: true));
    final faceImage = File('${tempDirectory.path}/face.jpg');
    await faceImage.writeAsBytes([0xFF, 0xD8, 0xFF, 0xD9]);

    final adapter = _CapturingAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://kompak.test'))
      ..httpClientAdapter = adapter;
    final dataSource = AuthRemoteDataSourceImpl(dio);

    final receipt = await dataSource.register(
      RegisterRequest(
        name: 'Olivia Rhye',
        phoneNumber: '081234567890',
        email: 'olivia@example.com',
        birthDate: '1995-06-12',
        password: 'secret123',
        faceImagePath: faceImage.path,
      ),
    );

    expect(adapter.request?.path, '/users/register');
    expect(adapter.request?.contentType, startsWith('multipart/form-data'));
    final form = adapter.request?.data as FormData;
    expect(Map.fromEntries(form.fields), {
      'name': 'Olivia Rhye',
      'phoneNumber': '081234567890',
      'email': 'olivia@example.com',
      'birthDate': '1995-06-12',
      'password': 'secret123',
    });
    expect(form.files.single.key, 'faceImage');
    expect(form.files.single.value.contentType.toString(), 'image/jpeg');
    expect(receipt.status, 'PENDING');
  });
}
