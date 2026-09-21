import 'package:flutter_test/flutter_test.dart';
import 'package:basic_widget/model/user.dart';

void main() {
  test("fromJson create user correctly", () {
    final json = {'id': 5, 'name': 'Namir', 'email': 'namir@example.com'};

    final user = User.fromJson(json);

    expect(user.id, 5);
    expect(user.name, 'Namir');
    expect(user.email, "namir@example.com");
  });

  test("toJson convert User to Json correctly", () {
    const user = User(id: 5, name: 'Namir', email: 'namir@example.com');

    final json = user.toJson();

    expect(json['id'], 5);
    expect(json['name'], 'Namir');
    expect(json['email'], 'namir@example.com');
  });
}
