part of 'notification_cubit.dart';

sealed class NotificationState extends Equatable {
  const NotificationState();
  @override
  List<Object?> get props => [];
}

final class NotificationInitial extends NotificationState {
  const NotificationInitial();
}

final class NotificationLoading extends NotificationState {
  const NotificationLoading();
}

final class NotificationLoaded extends NotificationState {
  final List<Map<String, dynamic>> notifications;
  const NotificationLoaded(this.notifications);
  @override
  List<Object?> get props => [notifications];
}

final class NotificationError extends NotificationState {
  final String message;
  const NotificationError(this.message);
  @override
  List<Object?> get props => [message];
}
