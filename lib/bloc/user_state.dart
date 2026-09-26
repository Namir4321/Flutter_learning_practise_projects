import 'package:basic_widget/bloc/status.dart';
import 'package:basic_widget/model/user.dart';
import 'package:equatable/equatable.dart';

class UserState extends Equatable {
  final Status status;
  final List<User> users;
  final String? errorMessage;

  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;
  final String searchQuery;
  final User? selectedUser;
  final String? loadMoreError;

  const UserState({
    this.status = Status.initial,
    this.users = const [],
    this.errorMessage,
    this.currentPage = 1,
    this.hasMore = true,
    this.isLoadingMore = false,
    this.searchQuery = "",
    this.selectedUser,
    this.loadMoreError,
  });

  UserState copyWith({
    Status? status,
    List<User>? users,
    String? errorMessage,
    bool clearError = false,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
    String? searchQuery,
    String? loadMoreError,
    bool clearLoadMoreError = false,
  }) {
    return UserState(
      status: status ?? this.status,
      users: users ?? this.users,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      searchQuery: searchQuery ?? this.searchQuery,
      loadMoreError: clearLoadMoreError
          ? null
          : loadMoreError ?? this.loadMoreError,
    );
  }

  @override
  List<Object?> get props => [
    status,
    users,
    errorMessage,
    loadMoreError,
    currentPage,
    hasMore,
    isLoadingMore,
  ];
}
