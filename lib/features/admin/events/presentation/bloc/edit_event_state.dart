import 'package:equatable/equatable.dart';

import '../../domain/entities/admin_event.dart';

sealed class EditEventState extends Equatable {
  const EditEventState();

  @override
  List<Object?> get props => [];
}

class EditEventInitial extends EditEventState {
  const EditEventInitial();
}

class EditEventSubmitting extends EditEventState {
  const EditEventSubmitting();
}

class EditEventSuccess extends EditEventState {
  const EditEventSuccess(this.event);

  final AdminEvent event;

  @override
  List<Object> get props => [event];
}

class EditEventDeleting extends EditEventState {
  const EditEventDeleting();
}

class EditEventDeleted extends EditEventState {
  const EditEventDeleted();
}

class EditEventFailure extends EditEventState {
  const EditEventFailure(this.message);

  final String message;

  @override
  List<Object> get props => [message];
}
