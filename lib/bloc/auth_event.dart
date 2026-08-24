abstract class AuthEvent {}

class AuthCheckRequested extends AuthEvent {}

class AuthLoginRequest extends AuthEvent {}

class AuthLogoutkRequested extends AuthEvent {}
