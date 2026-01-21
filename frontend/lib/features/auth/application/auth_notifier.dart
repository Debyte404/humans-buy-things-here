import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_notifier.g.dart';

@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  FutureOr<bool> build() {
    return false; // Initially logged out
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    state = const AsyncData(true);
  }

  Future<void> logout() async {
    state = const AsyncLoading();
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    state = const AsyncData(false);
  }

  // Alias for logout to satisfy Home screen usage
  Future<void> signOut() => logout();
}
