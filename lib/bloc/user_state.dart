import 'package:basic_widget/bloc/status.dart';
import 'package:basic_widget/model/user.dart';
import 'package:equatable/equatable.dart';

class UserState extends Equatable {
  final Status status;
  final List<User> users;
  final String? errorMessage;
  final bool clearError;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;
  final String searchQuery;
  final User? selectedUser;

  const UserState({
    this.status = Status.initial,
    this.users = const [],
    this.errorMessage,
    this.clearError = false,
    this.currentPage = 1,
    this.hasMore = true,
    this.isLoadingMore = false,
    this.searchQuery = "",
    this.selectedUser,
  });

  UserState copyWith({
    Status? status,
    List<User>? users,
    String? errorMessage,
    bool? clearError,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
    String? searchQuery,
    User? selectedUser,
  }) {
    return UserState(
      status: status ?? this.status,
      users: users ?? this.users,
      errorMessage: (clearError ?? false)
          ? null
          : errorMessage ?? this.errorMessage,
      clearError: clearError ?? false,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedUser: selectedUser ?? this.selectedUser,
    );
  }

  @override
  List<Object?> get props => [
    status,
    users,
    errorMessage,
    clearError,
    currentPage,
    hasMore,
    isLoadingMore,
    selectedUser,
  ];
}
