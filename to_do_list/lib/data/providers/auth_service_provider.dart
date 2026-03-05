import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:to_do_list/data/data_sources/remote/firebase/auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});
