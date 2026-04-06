import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // ⚠️  Change to your server IP / domain
  static const String _base = 'http://192.168.100.21:8000/api';
  static const Duration _timeout = Duration(seconds: 15);

  // ── Token helpers ─────────────────────────────────────────────────────────

  static Future<String?> getToken() async =>
      (await SharedPreferences.getInstance()).getString('token');

  static Future<void> _saveToken(String t) async =>
      (await SharedPreferences.getInstance()).setString('token', t);

  static Future<void> clearSession() async {
    final p = await SharedPreferences.getInstance();
    p.remove('token');
    p.remove('user');
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  static Future<Map<String, String>> _headers({bool auth = false}) async {
    final h = {'Content-Type': 'application/json', 'Accept': 'application/json'};
    if (auth) {
      final t = await getToken();
      if (t != null) h['Authorization'] = 'Bearer $t';
    }
    return h;
  }

  static Map<String, dynamic> _parse(http.Response r) =>
      jsonDecode(r.body) as Map<String, dynamic>;

  static Uri _uri(String path, [Map<String, String?>? q]) {
    final params = q?.map((k, v) => MapEntry(k, v ?? ''))
      ?..removeWhere((_, v) => v.isEmpty);
    return Uri.parse('$_base$path').replace(queryParameters: params?.isEmpty == false ? params : null);
  }

  // ── Auth ──────────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String type,
  }) async {
    final r = await http
        .post(_uri('/register'),
        headers: await _headers(),
        body: jsonEncode({'name': name, 'email': email, 'password': password, 'type': type}))
        .timeout(_timeout);
    return _parse(r);
  }

  static Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    final r = await http
        .post(_uri('/verify-otp'),
        headers: await _headers(),
        body: jsonEncode({'email': email, 'otp': otp}))
        .timeout(_timeout);
    return _parse(r);
  }

  static Future<Map<String, dynamic>> resendOtp(String email) async {
    final r = await http
        .post(_uri('/resend-otp'),
        headers: await _headers(),
        body: jsonEncode({'email': email}))
        .timeout(_timeout);
    return _parse(r);
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final r = await http
        .post(_uri('/login'),
        headers: await _headers(),
        body: jsonEncode({'email': email, 'password': password}))
        .timeout(_timeout);
    final data = _parse(r);
    if (data['status'] == 200) {
      await _saveToken(data['token'] as String);
    }
    return data;
  }

  static Future<void> logout() async {
    try {
      await http.post(_uri('/logout'), headers: await _headers(auth: true)).timeout(_timeout);
    } catch (_) {}
    await clearSession();
  }

  static Future<Map<String, dynamic>> getMe() async {
    final r = await http.get(_uri('/me'), headers: await _headers(auth: true)).timeout(_timeout);
    return _parse(r);
  }

  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    final r = await http
        .post(_uri('/forgot-password'),
        headers: await _headers(), body: jsonEncode({'email': email}))
        .timeout(_timeout);
    return _parse(r);
  }

  // ── Doctors ───────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> getDoctors({
    String? category,
    String? search,
    int page = 1,
  }) async {
    final r = await http
        .get(_uri('/doctors', {'category': category, 'search': search, 'page': '$page'}),
        headers: await _headers())
        .timeout(_timeout);
    return _parse(r);
  }

  static Future<Map<String, dynamic>> getDoctorDetail(int id) async {
    final r = await http.get(_uri('/doctors/$id'), headers: await _headers()).timeout(_timeout);
    return _parse(r);
  }

  static Future<Map<String, dynamic>> getCategories() async {
    final r = await http
        .get(_uri('/doctors/categories'), headers: await _headers())
        .timeout(_timeout);
    return _parse(r);
  }

  static Future<Map<String, dynamic>> getDoctorReviews(int doctorId) async {
    final r = await http
        .get(_uri('/doctors/$doctorId/reviews'), headers: await _headers())
        .timeout(_timeout);
    return _parse(r);
  }

  // ── Appointments ─────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> bookAppointment({
    required int doctorId,
    required String date,
    required String time,
    String? notes,
  }) async {
    final r = await http
        .post(_uri('/appointments'),
        headers: await _headers(auth: true),
        body: jsonEncode({
          'doctor_id': doctorId,
          'appointment_date': date,
          'appointment_time': time,
          if (notes != null && notes.isNotEmpty) 'notes': notes,
        }))
        .timeout(_timeout);
    return _parse(r);
  }

  static Future<Map<String, dynamic>> getMyAppointments({String? status}) async {
    final r = await http
        .get(_uri('/appointments', {'status': status}), headers: await _headers(auth: true))
        .timeout(_timeout);
    return _parse(r);
  }

  static Future<Map<String, dynamic>> cancelAppointment(int id) async {
    final r = await http
        .patch(_uri('/appointments/$id/cancel'), headers: await _headers(auth: true))
        .timeout(_timeout);
    return _parse(r);
  }

  // ── Doctor dashboard ──────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> updateDoctorProfile(Map<String, dynamic> data) async {
    final r = await http
        .put(_uri('/doctor/profile'),
        headers: await _headers(auth: true), body: jsonEncode(data))
        .timeout(_timeout);
    return _parse(r);
  }

  static Future<Map<String, dynamic>> getDoctorAppointments({String? status}) async {
    final r = await http
        .get(_uri('/doctor/appointments', {'status': status}),
        headers: await _headers(auth: true))
        .timeout(_timeout);
    return _parse(r);
  }

  static Future<Map<String, dynamic>> updateAppointmentStatus(int id, String status) async {
    final r = await http
        .patch(_uri('/doctor/appointments/$id/status'),
        headers: await _headers(auth: true), body: jsonEncode({'status': status}))
        .timeout(_timeout);
    return _parse(r);
  }

  // ── Reviews ───────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> submitReview({
    required int doctorId,
    required double rating,
    String? comment,
  }) async {
    final r = await http
        .post(_uri('/reviews'),
        headers: await _headers(auth: true),
        body: jsonEncode({
          'doctor_id': doctorId,
          'rating': rating,
          if (comment != null && comment.isNotEmpty) 'comment': comment,
        }))
        .timeout(_timeout);
    return _parse(r);
  }

  // ── Profile ───────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    final r = await http
        .put(_uri('/profile'),
        headers: await _headers(auth: true), body: jsonEncode(data))
        .timeout(_timeout);
    return _parse(r);
  }

  static Future<Map<String, dynamic>> changePassword({
    required String current,
    required String newPass,
  }) async {
    final r = await http
        .post(_uri('/profile/change-password'),
        headers: await _headers(auth: true),
        body: jsonEncode({
          'current_password': current,
          'new_password': newPass,
          'new_password_confirmation': newPass,
        }))
        .timeout(_timeout);
    return _parse(r);
  }
}