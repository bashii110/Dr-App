<div align="center">

<img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" />
<img src="https://img.shields.io/badge/Laravel-FF2D20?style=for-the-badge&logo=laravel&logoColor=white" />
<img src="https://img.shields.io/badge/MySQL-4479A1?style=for-the-badge&logo=mysql&logoColor=white" />
<img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" />
<img src="https://img.shields.io/badge/PHP-777BB4?style=for-the-badge&logo=php&logoColor=white" />

<br/><br/>

<h1>🏥 DoctorApp</h1>

<p><strong>A full-stack mobile healthcare platform connecting patients with doctors — built with Flutter & Laravel.</strong></p>

<p>
  <a href="https://github.com/bashii110/Dr-App/stargazers"><img src="https://img.shields.io/github/stars/bashii110/Dr-App?style=social" /></a>
  <a href="https://github.com/bashii110/Dr-App/network/members"><img src="https://img.shields.io/github/forks/bashii110/Dr-App?style=social" /></a>
  <img src="https://img.shields.io/badge/License-MIT-green.svg" />
  <img src="https://img.shields.io/badge/Status-Active%20Development-brightgreen" />
</p>

<br/>

```
Book appointments. Manage schedules. Review doctors. All in one place.
```

</div>

---

## 📋 Table of Contents

- [✨ Features](#-features)
- [🏗️ Architecture](#️-architecture)
- [📱 Screens](#-screens)
- [🚀 Getting Started](#-getting-started)
- [🔌 API Reference](#-api-reference)
- [🔐 Security](#-security)
- [🛠️ Tech Stack](#️-tech-stack)
- [🤝 Contributing](#-contributing)

---

## ✨ Features

### 👨‍⚕️ For Doctors
| Feature | Description |
|--------|-------------|
| 📊 **Dashboard** | Real-time stats — total appointments, today's schedule, pending confirmations |
| 📅 **Schedule Manager** | Set working days, consultation hours, and slot duration |
| 🗂️ **Patient History** | Expandable patient records with full visit history |
| ✅ **Appointment Control** | Confirm, complete, or cancel appointments with one tap |
| ✏️ **Profile Management** | Update specialisation, bio, consultation fee, and availability |

### 🤒 For Patients
| Feature | Description |
|--------|-------------|
| 🔍 **Doctor Discovery** | Browse & search doctors by name or specialisation |
| 📆 **Smart Booking** | Real-time calendar with available slots (weekends blocked) |
| 📋 **Appointment Tracking** | Live status updates — pending → confirmed → completed |
| ⭐ **Reviews** | Rate and review doctors after completed appointments |
| 🏥 **Medical History** | Full record of past visits with prescriptions |

### 🔒 Auth & Security
- ✉️ **OTP Email Verification** — 6-digit code, 10-minute expiry, brute-force throttling
- 🔑 **Laravel Sanctum** — Token-based API authentication
- 🔄 **Password Reset** — OTP-driven secure reset flow
- 👤 **Role-based Access** — Strict patient/doctor separation throughout

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        Flutter App                          │
│                                                             │
│   ┌──────────┐   ┌──────────┐   ┌──────────┐              │
│   │  Auth    │   │ Patient  │   │  Doctor  │              │
│   │  Screens │   │  Screens │   │  Screens │              │
│   └────┬─────┘   └────┬─────┘   └────┬─────┘              │
│        │              │              │                      │
│        └──────────────┴──────────────┘                      │
│                       │                                     │
│              ┌────────▼────────┐                           │
│              │   ApiService    │   (HTTP + SharedPrefs)    │
│              └────────┬────────┘                           │
│                       │                                     │
│              ┌────────▼────────┐                           │
│              │  AuthProvider   │   (Provider state mgmt)  │
│              └─────────────────┘                           │
└───────────────────────┬─────────────────────────────────────┘
                        │  HTTP / JSON
                        │
┌───────────────────────▼─────────────────────────────────────┐
│                    Laravel 12 API                           │
│                                                             │
│   ┌────────────┐  ┌──────────────┐  ┌─────────────────┐   │
│   │AuthContrl. │  │DoctorContrl. │  │ApptContrl.      │   │
│   └────────────┘  └──────────────┘  └─────────────────┘   │
│                                                             │
│   ┌────────────┐  ┌──────────────┐  ┌─────────────────┐   │
│   │ReviewContrl│  │ProfileContrl │  │Sanctum Tokens   │   │
│   └────────────┘  └──────────────┘  └─────────────────┘   │
│                                                             │
│              ┌──────────────────────┐                      │
│              │  Eloquent ORM Models │                      │
│              └──────────┬───────────┘                      │
└─────────────────────────┼────────────────────────────────── ┘
                          │
              ┌───────────▼───────────┐
              │        MySQL          │
              │  users · doctors      │
              │  appointments · otp   │
              │  reviews · sessions   │
              └───────────────────────┘
```

---

## 📱 Screens

<table>
  <tr>
    <td><img width="80" src="https://github.com/user-attachments/assets/85de2688-246b-4b7a-9a54-e3a959f0da77" /></td>
    <td><img width="80" src="https://github.com/user-attachments/assets/46bc6739-f434-4d2f-a175-16472122c545" /></td>
    <td><img width="80" src="https://github.com/user-attachments/assets/6cdb21ea-f09f-4b83-ba79-1bf6f2526ec9" /></td>
    <td><img width="80" src="https://github.com/user-attachments/assets/bf8e0e3f-d92f-4a55-b4a7-75d92698f007" /></td>
    <td><img width="80" src="https://github.com/user-attachments/assets/16e3c748-f2d4-48f0-88a9-0a2a015c268a" /></td>
    <td><img width="80" src="https://github.com/user-attachments/assets/288da965-72a1-4158-85e0-b25a0af2d469" /></td>
    <td><img width="80" src="https://github.com/user-attachments/assets/0dc06f53-869b-405c-8f9b-9e706b8fb760" /></td>
    <td><img width="80" src="https://github.com/user-attachments/assets/f429bad1-c575-429b-934f-8e8debfb619b" /></td>
    <td><img width="80" src="https://github.com/user-attachments/assets/5ebbeeb8-3054-44fa-8ab3-68197c8f8b9a" /></td>
  </tr>
</table>

<details>
<summary><strong>🔐 Auth Flow</strong></summary>

```
Login Screen
   ├── Email + Password
   ├── Forgot Password (OTP modal)
   └── Navigate to Register

Register Screen
   ├── Role Selector (Patient / Doctor)
   ├── Name, Email, Password
   └── → OTP Verification Screen
           ├── 6-digit PIN input
           ├── 60s countdown timer
           └── Resend OTP
```
</details>

<details>
<summary><strong>🤒 Patient Flow</strong></summary>

```
Home Screen
   ├── Greeting + Search bar
   ├── Specialisation category chips
   └── Doctor cards (rating, fee, experience)
         └── Doctor Detail Screen
               ├── Stats (rating, reviews, experience, fee)
               ├── About tab
               ├── Reviews tab
               └── Book Appointment Button
                     └── Booking Screen
                           ├── Interactive calendar
                           ├── Available time slots grid
                           ├── Notes field
                           └── Booking summary + Confirm

Appointments Screen (tabbed)
   ├── Pending
   ├── Confirmed
   ├── Completed (with Write Review CTA)
   └── Cancelled

Medical History Screen
   ├── Completed appointments
   └── Cancelled appointments
```
</details>

<details>
<summary><strong>👨‍⚕️ Doctor Flow</strong></summary>

```
Dashboard Screen
   ├── Stats grid (total, pending, completed, cancelled)
   ├── Today's appointments
   └── Upcoming appointments

Appointments Screen (tabbed)
   ├── Pending → [Confirm] [Complete] [Cancel]
   ├── Confirmed → [Complete] [Cancel]
   ├── Completed
   └── Cancelled

Patient History Screen
   ├── Search by patient name
   └── Expandable cards (visit count, last visit, all appointments)

Schedule Screen
   ├── Status toggle (Available / Busy / Offline)
   ├── Working days selector
   ├── Consultation hours time pickers
   ├── Slot duration slider (15/30/45/60 min)
   └── Live slot preview grid

Profile / Edit Profile Screen
```
</details>

---

## 🚀 Getting Started

### Prerequisites

- Flutter `>=3.6.2`
- PHP `>=8.2`
- Composer
- MySQL
- Laravel `12.x`

---

### 🔧 Backend Setup (Laravel)

```bash
# 1. Clone the repo
git clone https://github.com/bashii110/Dr-App.git
cd Dr-App

# 2. Install PHP dependencies
composer install

# 3. Set up environment
cp .env.example .env
php artisan key:generate

# 4. Configure your .env
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=doctor_app
DB_USERNAME=root
DB_PASSWORD=your_password

MAIL_MAILER=smtp
MAIL_HOST=smtp.gmail.com
MAIL_PORT=587
MAIL_USERNAME=your@gmail.com
MAIL_PASSWORD=your_app_password
MAIL_FROM_ADDRESS=your@gmail.com

# 5. Run migrations
php artisan migrate

# 6. Start the server
php artisan serve
```

> 💡 **Dev tip:** OTP codes are logged to `storage/logs/laravel.log` as a fallback when email isn't configured yet.

---

### 📱 Flutter Setup

```bash
# Navigate to Flutter project root
cd doctor_app   # or wherever your Flutter files live

# Install dependencies
flutter pub get

# Update the API base URL in lib/service/api_service.dart
# Android emulator:  http://10.0.2.2:8000/api
# Physical device:   http://YOUR_PC_IP:8000/api

# Run the app
flutter run
```

---

## 🔌 API Reference

### Auth Endpoints

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| `POST` | `/api/auth/register` | Register patient or doctor | ❌ |
| `POST` | `/api/auth/verify-otp` | Verify email with OTP | ❌ |
| `POST` | `/api/auth/resend-otp` | Resend OTP (throttled) | ❌ |
| `POST` | `/api/auth/login` | Login, returns token | ❌ |
| `POST` | `/api/auth/logout` | Revoke token | ✅ |
| `GET` | `/api/auth/me` | Get authenticated user | ✅ |
| `POST` | `/api/auth/forgot-password` | Send reset OTP | ❌ |
| `POST` | `/api/auth/reset-password` | Reset with OTP | ❌ |

### Doctor Endpoints (Public)

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/api/doctors` | List approved doctors (search, filter, sort) |
| `GET` | `/api/doctors/{id}` | Doctor full profile |
| `GET` | `/api/doctors/categories` | All available specialisations |
| `GET` | `/api/doctors/{id}/slots` | Available time slots for a date |
| `GET` | `/api/doctors/{id}/reviews` | Doctor reviews (paginated) |

### Appointment Endpoints (Auth Required)

| Method | Endpoint | Description |
|--------|----------|-------------|
| `POST` | `/api/appointments` | Book appointment |
| `GET` | `/api/appointments` | List my appointments |
| `POST` | `/api/appointments/{id}/cancel` | Cancel appointment |
| `POST` | `/api/appointments/{id}/confirm` | Doctor confirms |
| `POST` | `/api/appointments/{id}/complete` | Doctor marks complete |
| `POST` | `/api/appointments/{id}/reschedule` | Reschedule |
| `GET` | `/api/doctor/appointments` | Doctor's appointment list |
| `PATCH` | `/api/doctor/appointments/{id}/status` | Update status |

<details>
<summary><strong>📦 Sample API Response — Book Appointment</strong></summary>

```json
{
  "status": 201,
  "message": "Appointment booked successfully!",
  "appointment": {
    "id": 42,
    "status": "pending",
    "appointment_date": "2025-06-15",
    "appointment_time": "09:00",
    "fee": 500,
    "doctor": {
      "id": 3,
      "name": "Dr. Sarah Ahmed",
      "category": "Cardiology",
      "hospital": "PIMS Islamabad"
    },
    "patient": {
      "id": 7,
      "name": "Bashir Khan",
      "email": "bashir@example.com"
    }
  }
}
```
</details>

---

## 🔐 Security

Security audit completed — 18 issues identified and addressed across four severity levels:

| Severity | Issue | Status |
|----------|-------|--------|
| 🔴 Critical | Hardcoded local IP + plain HTTP | ⏳ HTTPS pending |
| 🔴 Critical | No rate limiting on auth endpoints | ⏳ In progress |
| 🟠 High | Tokens not revoked on password reset | ✅ Fixed |
| 🟠 High | OTP brute-force vulnerability | ✅ Throttled (3/10 min) |
| 🟡 Medium | Missing file upload validation | ✅ Fixed |
| 🟡 Medium | CORS misconfiguration | ⏳ In progress |
| 🟡 Medium | Sensitive data in device logs | ✅ Fixed |
| 🟢 Low | Sanctum tokens never expiring | ⏳ In progress |

---

## 🗄️ Database Schema

```
users
 ├── id, name, email, password, type (patient|doctor)
 ├── phone, is_email_verified, profile_photo_path
 └── timestamps

doctors
 ├── id, doc_id → users.id
 ├── category, experience, patients, bio_data
 ├── status, fee, rating, hospital
 ├── education, address, languages (JSON)
 └── is_available, available_from, available_to

appointments
 ├── id, patient_id → users.id, doctor_id → doctors.id
 ├── appointment_date, appointment_time
 ├── status (pending|confirmed|completed|cancelled)
 ├── type (in_person|video), notes, fee
 ├── prescription, doctor_notes
 └── cancelled_at, confirmed_at, completed_at

otp_codes
 ├── id, user_id → users.id
 ├── code, type (email_verify|password_reset)
 ├── expires_at, used (boolean)
 └── timestamps

reviews
 ├── id, doctor_id, patient_id, appointment_id
 ├── rating (1-5), comment
 └── timestamps
```

---

## 🛠️ Tech Stack

### Frontend
| Technology | Purpose |
|-----------|---------|
| **Flutter 3.6** | Cross-platform mobile UI |
| **Provider** | State management |
| **http** | REST API calls |
| **shared_preferences** | Token persistence |
| **table_calendar** | Booking calendar |
| **pin_code_fields** | OTP input |
| **shimmer** | Loading skeletons |
| **flutter_rating_bar** | Doctor reviews |

### Backend
| Technology | Purpose |
|-----------|---------|
| **Laravel 12** | REST API framework |
| **Laravel Sanctum** | Token authentication |
| **Eloquent ORM** | Database abstraction |
| **Laravel Mail** | OTP email delivery |
| **Laravel Notifications** | In-app + email notifications |
| **MySQL** | Primary database |

---

## 📁 Project Structure

```
Dr-App/
│
├── 📂 app/
│   ├── Http/Controllers/
│   │   ├── AuthController.php        ← Register, OTP, Login, Reset
│   │   ├── DoctorController.php      ← Listings, profile, slots, dashboard
│   │   ├── AppointmentController.php ← Book, cancel, confirm, complete
│   │   ├── ReviewController.php      ← Submit + fetch reviews
│   │   └── ProfileController.php     ← Profile, password, history
│   ├── Models/
│   │   ├── User.php
│   │   ├── Doctor.php
│   │   ├── Appointment.php
│   │   ├── Review.php
│   │   └── OtpCode.php
│   ├── Mail/OtpMail.php
│   └── Notifications/NewAppointmentNotification.php
│
├── 📂 routes/api.php                 ← All API routes
├── 📂 database/migrations/           ← Full schema history
│
└── 📂 lib/                           ← Flutter source
    ├── auth/                         ← Login, Register, OTP screens
    ├── screens/
    │   ├── patients/                 ← Home, booking, appointments, history
    │   ├── doctor/                   ← Dashboard, schedule, patients, profile
    │   └── shared/                   ← Profile screen
    ├── models/app_models.dart        ← Typed Dart models
    ├── service/api_service.dart      ← Centralised HTTP layer
    ├── provider/auth_provider.dart   ← Auth state management
    ├── components/custom_widget.dart ← Reusable UI components
    └── utils/
        ├── config.dart               ← Theme, colours, spacing
        └── main_layout.dart          ← Role-based navigation
```

---

## 🤝 Contributing

Contributions are welcome! Here's how to get started:

```bash
# 1. Fork the repository
# 2. Create your feature branch
git checkout -b feature/your-feature-name

# 3. Commit your changes
git commit -m "feat: add your feature description"

# 4. Push to your branch
git push origin feature/your-feature-name

# 5. Open a Pull Request
```

### 📌 Planned Features
- [ ] Video consultation support
- [ ] Push notifications (FCM)
- [ ] Prescription PDF generation
- [ ] Admin panel for doctor approval
- [ ] Payment gateway integration
- [ ] HTTPS + production deployment

---

## 📄 License

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details.

---

<div align="center">

**Built with ❤️ by [Bashir](https://github.com/bashii110)**

⭐ **Star this repo** if you found it useful!

<a href="https://github.com/bashii110/Dr-App">
  <img src="https://img.shields.io/badge/View%20on-GitHub-black?style=for-the-badge&logo=github" />
</a>

</div>
