abstract class DashboardEvent {}

class DashboardPageRequested extends DashboardEvent {
  String? nfcData;

  DashboardPageRequested({this.nfcData});
}


