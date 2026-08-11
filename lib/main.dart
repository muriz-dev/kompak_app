import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di/injection.dart';
import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/session/session_cubit.dart';
import 'features/auth/presentation/session/session_navigation.dart';
import 'features/auth/presentation/session/session_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await configureDependencies();

  final sessionCubit = getIt<SessionCubit>();
  runApp(
    BlocProvider.value(
      value: sessionCubit,
      child: MainApp(appRouter: getIt<AppRouter>()),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({required this.appRouter, super.key});

  final AppRouter appRouter;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: appRouter.config(),
      theme: AppTheme.light,
      builder: (context, child) => BlocListener<SessionCubit, SessionState>(
        listenWhen: (previous, current) =>
            routesForSession(current) != null &&
            previous.runtimeType != current.runtimeType,
        listener: (context, state) {
          final routes = routesForSession(state);
          if (routes != null) appRouter.replaceAll(routes);
        },
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}
