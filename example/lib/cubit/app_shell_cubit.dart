import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Global shell flags for navigation and product-state demos.
final class AppShellState extends Equatable {
  /// Creates shell state.
  const new({
    this.tabIndex = 0,
    this.isSignedIn = true,
    this.maintenanceMode = false,
    this.notificationsAllowed = true,
    this.forceOffline = false,
  });

  /// Selected adaptive destination (0 Tasks, 1 Activity, 2 Settings).
  final int tabIndex;

  /// When false, session-expired UI should activate on gated tabs.
  final bool isSignedIn;

  /// When true, maintenance UI should activate on gated tabs.
  final bool maintenanceMode;

  /// When false, permission-denied UI should activate on Tasks.
  final bool notificationsAllowed;

  /// When true, force offline connectivity presentation.
  final bool forceOffline;

  /// Copy with overrides.
  AppShellState copyWith({
    int? tabIndex,
    bool? isSignedIn,
    bool? maintenanceMode,
    bool? notificationsAllowed,
    bool? forceOffline,
  }) {
    return AppShellState(
      tabIndex: tabIndex ?? this.tabIndex,
      isSignedIn: isSignedIn ?? this.isSignedIn,
      maintenanceMode: maintenanceMode ?? this.maintenanceMode,
      notificationsAllowed: notificationsAllowed ?? this.notificationsAllowed,
      forceOffline: forceOffline ?? this.forceOffline,
    );
  }

  @override
  List<Object?> get props => [
    tabIndex,
    isSignedIn,
    maintenanceMode,
    notificationsAllowed,
    forceOffline,
  ];
}

/// Owns tab selection and developer product-state toggles.
final class AppShellCubit extends Cubit<AppShellState> {
  /// Creates the shell cubit.
  new() : super(const AppShellState());

  /// Selects a navigation destination.
  void selectTab(int index) {
    if (index == state.tabIndex) {
      return;
    }
    emit(state.copyWith(tabIndex: index));
  }

  /// Signs the demo user in.
  void signIn() => emit(state.copyWith(isSignedIn: true, tabIndex: 0));

  /// Signs out (triggers session-expired UI).
  void signOut() => emit(state.copyWith(isSignedIn: false));

  /// Toggles maintenance mode.
  void setMaintenanceMode({required bool enabled}) {
    emit(state.copyWith(maintenanceMode: enabled));
  }

  /// Toggles notification permission for the permission gate demo.
  void setNotificationsAllowed({required bool allowed}) {
    emit(state.copyWith(notificationsAllowed: allowed));
  }

  /// Forces offline connectivity presentation.
  void setForceOffline({required bool offline}) {
    emit(state.copyWith(forceOffline: offline));
  }
}
