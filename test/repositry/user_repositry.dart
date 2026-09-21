import 'package:basic_widget/bloc/network/api_client.dart';
import 'package:basic_widget/repository/user_repository.dart';
import 'package:basic_widget/service/user_cache_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockApiClient extends Mock implements ApiClient {}

class MockUserCacheService extends Mock implements UserCacheService {}

void main() {
  late MockApiClient mockApiClient;
  late MockUserCacheService mockUserCacheService;
  late UserRepository userRepository;

  setUp(() {
    mockApiClient = MockApiClient();
    mockUserCacheService = MockUserCacheService();
    userRepository = UserRepository(
      apiClient: mockApiClient,
      userCacheService: UserCacheService(),
    );
  });

  test("getUserById returns User when API call succeeds", () async {
    //  Arrange
    final fakeResponse = Response(
      requestOptions: RequestOptions(path: "/users/5"),
      data: {'id': 5, 'name': 'Namir', 'email': 'namir@example.com'},
      statusCode: 200,
    );
    when(
      () => mockApiClient.get('/users/5'),
    ).thenAnswer((_) async => fakeResponse);

    final user = await userRepository.getUserById(5);

    expect(user.id, 5);
    expect(user.name, 'Namir');
    expect(user.email, 'namir@example.com');
    verify(() => mockApiClient.get("/users/5")).called(1);
  });

  test("getUserById throws when API fails", () async {
    when(
      () => mockApiClient.get("/users/5"),
    ).thenThrow(Exception("Network error"));

    await expectLater(userRepository.getUserById(5), throwsA(isA<Exception>()));
    verify(() => mockApiClient.get('/users/5')).called(1);
  });
}
