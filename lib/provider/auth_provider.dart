import 'package:flutter/foundation.dart';
import '../models/app_models.dart';
import '../service/api_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  AuthStatus _status = AuthStatus.unknown;
  UserModel? _user;
  bool _loading = false;
  String? _error;

  AuthStatus get status  => _status;
  UserModel? get user    => _user;
  bool       get loading => _loading;
  String?    get error   => _error;
  bool       get isDoctor => _user?.isDoctor ?? false;

  // ── Startup ───────────────────────────────────────────────────────────────

  Future<void> checkAuth() async {
    final token = await ApiService.getToken();
    if (token == null) { _status = AuthStatus.unauthenticated; notifyListeners(); return; }
    try {
      final res = await ApiService.getMe();
      if (res['status'] == 200) {
        _user   = UserModel.fromJson(res['user'] as Map<String, dynamic>);
        _status = AuthStatus.authenticated;
      } else {
        await ApiService.clearSession();
        _status = AuthStatus.unauthenticated;
      }
    } catch (_) {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  // ── Register ──────────────────────────────────────────────────────────────

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String type,
  }) async {
    _setLoading(true);
    try {
      final res = await ApiService.register(
          name: name, email: email, password: password, type: type);
      _setLoading(false);
      if (res['status'] == 200) return true;
      _error = _parseMsg(res['message']);
      notifyListeners();
      return false;
    } catch (_) {
      _error = 'Connection error. Please check your network.';
      _setLoading(false);
      return false;
    }
  }

  // ── OTP ───────────────────────────────────────────────────────────────────

  Future<bool> verifyOtp({required String email, required String otp}) async {
    _setLoading(true);
    try {
      final res = await ApiService.verifyOtp(email: email, otp: otp);
      _setLoading(false);
      if (res['status'] == 200) return true;
      _error = _parseMsg(res['message']);
      notifyListeners();
      return false;
    } catch (_) {
      _error = 'Connection error.';
      _setLoading(false);
      return false;
    }
  }

  Future<bool> resendOtp(String email) async {
    try {
      final res = await ApiService.resendOtp(email);
      return res['status'] == 200;
    } catch (_) { return false; }
  }

  // ── Login ─────────────────────────────────────────────────────────────────

  Future<bool> login({required String email, required String password}) async {
    _setLoading(true);
    _error = null;
    try {
      final res = await ApiService.login(email: email, password: password);
      _setLoading(false);
      if (res['status'] == 200) {
        _user   = UserModel.fromJson(res['user'] as Map<String, dynamic>);
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      }
      _error = _parseMsg(res['message']);
      notifyListeners();
      return false;
    } catch (_) {
      _error = 'Connection error. Please check your network.';
      _setLoading(false);
      return false;
    }
  }

  // ── Logout ────────────────────────────────────────────────────────────────

  Future<void> logout() async {
    await ApiService.logout();
    _user   = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  void clearError() { _error = null; notifyListeners(); }

  // ── Helpers ───────────────────────────────────────────────────────────────

  void _setLoading(bool v) { _loading = v; notifyListeners(); }

  String _parseMsg(dynamic m) {
    if (m is String) return m;
    if (m is Map)    return m.values.expand((v) => v is List ? v : [v]).join('\n');
    return 'An error occurred.';
  }
}