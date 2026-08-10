// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

/// generated route for
/// [ActivityDetailPage]
class ActivityDetailRoute extends PageRouteInfo<ActivityDetailRouteArgs> {
  ActivityDetailRoute({
    required String eventId,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
         ActivityDetailRoute.name,
         args: ActivityDetailRouteArgs(eventId: eventId, key: key),
         rawPathParams: {'eventId': eventId},
         initialChildren: children,
       );

  static const String name = 'ActivityDetailRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<ActivityDetailRouteArgs>(
        orElse: () =>
            ActivityDetailRouteArgs(eventId: pathParams.getString('eventId')),
      );
      return ActivityDetailPage(eventId: args.eventId, key: args.key);
    },
  );
}

class ActivityDetailRouteArgs {
  const ActivityDetailRouteArgs({required this.eventId, this.key});

  final String eventId;

  final Key? key;

  @override
  String toString() {
    return 'ActivityDetailRouteArgs{eventId: $eventId, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ActivityDetailRouteArgs) return false;
    return eventId == other.eventId && key == other.key;
  }

  @override
  int get hashCode => eventId.hashCode ^ key.hashCode;
}

/// generated route for
/// [AdminEventDetailPage]
class AdminEventDetailRoute extends PageRouteInfo<AdminEventDetailRouteArgs> {
  AdminEventDetailRoute({
    required String eventId,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
         AdminEventDetailRoute.name,
         args: AdminEventDetailRouteArgs(eventId: eventId, key: key),
         rawPathParams: {'eventId': eventId},
         initialChildren: children,
       );

  static const String name = 'AdminEventDetailRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<AdminEventDetailRouteArgs>(
        orElse: () =>
            AdminEventDetailRouteArgs(eventId: pathParams.getString('eventId')),
      );
      return AdminEventDetailPage(eventId: args.eventId, key: args.key);
    },
  );
}

class AdminEventDetailRouteArgs {
  const AdminEventDetailRouteArgs({required this.eventId, this.key});

  final String eventId;

  final Key? key;

  @override
  String toString() {
    return 'AdminEventDetailRouteArgs{eventId: $eventId, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AdminEventDetailRouteArgs) return false;
    return eventId == other.eventId && key == other.key;
  }

  @override
  int get hashCode => eventId.hashCode ^ key.hashCode;
}

/// generated route for
/// [AdminEventsPage]
class AdminEventsRoute extends PageRouteInfo<void> {
  const AdminEventsRoute({List<PageRouteInfo>? children})
    : super(AdminEventsRoute.name, initialChildren: children);

  static const String name = 'AdminEventsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const AdminEventsPage();
    },
  );
}

/// generated route for
/// [AdminResidentsPage]
class AdminResidentsRoute extends PageRouteInfo<void> {
  const AdminResidentsRoute({List<PageRouteInfo>? children})
    : super(AdminResidentsRoute.name, initialChildren: children);

  static const String name = 'AdminResidentsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const AdminResidentsPage();
    },
  );
}

/// generated route for
/// [AttendancePage]
class AttendanceRoute extends PageRouteInfo<void> {
  const AttendanceRoute({List<PageRouteInfo>? children})
    : super(AttendanceRoute.name, initialChildren: children);

  static const String name = 'AttendanceRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const AttendancePage();
    },
  );
}

/// generated route for
/// [BlockedAccountPage]
class BlockedAccountRoute extends PageRouteInfo<void> {
  const BlockedAccountRoute({List<PageRouteInfo>? children})
    : super(BlockedAccountRoute.name, initialChildren: children);

  static const String name = 'BlockedAccountRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const BlockedAccountPage();
    },
  );
}

/// generated route for
/// [CreateEventPage]
class CreateEventRoute extends PageRouteInfo<CreateEventRouteArgs> {
  CreateEventRoute({
    Key? key,
    EventLocationSelection? initialLocation,
    List<PageRouteInfo>? children,
  }) : super(
         CreateEventRoute.name,
         args: CreateEventRouteArgs(key: key, initialLocation: initialLocation),
         initialChildren: children,
       );

  static const String name = 'CreateEventRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<CreateEventRouteArgs>(
        orElse: () => const CreateEventRouteArgs(),
      );
      return CreateEventPage(
        key: args.key,
        initialLocation: args.initialLocation,
      );
    },
  );
}

class CreateEventRouteArgs {
  const CreateEventRouteArgs({this.key, this.initialLocation});

  final Key? key;

  final EventLocationSelection? initialLocation;

  @override
  String toString() {
    return 'CreateEventRouteArgs{key: $key, initialLocation: $initialLocation}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CreateEventRouteArgs) return false;
    return key == other.key && initialLocation == other.initialLocation;
  }

  @override
  int get hashCode => key.hashCode ^ initialLocation.hashCode;
}

/// generated route for
/// [EditEventPage]
class EditEventRoute extends PageRouteInfo<EditEventRouteArgs> {
  EditEventRoute({
    required AdminEvent event,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
         EditEventRoute.name,
         args: EditEventRouteArgs(event: event, key: key),
         initialChildren: children,
       );

  static const String name = 'EditEventRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<EditEventRouteArgs>();
      return EditEventPage(event: args.event, key: args.key);
    },
  );
}

class EditEventRouteArgs {
  const EditEventRouteArgs({required this.event, this.key});

  final AdminEvent event;

  final Key? key;

  @override
  String toString() {
    return 'EditEventRouteArgs{event: $event, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! EditEventRouteArgs) return false;
    return event == other.event && key == other.key;
  }

  @override
  int get hashCode => event.hashCode ^ key.hashCode;
}

/// generated route for
/// [EventLocationPickerPage]
class EventLocationPickerRoute
    extends PageRouteInfo<EventLocationPickerRouteArgs> {
  EventLocationPickerRoute({
    Key? key,
    double? initialLatitude,
    double? initialLongitude,
    EventLocationService locationService =
        const GeolocatorEventLocationService(),
    List<PageRouteInfo>? children,
  }) : super(
         EventLocationPickerRoute.name,
         args: EventLocationPickerRouteArgs(
           key: key,
           initialLatitude: initialLatitude,
           initialLongitude: initialLongitude,
           locationService: locationService,
         ),
         initialChildren: children,
       );

  static const String name = 'EventLocationPickerRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<EventLocationPickerRouteArgs>(
        orElse: () => const EventLocationPickerRouteArgs(),
      );
      return EventLocationPickerPage(
        key: args.key,
        initialLatitude: args.initialLatitude,
        initialLongitude: args.initialLongitude,
        locationService: args.locationService,
      );
    },
  );
}

class EventLocationPickerRouteArgs {
  const EventLocationPickerRouteArgs({
    this.key,
    this.initialLatitude,
    this.initialLongitude,
    this.locationService = const GeolocatorEventLocationService(),
  });

  final Key? key;

  final double? initialLatitude;

  final double? initialLongitude;

  final EventLocationService locationService;

  @override
  String toString() {
    return 'EventLocationPickerRouteArgs{key: $key, initialLatitude: $initialLatitude, initialLongitude: $initialLongitude, locationService: $locationService}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! EventLocationPickerRouteArgs) return false;
    return key == other.key &&
        initialLatitude == other.initialLatitude &&
        initialLongitude == other.initialLongitude &&
        locationService == other.locationService;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      initialLatitude.hashCode ^
      initialLongitude.hashCode ^
      locationService.hashCode;
}

/// generated route for
/// [ForgotPasswordPage]
class ForgotPasswordRoute extends PageRouteInfo<void> {
  const ForgotPasswordRoute({List<PageRouteInfo>? children})
    : super(ForgotPasswordRoute.name, initialChildren: children);

  static const String name = 'ForgotPasswordRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ForgotPasswordPage();
    },
  );
}

/// generated route for
/// [HomePage]
class HomeRoute extends PageRouteInfo<void> {
  const HomeRoute({List<PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const HomePage();
    },
  );
}

/// generated route for
/// [LeaderboardPage]
class LeaderboardRoute extends PageRouteInfo<void> {
  const LeaderboardRoute({List<PageRouteInfo>? children})
    : super(LeaderboardRoute.name, initialChildren: children);

  static const String name = 'LeaderboardRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const LeaderboardPage();
    },
  );
}

/// generated route for
/// [LoginPage]
class LoginRoute extends PageRouteInfo<void> {
  const LoginRoute({List<PageRouteInfo>? children})
    : super(LoginRoute.name, initialChildren: children);

  static const String name = 'LoginRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const LoginPage();
    },
  );
}

/// generated route for
/// [MainPage]
class MainRoute extends PageRouteInfo<void> {
  const MainRoute({List<PageRouteInfo>? children})
    : super(MainRoute.name, initialChildren: children);

  static const String name = 'MainRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const MainPage();
    },
  );
}

/// generated route for
/// [NotificationPage]
class NotificationRoute extends PageRouteInfo<void> {
  const NotificationRoute({List<PageRouteInfo>? children})
    : super(NotificationRoute.name, initialChildren: children);

  static const String name = 'NotificationRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const NotificationPage();
    },
  );
}

/// generated route for
/// [PendingApprovalPage]
class PendingApprovalRoute extends PageRouteInfo<void> {
  const PendingApprovalRoute({List<PageRouteInfo>? children})
    : super(PendingApprovalRoute.name, initialChildren: children);

  static const String name = 'PendingApprovalRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const PendingApprovalPage();
    },
  );
}

/// generated route for
/// [PointHistoryPage]
class PointHistoryRoute extends PageRouteInfo<void> {
  const PointHistoryRoute({List<PageRouteInfo>? children})
    : super(PointHistoryRoute.name, initialChildren: children);

  static const String name = 'PointHistoryRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const PointHistoryPage();
    },
  );
}

/// generated route for
/// [ProfilePage]
class ProfileRoute extends PageRouteInfo<void> {
  const ProfileRoute({List<PageRouteInfo>? children})
    : super(ProfileRoute.name, initialChildren: children);

  static const String name = 'ProfileRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ProfilePage();
    },
  );
}

/// generated route for
/// [RedeemConfirmationPage]
class RedeemConfirmationRoute
    extends PageRouteInfo<RedeemConfirmationRouteArgs> {
  RedeemConfirmationRoute({
    Key? key,
    required StoreItem item,
    List<PageRouteInfo>? children,
  }) : super(
         RedeemConfirmationRoute.name,
         args: RedeemConfirmationRouteArgs(key: key, item: item),
         initialChildren: children,
       );

  static const String name = 'RedeemConfirmationRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<RedeemConfirmationRouteArgs>();
      return RedeemConfirmationPage(key: args.key, item: args.item);
    },
  );
}

class RedeemConfirmationRouteArgs {
  const RedeemConfirmationRouteArgs({this.key, required this.item});

  final Key? key;

  final StoreItem item;

  @override
  String toString() {
    return 'RedeemConfirmationRouteArgs{key: $key, item: $item}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! RedeemConfirmationRouteArgs) return false;
    return key == other.key && item == other.item;
  }

  @override
  int get hashCode => key.hashCode ^ item.hashCode;
}

/// generated route for
/// [RegisterPage]
class RegisterRoute extends PageRouteInfo<void> {
  const RegisterRoute({List<PageRouteInfo>? children})
    : super(RegisterRoute.name, initialChildren: children);

  static const String name = 'RegisterRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const RegisterPage();
    },
  );
}

/// generated route for
/// [RejectedAccountPage]
class RejectedAccountRoute extends PageRouteInfo<void> {
  const RejectedAccountRoute({List<PageRouteInfo>? children})
    : super(RejectedAccountRoute.name, initialChildren: children);

  static const String name = 'RejectedAccountRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const RejectedAccountPage();
    },
  );
}

/// generated route for
/// [ResetPasswordPage]
class ResetPasswordRoute extends PageRouteInfo<void> {
  const ResetPasswordRoute({List<PageRouteInfo>? children})
    : super(ResetPasswordRoute.name, initialChildren: children);

  static const String name = 'ResetPasswordRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ResetPasswordPage();
    },
  );
}

/// generated route for
/// [SessionGatePage]
class SessionGateRoute extends PageRouteInfo<void> {
  const SessionGateRoute({List<PageRouteInfo>? children})
    : super(SessionGateRoute.name, initialChildren: children);

  static const String name = 'SessionGateRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SessionGatePage();
    },
  );
}

/// generated route for
/// [StorePage]
class StoreRoute extends PageRouteInfo<void> {
  const StoreRoute({List<PageRouteInfo>? children})
    : super(StoreRoute.name, initialChildren: children);

  static const String name = 'StoreRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const StorePage();
    },
  );
}
