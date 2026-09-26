abstract class UserDetailEvent {}

class UserDetailRequested extends UserDetailEvent {
  final int id;

  UserDetailRequested(this.id);
}