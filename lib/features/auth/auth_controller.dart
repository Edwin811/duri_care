import 'package:duri_care/core/services/session_service.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_state.dart' as state;

class AuthController extends GetxController {
  Rxn<state.AuthState> authState = Rxn();
  bool get isAuthenticated => authState.value == state.AuthState.authenticated;
  bool get isUnauthenticated => !isAuthenticated;
  RxBool isFirstTime = true.obs;
  final SupabaseClient _supabase = Supabase.instance.client;
  @override
  void onInit() {
    super.onInit();

    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      if (event == AuthChangeEvent.signedIn) {
        authState.value = state.AuthState.authenticated;
      } else if (event == AuthChangeEvent.signedOut) {
        authState.value = state.AuthState.unauthenticated;
      } else {
        authState.value = state.AuthState.unauthenticated;
      }
    });
  }

  @override
  void onReady() async {
    super.onReady();
    await checkFirstTimeUser();
    await updateAuthState();
  }

  Future<void> updateAuthState() async {
    final session = Supabase.instance.client.auth.currentSession;

    if (isFirstTime.value) {
      authState.value = state.AuthState.initial;
    } else if (session?.user != null) {
      authState.value = state.AuthState.authenticated;
    } else {
      authState.value = state.AuthState.unauthenticated;
    }
  }

  Future<void> checkFirstTimeUser() async {
    final prefs = await SharedPreferences.getInstance();
    isFirstTime.value = prefs.getBool('first_time') ?? true;
  }

  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('first_time', false);
    isFirstTime.value = false;
    authState.value = state.AuthState.unauthenticated;
  }

  Future<AuthResponse> login(String email, String password) async {
    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.user != null) {
      final username = await getUsername();

      final userData = {
        'id': response.user!.id,
        'email': response.user!.email,
        'fullname': username,
      };

      await SessionService.to.saveSession(
        response.session!.accessToken,
        userData,
      );
    }

    authState.value = state.AuthState.authenticated;
    return response;
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();
    await SessionService.to.clearSession();

    authState.value = state.AuthState.unauthenticated;
    authState.refresh();
    Get.offAllNamed('/login');
  }

  Future<String> getUsername() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return 'User';

    final cached = await SessionService.to.getCachedUsername(user.id);
    if (cached != null && cached.isNotEmpty) return cached;

    try {
      final res =
          await _supabase
              .from('users')
              .select('fullname')
              .eq('id', user.id)
              .limit(1)
              .single();

      final fullname = res['fullname']?.toString().trim();

      final nameToUse =
          (fullname != null && fullname.isNotEmpty)
              ? fullname
              : (user.email?.split('@').first ?? 'User');

      await SessionService.to.cacheUsername(user.id, nameToUse);
      return nameToUse;
    } catch (e) {
      return user.email?.split('@').first ?? 'User';
    }
  }

  Future<String?> getEmail() async {
    final user = _supabase.auth.currentUser;
    return user?.email;
  }

  Future<String> getProfilePicture() async {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      try {
        final response =
            await _supabase
                .from('users')
                .select('profile_image, fullname')
                .eq('id', user.id)
                .maybeSingle();

        final profileImagePath = response?['profile_image'];

        if (profileImagePath != null &&
            profileImagePath is String &&
            profileImagePath.isNotEmpty) {
          final publicUrl = _supabase.storage
              .from('duricare')
              .getPublicUrl(profileImagePath);
          return publicUrl;
        }

        final fullname = response!['fullname'];
        if (fullname != null && fullname is String && fullname.isNotEmpty) {
          return fullname[0].toUpperCase();
        }
      } catch (e) {
        throw Exception('Error fetching profile picture: $e');
      }
    }

    return '';
  }

  Future<String?> getRole() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return null;

    final response =
        await Supabase.instance.client
            .from('user_roles')
            .select('roles ( role_name )')
            .eq('user_id', user.id)
            .maybeSingle();

    if (response == null) return null;

    return response['roles']?['role_name'];
  }
}
