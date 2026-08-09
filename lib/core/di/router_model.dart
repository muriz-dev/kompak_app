import 'package:injectable/injectable.dart';
import '../routes/app_router.dart';
import '../../features/auth/presentation/session/session_cubit.dart';

@module
abstract class RouterModule {
  @singleton
  AppRouter appRouter(SessionCubit sessionCubit) => AppRouter(sessionCubit);
}
