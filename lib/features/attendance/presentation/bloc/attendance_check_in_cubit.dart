import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/attendance_check_in.dart';
import '../../domain/repositories/attendance_repository.dart';

@injectable
class AttendanceCheckInCubit extends Cubit<AttendanceCheckInState> {
  AttendanceCheckInCubit(this._repository)
    : super(const AttendanceCheckInInitial());

  final AttendanceRepository _repository;

  Future<void> submit({
    required String eventId,
    required String faceImagePath,
    required double latitude,
    required double longitude,
    String? activityPhotoPath,
    String activityDescription = '',
  }) async {
    emit(const AttendanceCheckInSubmitting());
    try {
      final result = await _repository.checkIn(
        AttendanceCheckInRequest(
          eventId: eventId,
          latitude: latitude,
          longitude: longitude,
          faceImagePath: faceImagePath,
          activityPhotoPath: activityPhotoPath,
          activityDescription: activityDescription,
        ),
      );
      emit(AttendanceCheckInSuccess(result));
    } catch (error) {
      emit(AttendanceCheckInFailure(error.toString()));
    }
  }

  void reset() => emit(const AttendanceCheckInInitial());
}

sealed class AttendanceCheckInState extends Equatable {
  const AttendanceCheckInState();

  @override
  List<Object?> get props => [];
}

class AttendanceCheckInInitial extends AttendanceCheckInState {
  const AttendanceCheckInInitial();
}

class AttendanceCheckInSubmitting extends AttendanceCheckInState {
  const AttendanceCheckInSubmitting();
}

class AttendanceCheckInSuccess extends AttendanceCheckInState {
  const AttendanceCheckInSuccess(this.result);

  final AttendanceCheckInResult result;

  @override
  List<Object?> get props => [result];
}

class AttendanceCheckInFailure extends AttendanceCheckInState {
  const AttendanceCheckInFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
