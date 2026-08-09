// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

import '../../features/attendance/presentation/bloc/attendance_cubit.dart'
    as _i1;
import '../../features/auth/data/datasources/auth_remote_data_source.dart'
    as _i107;
import '../../features/auth/data/repositories/auth_repository_impl.dart'
    as _i153;
import '../../features/auth/domain/repositories/auth_repository.dart' as _i787;
import '../../features/auth/domain/usecases/login_usecase.dart' as _i188;
import '../../features/auth/domain/usecases/register_usecase.dart' as _i941;
import '../../features/auth/presentation/bloc/auth_bloc.dart' as _i797;
import '../../features/auth/presentation/session/session_cubit.dart' as _i371;
import '../../features/home/presentation/bloc/home_cubit.dart' as _i816;
import '../../features/leaderboard/presentation/bloc/leaderboard_cubit.dart'
    as _i100;
import '../../features/store/presentation/bloc/store_cubit.dart' as _i487;
import '../auth/session_invalidation_bus.dart' as _i875;
import '../auth/session_token_store.dart' as _i1016;
import '../network/dio_module.dart' as _i614;
import '../routes/app_router.dart' as _i629;
import 'router_model.dart' as _i553;
import 'secure_storage_module.dart' as _i897;
import 'shared_prefs_module.dart' as _i295;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final sharedPrefsModule = _$SharedPrefsModule();
    final secureStorageModule = _$SecureStorageModule();
    final dioModule = _$DioModule();
    final routerModule = _$RouterModule();
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => sharedPrefsModule.prefs,
      preResolve: true,
    );
    gh.factory<_i1.AttendanceCubit>(() => _i1.AttendanceCubit());
    gh.factory<_i816.HomeCubit>(() => _i816.HomeCubit());
    gh.factory<_i100.LeaderboardCubit>(() => _i100.LeaderboardCubit());
    gh.factory<_i487.StoreCubit>(() => _i487.StoreCubit());
    gh.lazySingleton<_i875.SessionInvalidationBus>(
      () => _i875.SessionInvalidationBus(),
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i558.FlutterSecureStorage>(
      () => secureStorageModule.storage,
    );
    gh.lazySingleton<_i1016.SessionTokenStore>(
      () => _i1016.SecureSessionTokenStore(
        gh<_i558.FlutterSecureStorage>(),
        gh<_i460.SharedPreferences>(),
      ),
    );
    gh.lazySingleton<_i361.Dio>(
      () => dioModule.dio(
        gh<_i1016.SessionTokenStore>(),
        gh<_i875.SessionInvalidationBus>(),
      ),
    );
    gh.lazySingleton<_i107.AuthRemoteDataSource>(
      () => _i107.AuthRemoteDataSourceImpl(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i787.AuthRepository>(
      () => _i153.AuthRepositoryImpl(
        gh<_i107.AuthRemoteDataSource>(),
        gh<_i1016.SessionTokenStore>(),
      ),
    );
    gh.lazySingleton<_i188.LoginUseCase>(
      () => _i188.LoginUseCase(gh<_i787.AuthRepository>()),
    );
    gh.lazySingleton<_i941.RegisterUseCase>(
      () => _i941.RegisterUseCase(gh<_i787.AuthRepository>()),
    );
    gh.factory<_i797.AuthBloc>(
      () => _i797.AuthBloc(gh<_i941.RegisterUseCase>()),
    );
    gh.lazySingleton<_i371.SessionCubit>(
      () => _i371.SessionCubit(
        gh<_i787.AuthRepository>(),
        gh<_i875.SessionInvalidationBus>(),
      ),
    );
    gh.singleton<_i629.AppRouter>(
      () => routerModule.appRouter(gh<_i371.SessionCubit>()),
    );
    return this;
  }
}

class _$SharedPrefsModule extends _i295.SharedPrefsModule {}

class _$SecureStorageModule extends _i897.SecureStorageModule {}

class _$DioModule extends _i614.DioModule {}

class _$RouterModule extends _i553.RouterModule {}
