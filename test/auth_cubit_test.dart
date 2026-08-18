import 'package:flutter_test/flutter_test.dart';
import 'package:rs_islam_app/features/home/presentation/bloc/auth_cubit.dart';

void main() {
  group('AuthCubit', () {
    test('initial state has fullName "Tamu" and isAuthenticated false', () {
      final cubit = AuthCubit();
      expect(cubit.state.isAuthenticated, false);
      expect(cubit.state.fullName, 'Tamu');
      expect(cubit.state.email, isNull);
    });

    test('login emits authenticated state with user details', () {
      final cubit = AuthCubit();
      cubit.login(fullName: 'Ahmad Fauzi Rahman', email: 'ahmad@example.com', token: 'dummy_jwt');
      expect(cubit.state.isAuthenticated, true);
      expect(cubit.state.fullName, 'Ahmad Fauzi Rahman');
      expect(cubit.state.email, 'ahmad@example.com');
      expect(cubit.state.token, 'dummy_jwt');
    });

    test('logout resets state back to Tamu', () {
      final cubit = AuthCubit();
      cubit.login(fullName: 'Ahmad Fauzi Rahman');
      expect(cubit.state.isAuthenticated, true);

      cubit.logout();
      expect(cubit.state.isAuthenticated, false);
      expect(cubit.state.fullName, 'Tamu');
    });
  });
}
