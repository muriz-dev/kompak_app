import 'package:equatable/equatable.dart';

import '../../domain/entities/admin_provider.dart';

sealed class AdminProvidersState extends Equatable {
  const AdminProvidersState();

  @override
  List<Object?> get props => [];
}

class AdminProvidersLoading extends AdminProvidersState {}

class AdminProvidersLoaded extends AdminProvidersState {
  const AdminProvidersLoaded({
    required this.data,
    required this.query,
    required this.status,
  });

  final AdminProviderPage data;
  final String query;
  final AdminProviderStatus? status;

  @override
  List<Object?> get props => [data, query, status];
}

class AdminProvidersFailure extends AdminProvidersState {
  const AdminProvidersFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
