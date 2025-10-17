abstract class DashboardState {}

class DashboardPageInitial extends DashboardState {}

class UserInfoUpdate extends DashboardState {}

class UserInfoUpdate2 extends DashboardState {}

class ChangeDashBoardNav extends DashboardState {}

class RefreshDashboard extends DashboardState {}

class DashboardPageLoaded extends DashboardState {}

class ChangeScreen extends DashboardState {}

class RefreshDashboard2 extends DashboardState {}

class RefreshSummaryPage extends DashboardState {}

class RefreshSummaryPage2 extends DashboardState {}

class RefreshDevicesPage extends DashboardState {}

class RefreshDevicesPage2 extends DashboardState {}

class DashboardPageError extends DashboardState {
  final String message;

  DashboardPageError({this.message = "Error in loading data"});
}