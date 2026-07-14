import 'package:injectable/injectable.dart';
import '../routes/app_router.dart';

@module
abstract class RouterModule {
  @singleton
  AppRouter get appRouter => AppRouter();
}
