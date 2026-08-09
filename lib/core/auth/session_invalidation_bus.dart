import 'dart:async';

import 'package:injectable/injectable.dart';

@lazySingleton
class SessionInvalidationBus {
  final _controller = StreamController<void>.broadcast();

  Stream<void> get stream => _controller.stream;

  void invalidate() => _controller.add(null);

  @disposeMethod
  void dispose() => _controller.close();
}
