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
/// [AdminAnnouncementsPage]
class AdminAnnouncementsRoute extends PageRouteInfo<void> {
  const AdminAnnouncementsRoute({List<PageRouteInfo>? children})
    : super(AdminAnnouncementsRoute.name, initialChildren: children);

  static const String name = 'AdminAnnouncementsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const AdminAnnouncementsPage();
    },
  );
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
/// [AdminLeaderboardRewardFormPage]
class AdminLeaderboardRewardFormRoute
    extends PageRouteInfo<AdminLeaderboardRewardFormRouteArgs> {
  AdminLeaderboardRewardFormRoute({
    required int position,
    AdminLeaderboardReward? reward,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
         AdminLeaderboardRewardFormRoute.name,
         args: AdminLeaderboardRewardFormRouteArgs(
           position: position,
           reward: reward,
           key: key,
         ),
         initialChildren: children,
       );

  static const String name = 'AdminLeaderboardRewardFormRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<AdminLeaderboardRewardFormRouteArgs>();
      return AdminLeaderboardRewardFormPage(
        position: args.position,
        reward: args.reward,
        key: args.key,
      );
    },
  );
}

class AdminLeaderboardRewardFormRouteArgs {
  const AdminLeaderboardRewardFormRouteArgs({
    required this.position,
    this.reward,
    this.key,
  });

  final int position;

  final AdminLeaderboardReward? reward;

  final Key? key;

  @override
  String toString() {
    return 'AdminLeaderboardRewardFormRouteArgs{position: $position, reward: $reward, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AdminLeaderboardRewardFormRouteArgs) return false;
    return position == other.position &&
        reward == other.reward &&
        key == other.key;
  }

  @override
  int get hashCode => position.hashCode ^ reward.hashCode ^ key.hashCode;
}

/// generated route for
/// [AdminLeaderboardRewardPickerPage]
class AdminLeaderboardRewardPickerRoute extends PageRouteInfo<void> {
  const AdminLeaderboardRewardPickerRoute({List<PageRouteInfo>? children})
    : super(AdminLeaderboardRewardPickerRoute.name, initialChildren: children);

  static const String name = 'AdminLeaderboardRewardPickerRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const AdminLeaderboardRewardPickerPage();
    },
  );
}

/// generated route for
/// [AdminLeaderboardRewardsPage]
class AdminLeaderboardRewardsRoute extends PageRouteInfo<void> {
  const AdminLeaderboardRewardsRoute({List<PageRouteInfo>? children})
    : super(AdminLeaderboardRewardsRoute.name, initialChildren: children);

  static const String name = 'AdminLeaderboardRewardsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const AdminLeaderboardRewardsPage();
    },
  );
}

/// generated route for
/// [AdminPointShopAddPage]
class AdminPointShopAddRoute extends PageRouteInfo<AdminPointShopAddRouteArgs> {
  AdminPointShopAddRoute({
    String? providerId,
    String? providerName,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
         AdminPointShopAddRoute.name,
         args: AdminPointShopAddRouteArgs(
           providerId: providerId,
           providerName: providerName,
           key: key,
         ),
         initialChildren: children,
       );

  static const String name = 'AdminPointShopAddRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<AdminPointShopAddRouteArgs>(
        orElse: () => const AdminPointShopAddRouteArgs(),
      );
      return AdminPointShopAddPage(
        providerId: args.providerId,
        providerName: args.providerName,
        key: args.key,
      );
    },
  );
}

class AdminPointShopAddRouteArgs {
  const AdminPointShopAddRouteArgs({
    this.providerId,
    this.providerName,
    this.key,
  });

  final String? providerId;

  final String? providerName;

  final Key? key;

  @override
  String toString() {
    return 'AdminPointShopAddRouteArgs{providerId: $providerId, providerName: $providerName, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AdminPointShopAddRouteArgs) return false;
    return providerId == other.providerId &&
        providerName == other.providerName &&
        key == other.key;
  }

  @override
  int get hashCode =>
      providerId.hashCode ^ providerName.hashCode ^ key.hashCode;
}

/// generated route for
/// [AdminPointShopPage]
class AdminPointShopRoute extends PageRouteInfo<AdminPointShopRouteArgs> {
  AdminPointShopRoute({
    String? providerId,
    String? providerName,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
         AdminPointShopRoute.name,
         args: AdminPointShopRouteArgs(
           providerId: providerId,
           providerName: providerName,
           key: key,
         ),
         initialChildren: children,
       );

  static const String name = 'AdminPointShopRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<AdminPointShopRouteArgs>(
        orElse: () => const AdminPointShopRouteArgs(),
      );
      return AdminPointShopPage(
        providerId: args.providerId,
        providerName: args.providerName,
        key: args.key,
      );
    },
  );
}

class AdminPointShopRouteArgs {
  const AdminPointShopRouteArgs({this.providerId, this.providerName, this.key});

  final String? providerId;

  final String? providerName;

  final Key? key;

  @override
  String toString() {
    return 'AdminPointShopRouteArgs{providerId: $providerId, providerName: $providerName, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AdminPointShopRouteArgs) return false;
    return providerId == other.providerId &&
        providerName == other.providerName &&
        key == other.key;
  }

  @override
  int get hashCode =>
      providerId.hashCode ^ providerName.hashCode ^ key.hashCode;
}

/// generated route for
/// [AdminProviderDetailPage]
class AdminProviderDetailRoute
    extends PageRouteInfo<AdminProviderDetailRouteArgs> {
  AdminProviderDetailRoute({
    required String providerId,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
         AdminProviderDetailRoute.name,
         args: AdminProviderDetailRouteArgs(providerId: providerId, key: key),
         rawPathParams: {'providerId': providerId},
         initialChildren: children,
       );

  static const String name = 'AdminProviderDetailRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<AdminProviderDetailRouteArgs>(
        orElse: () => AdminProviderDetailRouteArgs(
          providerId: pathParams.getString('providerId'),
        ),
      );
      return AdminProviderDetailPage(
        providerId: args.providerId,
        key: args.key,
      );
    },
  );
}

class AdminProviderDetailRouteArgs {
  const AdminProviderDetailRouteArgs({required this.providerId, this.key});

  final String providerId;

  final Key? key;

  @override
  String toString() {
    return 'AdminProviderDetailRouteArgs{providerId: $providerId, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AdminProviderDetailRouteArgs) return false;
    return providerId == other.providerId && key == other.key;
  }

  @override
  int get hashCode => providerId.hashCode ^ key.hashCode;
}

/// generated route for
/// [AdminProvidersPage]
class AdminProvidersRoute extends PageRouteInfo<void> {
  const AdminProvidersRoute({List<PageRouteInfo>? children})
    : super(AdminProvidersRoute.name, initialChildren: children);

  static const String name = 'AdminProvidersRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const AdminProvidersPage();
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
/// [AnnouncementFormPage]
class AnnouncementFormRoute extends PageRouteInfo<AnnouncementFormRouteArgs> {
  AnnouncementFormRoute({
    CommunityAnnouncement? announcement,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
         AnnouncementFormRoute.name,
         args: AnnouncementFormRouteArgs(announcement: announcement, key: key),
         initialChildren: children,
       );

  static const String name = 'AnnouncementFormRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<AnnouncementFormRouteArgs>(
        orElse: () => const AnnouncementFormRouteArgs(),
      );
      return AnnouncementFormPage(
        announcement: args.announcement,
        key: args.key,
      );
    },
  );
}

class AnnouncementFormRouteArgs {
  const AnnouncementFormRouteArgs({this.announcement, this.key});

  final CommunityAnnouncement? announcement;

  final Key? key;

  @override
  String toString() {
    return 'AnnouncementFormRouteArgs{announcement: $announcement, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AnnouncementFormRouteArgs) return false;
    return announcement == other.announcement && key == other.key;
  }

  @override
  int get hashCode => announcement.hashCode ^ key.hashCode;
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
/// [AttendanceScannerPage]
class AttendanceScannerRoute extends PageRouteInfo<AttendanceScannerRouteArgs> {
  AttendanceScannerRoute({
    required String eventId,
    String? activityPhotoPath,
    String activityDescription = '',
    AttendanceLocationService locationService =
        const GeolocatorAttendanceLocationService(),
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
         AttendanceScannerRoute.name,
         args: AttendanceScannerRouteArgs(
           eventId: eventId,
           activityPhotoPath: activityPhotoPath,
           activityDescription: activityDescription,
           locationService: locationService,
           key: key,
         ),
         rawPathParams: {'eventId': eventId},
         initialChildren: children,
       );

  static const String name = 'AttendanceScannerRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<AttendanceScannerRouteArgs>(
        orElse: () => AttendanceScannerRouteArgs(
          eventId: pathParams.getString('eventId'),
        ),
      );
      return AttendanceScannerPage(
        eventId: args.eventId,
        activityPhotoPath: args.activityPhotoPath,
        activityDescription: args.activityDescription,
        locationService: args.locationService,
        key: args.key,
      );
    },
  );
}

class AttendanceScannerRouteArgs {
  const AttendanceScannerRouteArgs({
    required this.eventId,
    this.activityPhotoPath,
    this.activityDescription = '',
    this.locationService = const GeolocatorAttendanceLocationService(),
    this.key,
  });

  final String eventId;

  final String? activityPhotoPath;

  final String activityDescription;

  final AttendanceLocationService locationService;

  final Key? key;

  @override
  String toString() {
    return 'AttendanceScannerRouteArgs{eventId: $eventId, activityPhotoPath: $activityPhotoPath, activityDescription: $activityDescription, locationService: $locationService, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AttendanceScannerRouteArgs) return false;
    return eventId == other.eventId &&
        activityPhotoPath == other.activityPhotoPath &&
        activityDescription == other.activityDescription &&
        locationService == other.locationService &&
        key == other.key;
  }

  @override
  int get hashCode =>
      eventId.hashCode ^
      activityPhotoPath.hashCode ^
      activityDescription.hashCode ^
      locationService.hashCode ^
      key.hashCode;
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
    int initialRadiusMeters = EventLocationSelection.defaultRadiusMeters,
    String title = 'Pilih Lokasi',
    bool showRadiusControl = true,
    EventLocationService locationService =
        const GeolocatorEventLocationService(),
    List<PageRouteInfo>? children,
  }) : super(
         EventLocationPickerRoute.name,
         args: EventLocationPickerRouteArgs(
           key: key,
           initialLatitude: initialLatitude,
           initialLongitude: initialLongitude,
           initialRadiusMeters: initialRadiusMeters,
           title: title,
           showRadiusControl: showRadiusControl,
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
        initialRadiusMeters: args.initialRadiusMeters,
        title: args.title,
        showRadiusControl: args.showRadiusControl,
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
    this.initialRadiusMeters = EventLocationSelection.defaultRadiusMeters,
    this.title = 'Pilih Lokasi',
    this.showRadiusControl = true,
    this.locationService = const GeolocatorEventLocationService(),
  });

  final Key? key;

  final double? initialLatitude;

  final double? initialLongitude;

  final int initialRadiusMeters;

  final String title;

  final bool showRadiusControl;

  final EventLocationService locationService;

  @override
  String toString() {
    return 'EventLocationPickerRouteArgs{key: $key, initialLatitude: $initialLatitude, initialLongitude: $initialLongitude, initialRadiusMeters: $initialRadiusMeters, title: $title, showRadiusControl: $showRadiusControl, locationService: $locationService}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! EventLocationPickerRouteArgs) return false;
    return key == other.key &&
        initialLatitude == other.initialLatitude &&
        initialLongitude == other.initialLongitude &&
        initialRadiusMeters == other.initialRadiusMeters &&
        title == other.title &&
        showRadiusControl == other.showRadiusControl &&
        locationService == other.locationService;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      initialLatitude.hashCode ^
      initialLongitude.hashCode ^
      initialRadiusMeters.hashCode ^
      title.hashCode ^
      showRadiusControl.hashCode ^
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
/// [ProviderEntryPage]
class ProviderEntryRoute extends PageRouteInfo<void> {
  const ProviderEntryRoute({List<PageRouteInfo>? children})
    : super(ProviderEntryRoute.name, initialChildren: children);

  static const String name = 'ProviderEntryRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ProviderEntryPage();
    },
  );
}

/// generated route for
/// [ProviderProductFormPage]
class ProviderProductFormRoute
    extends PageRouteInfo<ProviderProductFormRouteArgs> {
  ProviderProductFormRoute({
    required String providerId,
    ProviderProduct? product,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
         ProviderProductFormRoute.name,
         args: ProviderProductFormRouteArgs(
           providerId: providerId,
           product: product,
           key: key,
         ),
         initialChildren: children,
       );

  static const String name = 'ProviderProductFormRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ProviderProductFormRouteArgs>();
      return ProviderProductFormPage(
        providerId: args.providerId,
        product: args.product,
        key: args.key,
      );
    },
  );
}

class ProviderProductFormRouteArgs {
  const ProviderProductFormRouteArgs({
    required this.providerId,
    this.product,
    this.key,
  });

  final String providerId;

  final ProviderProduct? product;

  final Key? key;

  @override
  String toString() {
    return 'ProviderProductFormRouteArgs{providerId: $providerId, product: $product, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ProviderProductFormRouteArgs) return false;
    return providerId == other.providerId &&
        product == other.product &&
        key == other.key;
  }

  @override
  int get hashCode => providerId.hashCode ^ product.hashCode ^ key.hashCode;
}

/// generated route for
/// [ProviderProfilePage]
class ProviderProfileRoute extends PageRouteInfo<ProviderProfileRouteArgs> {
  ProviderProfileRoute({
    required ProviderAccount account,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
         ProviderProfileRoute.name,
         args: ProviderProfileRouteArgs(account: account, key: key),
         initialChildren: children,
       );

  static const String name = 'ProviderProfileRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ProviderProfileRouteArgs>();
      return ProviderProfilePage(account: args.account, key: args.key);
    },
  );
}

class ProviderProfileRouteArgs {
  const ProviderProfileRouteArgs({required this.account, this.key});

  final ProviderAccount account;

  final Key? key;

  @override
  String toString() {
    return 'ProviderProfileRouteArgs{account: $account, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ProviderProfileRouteArgs) return false;
    return account == other.account && key == other.key;
  }

  @override
  int get hashCode => account.hashCode ^ key.hashCode;
}

/// generated route for
/// [RedeemConfirmationPage]
class RedeemConfirmationRoute
    extends PageRouteInfo<RedeemConfirmationRouteArgs> {
  RedeemConfirmationRoute({
    Key? key,
    required StoreItem item,
    required int availablePoints,
    List<PageRouteInfo>? children,
  }) : super(
         RedeemConfirmationRoute.name,
         args: RedeemConfirmationRouteArgs(
           key: key,
           item: item,
           availablePoints: availablePoints,
         ),
         initialChildren: children,
       );

  static const String name = 'RedeemConfirmationRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<RedeemConfirmationRouteArgs>();
      return RedeemConfirmationPage(
        key: args.key,
        item: args.item,
        availablePoints: args.availablePoints,
      );
    },
  );
}

class RedeemConfirmationRouteArgs {
  const RedeemConfirmationRouteArgs({
    this.key,
    required this.item,
    required this.availablePoints,
  });

  final Key? key;

  final StoreItem item;

  final int availablePoints;

  @override
  String toString() {
    return 'RedeemConfirmationRouteArgs{key: $key, item: $item, availablePoints: $availablePoints}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! RedeemConfirmationRouteArgs) return false;
    return key == other.key &&
        item == other.item &&
        availablePoints == other.availablePoints;
  }

  @override
  int get hashCode => key.hashCode ^ item.hashCode ^ availablePoints.hashCode;
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
