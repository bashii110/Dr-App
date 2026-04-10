import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // ── Change this to your server IP / domain ────────────────────────────────
  // For Android emulator use: http://10.0.2.2:8000
  // For physical device on same WiFi: http://YOUR_PC_IP:8000
  // For production: https://yourdomain.com
  static const String _base = 'http://10.127.36.46:8000/api';
  static const Duration _timeout = Duration(seconds: 15);

  // ── Token helpers ─────────────────────────────────────────────────────────

  static Future<String?> getToken() async =>
      (await SharedPreferences.getInstance()).getString('auth_token');

  static Future<void> _saveToken(String token) async =>
      (await SharedPreferences.getInstance()).setString('auth_token', token);

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user');
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  static Future<Map<String, String>> _headers({bool auth = false}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (auth) {
      final token = await getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  static Map<String, dynamic> _parse(http.Response r) {
    try {
      return jsonDecode(r.body) as Map<String, dynamic>;
    } catch (_) {
      return {'status': r.statusCode, 'message': 'Server returned invalid response.'};
    }
  }

  static Uri _uri(String path, [Map<String, String?>? queryParams]) {
    final cleanParams = queryParams?.map((k, v) => MapEntry(k, v ?? ''))
      ?..removeWhere((_, v) => v.isEmpty);
    return Uri.parse('$_base$path').replace(
      queryParameters: (cleanParams?.isNotEmpty == true) ? cleanParams : null,
    );
  }

  // ── Auth ──────────────────────────────────────────────────────────────────

  /// Register a new user. Returns status 201 on success.
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String type, // 'patient' or 'doctor'
    String? phone,
  }) async {
    try {
      final r = await http
          .post(
        _uri('/auth/register'),
        headers: await _headers(),
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'type': type,
          if (phone != null) 'phone': phone,
        }),
      )
          .timeout(_timeout);
      return _parse(r);
    } catch (e) {
      return {'status': 500, 'message': 'Connection failed: $e'};
    }
  }

  /// Verify OTP. Sends email (not user_id) — matches new AuthController.
  /// Returns token + user on success so Flutter can log user in immediately.
  static Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final r = await http
          .post(
        _uri('/auth/verify-otp'),
        headers: await _headers(),
        body: jsonEncode({'email': email, 'otp': otp}),
      )
          .timeout(_timeout);
      final data = _parse(r);
      // If verified, save token immediately
      if (data['status'] == 200 && data['token'] != null) {
        await _saveToken(data['token'] as String);
      }
      return data;
    } catch (e) {
      return {'status': 500, 'message': 'Connection failed: $e'};
    }
  }

  /// Resend OTP by email.
  static Future<Map<String, dynamic>> resendOtp(String email) async {
    try {
      final r = await http
          .post(
        _uri('/auth/resend-otp'),
        headers: await _headers(),
        body: jsonEncode({'email': email}),
      )
          .timeout(_timeout);
      return _parse(r);
    } catch (e) {
      return {'status': 500, 'message': 'Connection failed: $e'};
    }
  }

  /// Login. Returns token on success, or requires_verification=true if unverified.
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final r = await http
          .post(
        _uri('/auth/login'),
        headers: await _headers(),
        body: jsonEncode({'email': email, 'password': password}),
      )
          .timeout(_timeout);
      final data = _parse(r);
      if (data['status'] == 200 && data['token'] != null) {
        await _saveToken(data['token'] as String);
      }
      return data;
    } catch (e) {
      return {'status': 500, 'message': 'Connection failed: $e'};
    }
  }

  /// Logout — revokes server token and clears local session.
  static Future<void> logout() async {
    try {
      await http
          .post(_uri('/auth/logout'), headers: await _headers(auth: true))
          .timeout(_timeout);
    } catch (_) {}
    await clearSession();
  }

  /// Get the authenticated user's profile.
  static Future<Map<String, dynamic>> getMe() async {
    try {
      final r = await http
          .get(_uri('/auth/me'), headers: await _headers(auth: true))
          .timeout(_timeout);
      return _parse(r);
    } catch (e) {
      return {'status': 500, 'message': 'Connection failed: $e'};
    }
  }

  /// Forgot password — sends OTP to email.
  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final r = await http
          .post(
        _uri('/auth/forgot-password'),
        headers: await _headers(),
        body: jsonEncode({'email': email}),
      )
          .timeout(_timeout);
      return _parse(r);
    } catch (e) {
      return {'status': 500, 'message': 'Connection failed: $e'};
    }
  }

  // ── Doctors ───────────────────────────────────────────────────────────────

  /// Fetch list of approved doctors. Supports search + category filter.
  static Future<Map<String, dynamic>> getDoctors({
    String? category,
    String? search,
    int page = 1,
  }) async {
    try {
      final r = await http
          .get(
        _uri('/doctors', {
          if (category != null) 'category': category,
          if (search != null) 'search': search,
          'page': '$page',
        }),
        headers: await _headers(),
      )
          .timeout(_timeout);
      return _parse(r);
    } catch (e) {
      return {'status': 500, 'message': 'Connection failed: $e'};
    }
  }

  /// Fetch a single doctor's full profile.
  static Future<Map<String, dynamic>> getDoctorDetail(int id) async {
    try {
      final r = await http
          .get(_uri('/doctors/$id'), headers: await _headers())
          .timeout(_timeout);
      return _parse(r);
    } catch (e) {
      return {'status': 500, 'message': 'Connection failed: $e'};
    }
  }

  /// Fetch categories — returns flat list of strings.
  static Future<Map<String, dynamic>> getCategories() async {
    try {
      final r = await http
          .get(_uri('/doctors/categories'), headers: await _headers())
          .timeout(_timeout);
      return _parse(r);
    } catch (e) {
      return {'status': 500, 'message': 'Connection failed: $e'};
    }
  }

  /// Fetch reviews for a doctor.
  static Future<Map<String, dynamic>> getDoctorReviews(int doctorId) async {
    try {
      final r = await http
          .get(_uri('/doctors/$doctorId/reviews'), headers: await _headers())
          .timeout(_timeout);
      return _parse(r);
    } catch (e) {
      return {'status': 500, 'message': 'Connection failed: $e'};
    }
  }

  // ── Appointments ─────────────────────────────────────────────────────────

  /// Book an appointment (patients only).
  static Future<Map<String, dynamic>> bookAppointment({
    required int doctorId,
    required String date,   // yyyy-MM-dd
    required String time,   // HH:mm
    String? notes,
  }) async {
    try {
      final r = await http
          .post(
        _uri('/appointments'),
        headers: await _headers(auth: true),
        body: jsonEncode({
          'doctor_id': doctorId,
          'appointment_date': date,
          'appointment_time': time,
          if (notes != null && notes.isNotEmpty) 'notes': notes,
        }),
      )
          .timeout(_timeout);
      return _parse(r);
    } catch (e) {
      return {'status': 500, 'message': 'Connection failed: $e'};
    }
  }

  /// Fetch current user's appointments (patient view).
  static Future<Map<String, dynamic>> getMyAppointments({String? status}) async {
    try {
      final r = await http
          .get(
        _uri('/appointments', {if (status != null) 'status': status}),
        headers: await _headers(auth: true),
      )
          .timeout(_timeout);
      return _parse(r);
    } catch (e) {
      return {'status': 500, 'message': 'Connection failed: $e'};
    }
  }

  /// Fetch doctor's own appointments.
  static Future<Map<String, dynamic>> getDoctorAppointments({
    String? status,
  }) async {
    try {
      final r = await http
          .get(
        _uri('/doctor/appointments', {if (status != null) 'status': status}),
        headers: await _headers(auth: true),
      )
          .timeout(_timeout);
      return _parse(r);
    } catch (e) {
      return {'status': 500, 'message': 'Connection failed: $e'};
    }
  }

  /// Cancel an appointment (PATCH — matches both old POST and new PATCH route).
  static Future<Map<String, dynamic>> cancelAppointment(int id,
      {String? reason}) async {
    try {
      final r = await http
          .post(                          // Changed from PATCH to POST to match route
        _uri('/appointments/$id/cancel'),
        headers: await _headers(auth: true),
        body: jsonEncode({if (reason != null) 'reason': reason}),
      )
          .timeout(_timeout);
      return _parse(r);
    } catch (e) {
      return {'status': 500, 'message': 'Connection failed: $e'};
    }
  }

  /// Doctor updates appointment status (confirm / complete / cancel).
  static Future<Map<String, dynamic>> updateAppointmentStatus(
      int id,
      String status,
      ) async {
    try {
      final r = await http
          .patch(
        _uri('/doctor/appointments/$id/status'),
        headers: await _headers(auth: true),
        body: jsonEncode({'status': status}),
      )
          .timeout(_timeout);
      return _parse(r);
    } catch (e) {
      return {'status': 500, 'message': 'Connection failed: $e'};
    }
  }

  // ── Doctor profile ────────────────────────────────────────────────────────

  /// Update the authenticated doctor's profile.
  static Future<Map<String, dynamic>> updateDoctorProfile(
      Map<String, dynamic> data,
      ) async {
    try {
      final r = await http
          .post(
        _uri('/doctor/profile'),
        headers: await _headers(auth: true),
        body: jsonEncode(data),
      )
          .timeout(_timeout);
      return _parse(r);
    } catch (e) {
      return {'status': 500, 'message': 'Connection failed: $e'};
    }
  }

  // ── Reviews ───────────────────────────────────────────────────────────────

  /// Submit a review after a completed appointment.
  static Future<Map<String, dynamic>> submitReview({
    required int doctorId,
    required double rating,
    String? comment,
  }) async {
    try {
      final r = await http
          .post(
        _uri('/reviews'),
        headers: await _headers(auth: true),
        body: jsonEncode({
          'doctor_id': doctorId,
          'rating': rating,
          if (comment != null && comment.isNotEmpty) 'comment': comment,
        }),
      )
          .timeout(_timeout);
      return _parse(r);
    } catch (e) {
      return {'status': 500, 'message': 'Connection failed: $e'};
    }
  }

  // ── Profile ───────────────────────────────────────────────────────────────

  /// Update basic profile fields.
  static Future<Map<String, dynamic>> updateProfile(
      Map<String, dynamic> data,
      ) async {
    try {
      final r = await http
          .post(
        _uri('/profile'),
        headers: await _headers(auth: true),
        body: jsonEncode(data),
      )
          .timeout(_timeout);
      return _parse(r);
    } catch (e) {
      return {'status': 500, 'message': 'Connection failed: $e'};
    }
  }

  /// Change password (requires current password).
  static Future<Map<String, dynamic>> changePassword({
    required String current,
    required String newPass,
  }) async {
    try {
      final r = await http
          .post(
        _uri('/profile/change-password'),
        headers: await _headers(auth: true),
        body: jsonEncode({
          'current_password': current,
          'new_password': newPass,
          'new_password_confirmation': newPass,
        }),
      )
          .timeout(_timeout);
      return _parse(r);
    } catch (e) {
      return {'status': 500, 'message': 'Connection failed: $e'};
    }
  }
}