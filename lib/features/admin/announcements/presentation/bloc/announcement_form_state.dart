import 'package:equatable/equatable.dart';

sealed class AnnouncementFormState extends Equatable {
  const AnnouncementFormState();

  @override
  List<Object?> get props => [];
}

class AnnouncementFormInitial extends AnnouncementFormState {}

class AnnouncementFormSubmitting extends AnnouncementFormState {}

class AnnouncementFormDeleting extends AnnouncementFormState {}

class AnnouncementFormSuccess extends AnnouncementFormState {
  const AnnouncementFormSuccess({required this.deleted});

  final bool deleted;

  @override
  List<Object?> get props => [deleted];
}

class AnnouncementFormFailure extends AnnouncementFormState {
  const AnnouncementFormFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
