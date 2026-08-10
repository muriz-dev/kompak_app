import 'package:equatable/equatable.dart';

import '../../domain/entities/admin_event_overview.dart';

sealed class AdminEventDetailState extends Equatable {
  const AdminEventDetailState();

  @override
  List<Object?> get props => [];
}

class AdminEventDetailLoading extends AdminEventDetailState {
  const AdminEventDetailLoading();
}

class AdminEventDetailLoaded extends AdminEventDetailState {
  const AdminEventDetailLoaded(this.overview);

  final AdminEventOverview overview;

  @override
  List<Object> get props => [overview];
}

class AdminEventDetailFailure extends AdminEventDetailState {
  const AdminEventDetailFailure(this.message);

  final String message;

  @override
  List<Object> get props => [message];
}
