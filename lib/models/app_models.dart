class UserModel {
  final int id;
  final String name;
  final String email;
  final String type;
  final Map<String, dynamic>? profile;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.type,
    this.profile,
  });

  factory UserModel.fromJson(Map<String, dynamic> j) => UserModel(
    id:      j['id'] as int,
    name:    j['name'] as String,
    email:   j['email'] as String,
    type:    j['type'] as String,
    profile: j['profile'] as Map<String, dynamic>?,
  );

  bool get isDoctor => type == 'doctor';
}

// ---------------------------------------------------------------------------

class DoctorModel {
  final int id;
  final int docId;
  final String? name;
  final String? category;
  final int? experience;
  final String? bioData;
  final String? status;
  final double rating;
  final int ratingCount;
  final double consultationFee;
  final String? availableFrom;
  final String? availableTo;

  DoctorModel({
    required this.id,
    required this.docId,
    this.name,
    this.category,
    this.experience,
    this.bioData,
    this.status,
    this.rating = 0,
    this.ratingCount = 0,
    this.consultationFee = 0,
    this.availableFrom,
    this.availableTo,
  });

  factory DoctorModel.fromJson(Map<String, dynamic> j) {
    final user = j['user'] as Map<String, dynamic>?;
    return DoctorModel(
      id:              j['id'] as int,
      docId:           j['doc_id'] as int,
      name:            user?['name'] as String?,
      category:        j['category'] as String?,
      experience:      j['experience'] as int?,
      bioData:         j['bio_data'] as String?,
      status:          j['status'] as String?,
      rating:          (j['rating'] as num?)?.toDouble() ?? 0,
      ratingCount:     j['rating_count'] as int? ?? 0,
      consultationFee: (j['consultation_fee'] as num?)?.toDouble() ?? 0,
      availableFrom:   j['available_from'] as String?,
      availableTo:     j['available_to'] as String?,
    );
  }
}

// ---------------------------------------------------------------------------

class AppointmentModel {
  final int id;
  final int patientId;
  final int doctorId;
  final String appointmentDate;
  final String appointmentTime;
  final String status;
  final String? notes;
  final double consultationFee;
  final DoctorModel? doctor;
  final Map<String, dynamic>? patient;

  AppointmentModel({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.status,
    this.notes,
    this.consultationFee = 0,
    this.doctor,
    this.patient,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> j) => AppointmentModel(
    id:               j['id'] as int,
    patientId:        j['patient_id'] as int,
    doctorId:         j['doctor_id'] as int,
    appointmentDate:  j['appointment_date'] as String,
    appointmentTime:  j['appointment_time'] as String,
    status:           j['status'] as String,
    notes:            j['notes'] as String?,
    consultationFee:  (j['consultation_fee'] as num?)?.toDouble() ?? 0,
    doctor: j['doctor'] != null
        ? DoctorModel.fromJson(j['doctor'] as Map<String, dynamic>)
        : null,
    patient: j['patient'] as Map<String, dynamic>?,
  );

  bool get isPending   => status == 'pending';
  bool get isConfirmed => status == 'confirmed';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';
}

// ---------------------------------------------------------------------------

class ReviewModel {
  final int id;
  final int patientId;
  final int doctorId;
  final double rating;
  final String? comment;
  final String? patientName;
  final String createdAt;

  ReviewModel({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.rating,
    this.comment,
    this.patientName,
    required this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> j) => ReviewModel(
    id:          j['id'] as int,
    patientId:   j['patient_id'] as int,
    doctorId:    j['doctor_id'] as int,
    rating:      (j['rating'] as num).toDouble(),
    comment:     j['comment'] as String?,
    patientName: (j['patient'] as Map<String, dynamic>?)?['name'] as String?,
    createdAt:   j['created_at'] as String,
  );
}