import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // ── Change this to your server IP / domain ────────────────────────────────
  // For Android emulator use: http://10.0.2.2:8000
  // For physical device on same WiFi: http://YOUR_PC_IP:8000
  // For production: https://yourdomain.com
  static const String _base = 'http://192.168.100.21:8000/api';
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
      return {
        'status': r.statusCode,
        'message': 'Server returned invalid response.',
      };
    }
  }

  static Uri _uri(String path, [Map<String, String?>? queryParams]) {
    final cleanParams = queryParams?.map((k, v) => MapEntry(k, v ?? ''))
      ?..removeWhere((_, v) => v.isEmpty);
    return Uri.parse('$_base$path').replace(
      queryParameters:
      (cleanParams?.isNotEmpty == true) ? cleanParams : null,
    );
  }

  // ── Auth ──────────────────────────────────────────────────────────────────

  /// Register a new user.
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
        _uri('/register'),          // ✅ /api/register
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

  /// Verify OTP sent to email after registration.
  static Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final r = await http
          .post(
        _uri('/verify-otp'),        // ✅ /api/verify-otp
        headers: await _headers(),
        body: jsonEncode({'email': email, 'otp': otp}),
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

  /// Resend OTP by email.
  static Future<Map<String, dynamic>> resendOtp(String email) async {
    try {
      final r = await http
          .post(
        _uri('/resend-otp'),        // ✅ /api/resend-otp
        headers: await _headers(),
        body: jsonEncode({'email': email}),
      )
          .timeout(_timeout);
      return _parse(r);
    } catch (e) {
      return {'status': 500, 'message': 'Connection failed: $e'};
    }
  }

  /// Login. Saves token on success.
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final r = await http
          .post(
        _uri('/login'),             // ✅ /api/login
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
          .post(
        _uri('/logout'),            // ✅ /api/logout
        headers: await _headers(auth: true),
      )
          .timeout(_timeout);
    } catch (_) {}
    await clearSession();
  }

  /// Get the authenticated user's profile.
  static Future<Map<String, dynamic>> getMe() async {
    try {
      final r = await http
          .get(
        _uri('/me'),                // ✅ /api/me
        headers: await _headers(auth: true),
      )
          .timeout(_timeout);
      return _parse(r);
    } catch (e) {
      return {'status': 500, 'message': 'Connection failed: $e'};
    }
  }

  /// Forgot password — sends reset link/OTP to email.
  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final r = await http
          .post(
        _uri('/forgot-password'),   // ✅ /api/forgot-password
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

  /// Fetch list of doctors. Supports search + category filter.
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

  /// Fetch specialisation categories.
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
          .get(
        _uri('/doctors/$doctorId/reviews'),
        headers: await _headers(),
      )
          .timeout(_timeout);
      return _parse(r);
    } catch (e) {
      return {'status': 500, 'message': 'Connection failed: $e'};
    }
  }

  // ── Appointments ──────────────────────────────────────────────────────────

  /// Book an appointment (patients only).
  static Future<Map<String, dynamic>> bookAppointment({
    required int doctorId,
    required String date, // yyyy-MM-dd
    required String time, // HH:mm
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

  /// Fetch current patient's appointments.
  static Future<Map<String, dynamic>> getMyAppointments({
    String? status,
  }) async {
    try {
      final r = await http
          .get(
        _uri('/appointments', {
          if (status != null) 'status': status,
        }),
        headers: await _headers(auth: true),
      )
          .timeout(_timeout);
      return _parse(r);
    } catch (e) {
      return {'status': 500, 'message': 'Connection failed: $e'};
    }
  }

  /// Cancel an appointment (patient).
  static Future<Map<String, dynamic>> cancelAppointment(int id,
      {String? reason}) async {
    try {
      final r = await http
          .patch(
        _uri('/appointments/$id/cancel'),
        headers: await _headers(auth: true),
        body: jsonEncode({
          if (reason != null) 'reason': reason,
        }),
      )
          .timeout(_timeout);
      return _parse(r);
    } catch (e) {
      return {'status': 500, 'message': 'Connection failed: $e'};
    }
  }

  // ── Doctor dashboard ──────────────────────────────────────────────────────

  /// Update the authenticated doctor's profile.
  static Future<Map<String, dynamic>> updateDoctorProfile(
      Map<String, dynamic> data,
      ) async {
    try {
      final r = await http
          .put(
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

  /// Fetch doctor's own appointments.
  static Future<Map<String, dynamic>> getDoctorAppointments({
    String? status,
  }) async {
    try {
      final r = await http
          .get(
        _uri('/doctor/appointments', {
          if (status != null) 'status': status,
        }),
        headers: await _headers(auth: true),
      )
          .timeout(_timeout);
      return _parse(r);
    } catch (e) {
      return {'status': 500, 'message': 'Connection failed: $e'};
    }
  }

  /// Doctor updates appointment status (confirmed / completed / cancelled).
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

  /// Update basic profile fields (name, phone, etc.).
  static Future<Map<String, dynamic>> updateProfile(
      Map<String, dynamic> data,
      ) async {
    try {
      final r = await http
          .put(
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