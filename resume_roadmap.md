# 🥼 DR Detection - UPDATED ROADMAP v3.0

**Last Updated:** Februari 2, 2025 - After Home Screen & Design System Complete  
**Project Type:** Medical App - Diabetic Retinopathy Detection System  
**Tech Stack:** Flutter + Hive CE + Dio + Provider + GoRouter

---

## 📋 Table of Contents

1. [Current Project Structure](#current-structure)
2. [Development Progress Checklist](#progress-checklist)
3. [Screen Development Priority](#screen-priority)
4. [Feature Specifications](#feature-specs)
5. [Export Data Feature](#export-feature)
6. [Design System Guidelines](#design-guidelines)
7. [API Endpoints Reference](#api-reference)
8. [Development Guidelines](#dev-guidelines)
9. [Next Actions](#next-actions)

---

## 🏗 Current Project Structure {#current-structure}

```
lib/
├── main.dart ✅
├── hive_registrar.g.dart ⚙️
│
├── core/
│   ├── constants/
│   │   ├── api_constants.dart ✅
│   │   ├── app_constants.dart ✅
│   │   └── spacing.dart ✅
│   ├── l10n/
│   │   ├── app_localizations.dart ✅
│   │   ├── app_localizations_en.dart ✅
│   │   └── app_localizations_id.dart ✅
│   ├── network/
│   │   ├── api_error_handler.dart ✅
│   │   ├── api_interceptor.dart ✅
│   │   ├── dio_clients.dart ✅
│   │   └── external_dio_client.dart ✅
│   ├── routes/
│   │   ├── app_router.dart ✅
│   │   └── route_names.dart ✅
│   ├── theme/
│   │   ├── app_colors.dart ✅
│   │   ├── app_gradients.dart ✅
│   │   ├── app_text_styles.dart ✅
│   │   └── app_theme.dart ✅
│   └── utils/
│       ├── chart_helper.dart ✅
│       ├── error_mapper.dart ✅
│       ├── greeting_helper.dart ✅
│       ├── helpers.dart ✅
│       ├── stats_calculator.dart ✅
│       └── validators.dart ✅
│
├── data/
│   ├── local/
│   │   ├── hive_box_names.dart ✅
│   │   ├── hive_helper.dart ✅
│   │   ├── secure_storage_helper.dart ✅
│   │   └── shared_prefs_helper.dart ✅
│   ├── models/
│   │   ├── auth/
│   │   │   ├── auth_response.dart ✅
│   │   │   └── auth_response.g.dart ⚙️
│   │   ├── dashboard/
│   │   │   ├── dashboard_model.dart ✅
│   │   │   └── dashboard_model.g.dart ⚙️
│   │   ├── detection/
│   │   │   ├── detection_model.dart ✅
│   │   │   └── detection_model.g.dart ⚙️
│   │   ├── location/
│   │   │   ├── location_model.dart ✅
│   │   │   └── location_model.g.dart ⚙️
│   │   ├── patient/
│   │   │   ├── patient_model.dart ✅
│   │   │   └── patient_model.g.dart ⚙️
│   │   ├── response/
│   │   │   ├── api_response_model.dart ✅
│   │   │   └── api_response_model.g.dart ⚙️
│   │   └── user/
│   │       ├── user_model.dart ✅
│   │       └── user_model.g.dart ⚙️
│   ├── repositories/
│   │   ├── auth_repository.dart ✅
│   │   ├── dashboard_repository.dart ✅
│   │   ├── detection_repository.dart ✅
│   │   ├── location_repository.dart ✅
│   │   ├── patient_repository.dart ✅
│   │   └── user_repository.dart ✅
│   └── services/
│       ├── auth_service.dart ✅
│       ├── dashboard_service.dart ✅
│       ├── detection_service.dart ✅
│       ├── location_service.dart ✅
│       ├── patient_service.dart ✅
│       └── user_service.dart ✅
│
├── features/
│   └── export/
│       ├── widgets/
│       │   └── export_dialog.dart ✅
│       ├── export.dart ✅
│       └── export_service.dart ✅
│
├── providers/
│   ├── auth_provider.dart ✅
│   ├── dashboard_provider.dart ✅
│   ├── detection_provider.dart ✅
│   ├── language_provider.dart ✅
│   ├── location_provider.dart ✅
│   ├── patient_provider.dart ✅
│   └── user_provider.dart ✅
│
├── screens/
│   ├── auth/
│   │   ├── forgot_password_screen.dart ❌ (TODO)
│   │   ├── login_screen.dart ✅
│   │   ├── otp_verification_login_screen.dart ✅
│   │   ├── otp_verification_signup_screen.dart ✅
│   │   ├── reset_password_screen.dart ❌ (TODO)
│   │   └── signup_screen.dart ✅
│   ├── detection/
│   │   ├── detection_detail_screen.dart ❌ (TODO)
│   │   ├── detection_history_screen.dart ❌ (TODO)
│   │   └── detection_screen.dart ✅ (Start Detection Flow)
│   ├── home/
│   │   └── home_screen.dart ✅
│   ├── patient/
│   │   ├── add_patient_screen.dart ✅
│   │   ├── edit_patient_screen.dart ❌ (TODO)
│   │   ├── patient_detail_screen.dart ✅ (Chart merged here)
│   │   └── patient_list_screen.dart ✅
│   └── profile/
│       ├── edit_profile_screen.dart ❌ (TODO)
│       └── profile_screen.dart ✅
│
└── widgets/
    ├── cards/
    │   ├── latest_detection_card.dart ✅
    │   └── stat_card.dart ✅
    ├── charts/
    │   ├── chart_filter_widget.dart ✅
    │   ├── chart_legend.dart ✅
    │   └── detection_progress_chart.dart ✅
    ├── states/
    │   └── empty_detection_state.dart ✅
    ├── custom_button.dart ✅
    ├── custom_text_field.dart ✅
    ├── language_switcher.dart ✅
    ├── medical_card.dart ✅
    ├── patient_avatar.dart ✅
    └── scaffold_with_navbar.dart ✅
```

---

## ✅ Development Progress Checklist {#progress-checklist}

### **PHASE 1: Foundation & Config** ✅ 100% COMPLETE

- [x] Project structure setup
- [x] Dependencies installation (Hive CE, Dio, Provider, GoRouter)
- [x] Design system (colors, gradients, typography, theme)
- [x] Reusable widgets (button, text field, cards, avatar)
- [x] Constants (API endpoints, app constants, spacing)
- [x] Utils (validators, helpers, greeting_helper, error_mapper)
- [x] Network layer (Dio client, interceptor, error handler, external client)
- [x] Routing (GoRouter with auth guard + StatefulShellRoute)
- [x] Local storage (Hive, SecureStorage, SharedPrefs)
- [x] Localization: Full L10n support (EN/ID)
- [x] Error Handling: ApiErrorHandler + ErrorMapper

---

### **PHASE 2: Backend Integration** ✅ 100% COMPLETE

- [x] Dashboard API integrated
- [x] All services connected to backend
- [x] Hybrid cache strategy (Hive + API)
- [x] Token refresh & auto-logout

---

### **PHASE 3: Data Layer** ✅ 100% COMPLETE

- [x] All Models with Hive TypeAdapters
- [x] All Services (API calls)
- [x] All Repositories (business logic)
- [x] All Providers (state management)

---

### **PHASE 4: UI Screens** ⚠️ 20% COMPLETE

#### Completed Screens:
- [x] Login Screen (Modern Glassmorphism)
- [x] OTP Verification Login Screen
- [x] Home Screen (Dashboard v4 - Final Design)

#### Pending Screens (by Priority):
- [ ] **P0**: Profile Screen (LOGOUT + Export + Language)
- [ ] **P1**: Signup Screen (Cascade dropdown wilayah)
- [ ] **P2**: Patient List Screen
- [ ] **P3**: Add Patient Screen
- [ ] **P4**: Start Detection + Result Screen
- [ ] **P5**: Patient Detail Screen (with tabs + Export)
- [ ] **P6**: Detection History Screen
- [ ] **P7**: Detection Detail Screen
- [ ] Edit Profile Screen
- [ ] Change Password Screen
- [ ] OTP Verification Signup Screen
- [ ] Forgot/Reset Password Screens

---

### **PHASE 5: Export Feature** ⏳ IMPLEMENT NOW (with Profile & Patient Detail)

- [ ] Export Service
- [ ] PDF Templates (Patient Report, Detection Report, Full Report)
- [ ] Excel Export
- [ ] Integration in Profile & Patient Detail screens

---

## 🎯 Screen Development Priority {#screen-priority}

| Priority | Screen | Reason | Prompt File |
|----------|--------|--------|-------------|
| **P0** | **Profile Screen** | LOGOUT + Export + Language | `PROMPT_00_PROFILE_SCREEN.md` |
| **P1** | **Signup Screen** | User register + profession | `PROMPT_01_SIGNUP_SCREEN.md` |
| **P2** | Patient List Screen | Core feature manage pasien | `PROMPT_02_PATIENT_LIST_SCREEN.md` |
| **P3** | Add Patient Screen | CRUD pasien | `PROMPT_03_ADD_PATIENT_SCREEN.md` |
| **P4** | Start Detection + Result | Core feature deteksi | `PROMPT_04 + 05` |
| **P5** | Patient Detail Screen | Detail + Export per pasien | `PROMPT_08_PATIENT_DETAIL_SCREEN.md` |
| **P6** | Detection History Screen | Riwayat semua deteksi | `PROMPT_06_DETECTION_HISTORY_SCREEN.md` |
| **P7** | Detection Detail Screen | Detail hasil deteksi | `PROMPT_07_DETECTION_DETAIL_SCREEN.md` |

---

## 📱 Feature Specifications {#feature-specs}

### Profile Screen Features:

| Section | Items | Implementation |
|---------|-------|----------------|
| **Header** | Avatar, Name+Title, Profession, Email | ✅ Implement |
| **Stats** | Scans, Patients, Detections | ✅ Implement |
| **Account** | Edit Profile, Change Password | ✅ Functional |
| **Data** | Export Data (PDF/Excel) | ✅ Implement NOW |
| **Settings** | **Language Switcher** | ✅ Implement |
| **About** | Help, Terms, Privacy | 🟡 Placeholder "Coming Soon" |
| **Sign Out** | Logout + confirm dialog | ✅ **PRIORITY** |

**TIDAK ADA:**
- ❌ Delete Account (no endpoint)
- ❌ Notifications (no feature)

---

### Signup Screen Features:

#### Form Fields (SEMUA WAJIB DI UI):

**Personal Information:**
| Field | Type | Validation |
|-------|------|------------|
| Photo Profile | Image Picker | Required |
| Full Name | TextInput | Min 2 chars, required |
| Email | TextInput | Email format, required |
| Password | TextInput + Toggle | Min 8, letter+number, required |
| Confirm Password | TextInput + Toggle | Match password, required |
| Phone Number | TextInput | Format 08xxxxxxxxxx, required |
| Date of Birth | DatePicker | Not future, required |
| Profession | Dropdown | From AppConstants, required |
| Gender | Radio/Toggle | Male/Female, required |

**Address Information (CASCADE DROPDOWN dari API Wilayah):**
| Field | Type | Source API |
|-------|------|------------|
| Province | Dropdown | GET /provinces.json |
| City/Regency | Dropdown | GET /regencies/{provinceId}.json |
| District | Dropdown | GET /districts/{regencyId}.json |
| Village | Dropdown | GET /villages/{districtId}.json |
| Detailed Address | TextInput | Required |
| Assignment Location | TextInput | Required (nama RS/Klinik) |

**TIDAK ADA:**
- ❌ Checkbox Terms & Conditions (belum ada)

---

### Profession Options & Greeting:

```dart
professionOptions = [
  'Ophthalmologist',        // → Dr.
  'Endocrinologist',        // → Dr.
  'General Practitioner',   // → Dr. (atau "Dokter Umum")
  'Optometrist',            // → (no title)
  'Nurse',                  // → Ners (atau "Perawat")
  'Medical Student',        // → (no title)
  'Healthcare Assistant',   // → (no title)
  'Other',                  // → Mr./Ms. based on gender
];
```

`greeting_helper.dart` sudah support BOTH:
- English: `"General Practitioner"` → `"Dr."`
- Indonesian: `"Dokter Umum"` → `"Dr."`

---

## 📊 Export Data Feature {#export-feature}

### Approach: **HYBRID**
| Format | Method | Use Case |
|--------|--------|----------|
| **PDF** | Custom Template | Professional medical report |
| **Excel** | Auto Generate | Raw data untuk analisis |

---

### Export Locations:

#### 1. Profile Screen (Semua Data User):
```
Export Data Dialog:
├── Export All Patients (PDF) 
├── Export All Patients (Excel)
├── Export All Detections (PDF)
├── Export All Detections (Excel)
└── Export Full Report (PDF) → Summary + semua data
```

#### 2. Patient Detail Screen (Per Pasien):
```
More Menu atau Export Button:
├── Export Patient Info (PDF)
├── Export Detection History (PDF)
├── Export Detection History (Excel)
└── Export Full Patient Report (PDF) → Info + History + Chart
```

---

### PDF Template - Patient Detection Report:

```
┌─────────────────────────────────────────────────────────────┐
│  🔬 DR DETECTION REPORT                        [App Logo]   │
│  Generated: 18 Dec 2024, 10:30 AM                          │
├─────────────────────────────────────────────────────────────┤
│  PATIENT INFORMATION                                        │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Name: John Doe                                       │   │
│  │ ID: PD-2024-001         Gender: Male                │   │
│  │ Age: 52 years           DOB: 15 Jan 1972            │   │
│  │ Phone: 081234567890                                  │   │
│  └─────────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────────┤
│  DETECTION HISTORY (Total: 5 screenings)                   │
│  ┌────────┬──────────┬─────────────┬────────┬──────────┐   │
│  │ Date   │ Eye      │ Result      │ Conf.  │ Risk     │   │
│  ├────────┼──────────┼─────────────┼────────┼──────────┤   │
│  │ 18 Dec │ Right    │ Moderate DR │ 92%    │ ⚠ High   │   │
│  │ 15 Nov │ Left     │ Mild DR     │ 88%    │ 🟡 Med   │   │
│  │ 10 Oct │ Right    │ No DR       │ 95%    │ 🟢 Low   │   │
│  └────────┴──────────┴─────────────┴────────┴──────────┘   │
├─────────────────────────────────────────────────────────────┤
│  LATEST RESULT DETAILS                                      │
│  [Fundus Image]     Classification: Moderate NPDR          │
│                     Confidence: 92%                         │
│                     Risk Level: High Risk                   │
│                                                             │
│  Recommendations:                                           │
│  • Schedule follow-up in 2-4 weeks                         │
│  • Monitor blood sugar levels                              │
│  • Consult ophthalmologist                                 │
├─────────────────────────────────────────────────────────────┤
│  DR Detection App v1.0.0 | Confidential Medical Record     │
│  Operator: Dr. Evelyn Reed | Page 1 of 1                   │
└─────────────────────────────────────────────────────────────┘
```

---

### Required Packages for Export:

```yaml
# pubspec.yaml
dependencies:
  pdf: ^3.10.0           # Generate PDF
  printing: ^5.11.0      # Print & Share PDF
  excel: ^4.0.0          # Generate Excel
  share_plus: ^7.0.0     # Share files
  path_provider: ^2.1.0  # Access storage
```

---

### Export Implementation Files:

```
lib/
└── features/
    └── export/
        ├── export_service.dart           # Main export logic
        ├── templates/
        │   ├── patient_report_template.dart    # Single patient PDF
        │   ├── detection_report_template.dart  # Detection history PDF
        │   └── full_report_template.dart       # Complete report PDF
        └── widgets/
            └── export_dialog.dart        # Export options dialog
```

---

## 🎨 Design System Guidelines {#design-guidelines}

### Design Principles (WAJIB DIIKUTI):

1. **Modern & Elegant** - Bukan kotak-kotak kaku
2. **Glassmorphism** - Subtle transparansi
3. **Curved Elements** - ClipPath header, rounded corners 12-20dp
4. **Soft Shadows** - blur 8-20, alpha 0.04-0.08
5. **Gradient Accents** - Header, buttons, highlights
6. **Staggered Animations** - fadeIn + slide dengan delay bertingkat
7. **Consistent Spacing** - Gunakan `Spacing` class, JANGAN hardcode

---

### Color Palette:

```dart
// Primary Colors
primary: #2E7CF6
primaryLight: #5BA4FC
secondary: #38BDF8

// Background
scaffoldBackground: #F8FAFC
surface: #FFFFFF

// Text
textPrimary: #1F2937
textSecondary: #6B7280
textDisabled: #9CA3AF

// Classification Colors
noDR: #10B981      // Green (0)
mild: #F59E0B      // Yellow (1)
moderate: #F97316  // Orange (2)
severe: #EF4444    // Red (3)
proliferative: #7C3AED  // Purple (4)

// Status
success: #10B981
warning: #F59E0B
error: #EF4444
```

---

### Key Design References:

| Screen | Design Elements |
|--------|-----------------|
| **Login** | Curved gradient header, floating white card, gradient button |
| **Home** | ClipPath curved header (220px), floating stats cards, 2-column grid, soft shadows |
| **Profile** | Similar to Home - curved header, overlapping avatar, menu sections |

---

### Spacing System:

```dart
// Values (8dp grid)
xxs: 2    xs: 4    sm: 8    md: 16    lg: 24    xl: 32    xxl: 48    xxxl: 64

// Usage
Spacing.verticalSM      // SizedBox(height: 8)
Spacing.horizontalMD    // SizedBox(width: 16)
Spacing.paddingLG       // EdgeInsets.all(24)
Spacing.radiusMD        // BorderRadius.circular(12)
Spacing.radiusXL        // BorderRadius.circular(20)
Spacing.avatarMD        // 52 (avatar size)
Spacing.iconSM          // 16 (icon size)
```

---

## 🌐 API Endpoints Reference {#api-reference}

### Auth Endpoints:
```
POST /auth/signup/           # Register new user
POST /auth/login/            # Login with email/password
POST /auth/verify-otp/       # Verify OTP (login)
POST /auth/verify-signup-otp/ # Verify OTP (signup)
POST /auth/resend-otp/       # Resend OTP
POST /auth/logout/           # Logout
POST /auth/change-password/  # Change password
POST /auth/forgot-password/  # Request reset
POST /auth/reset-password/   # Reset with token
```

### User Endpoints:
```
GET  /users/me/              # Get current user
PUT  /users/me/              # Update profile
POST /users/me/photo/        # Upload photo
```

### Patient Endpoints:
```
GET    /patients/            # List patients (?skip=0&limit=20&search=)
POST   /patients/            # Create patient
GET    /patients/{code}/     # Get patient detail
PUT    /patients/{code}/     # Update patient
DELETE /patients/{code}/     # Delete patient
```

### Detection Endpoints:
```
GET  /detections/            # List detections (history)
POST /detections/analyze/    # Start detection (multipart)
POST /detections/save/       # Save detection result
GET  /detections/{id}/       # Get detection detail
DELETE /detections/{id}/     # Delete detection
```

### Dashboard Endpoints:
```
GET /dashboard/stats/        # Get dashboard statistics
```

### Wilayah API (External - emsifa):
```
Base: https://www.emsifa.com/api-wilayah-indonesia/api

GET /provinces.json                    # List provinces
GET /regencies/{provinceId}.json       # List regencies by province
GET /districts/{regencyId}.json        # List districts by regency
GET /villages/{districtId}.json        # List villages by district
```

---

## 📝 Development Guidelines {#dev-guidelines}

### 1. File & Folder Naming:
```
screens/auth/signup_screen.dart
screens/profile/profile_screen.dart
features/export/export_service.dart
widgets/export_dialog.dart
```

### 2. State Management Pattern:
```dart
// For actions (button press, init):
final provider = Provider.of<XProvider>(context, listen: false);
await provider.loadData();

// For UI updates:
Consumer<XProvider>(
  builder: (context, provider, child) {
    if (provider.isLoading) return LoadingWidget();
    return DataWidget(data: provider.data);
  },
)
```

### 3. Error Handling:
```dart
try {
  await repository.someMethod();
} on ApiException catch (e) {
  if (mounted) {
    Helpers.showErrorSnackbar(context, e.getTranslatedMessage(context));
  }
} catch (e) {
  if (mounted) {
    Helpers.showErrorSnackbar(context, l10n.errorGeneric);
  }
}
```

### 4. Validation Pattern:
```dart
// Use Validators from validators.dart
Validators.validateRequired(value, fieldName)
Validators.validateEmail(value)
Validators.validatePassword(value)
Validators.validateConfirmPassword(password, confirm)
Validators.validatePhone(value)
Validators.validateMinLength(value, min, fieldName)
```

### 5. Localization:
```dart
final l10n = AppLocalizations.of(context);
Text(l10n.signUp)
Text(l10n.errorEmailInvalid)
```

### 6. Animation Pattern:
```dart
// Staggered animation for lists
ListView.builder(
  itemBuilder: (context, index) {
    return Widget()
      .animate(delay: (50 * index).ms)
      .fadeIn(duration: 300.ms)
      .slideX(begin: 0.03, end: 0);
  },
)
```

### 7. Image Display:
```dart
CachedNetworkImage(
  imageUrl: imageUrl,
  width: 48,
  height: 48,
  fit: BoxFit.cover,
  placeholder: (_, __) => Container(
    color: AppColors.borderLight,
    child: CircularProgressIndicator(strokeWidth: 2),
  ),
  errorWidget: (_, __, ___) => Icon(Icons.image_not_supported),
)
```

### 8. Logging Convention:
```dart
debugPrint('✅ [ClassName] Success message');
debugPrint('❌ [ClassName] Error: $error');
debugPrint('🔄 [ClassName] Loading...');
debugPrint('📊 [ClassName] Data: $data');
```

---

## 🎯 Next Actions {#next-actions}

### **IMMEDIATE PRIORITY:**

#### 1. 🔥 Profile Screen (P0) - ~3-4 hours
```
Target: profile_screen.dart + export_service.dart

Checklist:
- [ ] Curved gradient header (like Home)
- [ ] Avatar with camera overlay
- [ ] User info (name + title, profession, email)
- [ ] Stats row (Scans, Patients, Detections)
- [ ] Account section:
    - [ ] Edit Profile → Navigate
    - [ ] Change Password → Navigate/Dialog
- [ ] Data section:
    - [ ] Export Data → Export Dialog
- [ ] Settings section:
    - [ ] Language Switcher (LanguageSwitcher widget)
- [ ] About section (placeholder):
    - [ ] Help & Support → "Coming Soon"
    - [ ] Terms of Service → "Coming Soon"
    - [ ] Privacy Policy → "Coming Soon"
- [ ] App Version text
- [ ] Sign Out button with confirm dialog
- [ ] Export Service implementation
```

**Milestone:** User can logout + export data + switch language

---

#### 2. 🔥 Signup Screen (P1) - ~4-5 hours
```
Target: signup_screen.dart

Checklist:
- [ ] Design mirip Login Screen (curved header)
- [ ] Photo picker (gallery/camera)
- [ ] Personal info form (all required):
    - [ ] Full Name
    - [ ] Email
    - [ ] Password + visibility toggle
    - [ ] Confirm Password
    - [ ] Phone Number
    - [ ] Date of Birth picker
    - [ ] Profession dropdown
    - [ ] Gender toggle
- [ ] CASCADE dropdown wilayah:
    - [ ] Province → Load Cities
    - [ ] City → Load Districts
    - [ ] District → Load Villages
    - [ ] Use LocationProvider
    - [ ] Loading state per dropdown
- [ ] Detailed Address
- [ ] Assignment Location
- [ ] Form validation (all fields required)
- [ ] Submit → API → Navigate to OTP
```

**Milestone:** User can register with full info including wilayah

---

#### 3. Patient List Screen (P2) - ~2-3 hours
```
Target: patient_list_screen.dart

Checklist:
- [ ] AppBar with search & filter icons
- [ ] Filter chips (All, Male, Female, High Risk)
- [ ] Search functionality with debounce
- [ ] PatientCard list (from medical_card.dart)
- [ ] Pull to refresh
- [ ] Pagination / Load more
- [ ] FAB → Add Patient
- [ ] Empty state
- [ ] Shimmer loading
```

---

#### 4. Add Patient Screen (P3) - ~2 hours
```
Target: add_patient_screen.dart

Checklist:
- [ ] Form fields:
    - [ ] Patient Code (unique)
    - [ ] Full Name
    - [ ] Gender toggle
    - [ ] Date of Birth
- [ ] Validation
- [ ] Submit → API → Back with refresh
- [ ] Reusable for Edit (isEdit flag)
```

---

#### 5. Start Detection + Result (P4) - ~4-5 hours
```
Target: start_detection_screen.dart + detection_result_screen.dart

Start Detection:
- [ ] Patient search/select
- [ ] Eye side selection (Left/Right cards)
- [ ] Image picker (gallery/camera)
- [ ] Image preview with remove option
- [ ] Start Analysis button → Loading
- [ ] Navigate to Result

Detection Result:
- [ ] Patient info header
- [ ] Fundus image preview
- [ ] Warning banner (if high risk)
- [ ] Classification result with badge
- [ ] Confidence circle indicator
- [ ] Probability bars (5 classes)
- [ ] AI description text
- [ ] Bottom actions: Cancel, Retry, Save
```

---

#### 6. Patient Detail Screen (P5) - ~3-4 hours
```
Target: patient_detail_screen.dart

Checklist:
- [ ] Patient header card
- [ ] Tab bar (Overview, History, Progress)
- [ ] Overview tab:
    - [ ] Stats (Total Detections, Avg Confidence)
    - [ ] Latest detection result
    - [ ] Patient info
    - [ ] Start New Detection button
- [ ] History tab:
    - [ ] Detection list with filter
    - [ ] DetectionCard compact
- [ ] Progress tab:
    - [ ] Line chart (fl_chart)
    - [ ] Period filter
    - [ ] Key statistics
- [ ] Export menu/button
- [ ] More menu (Edit, Delete, Export)
```

---

#### 7. Detection History Screen (P6) - ~2-3 hours
```
Target: detection_history_screen.dart

Checklist:
- [ ] AppBar with search & filter
- [ ] Expandable filter section
- [ ] Grouped list by date (Today, Yesterday, etc)
- [ ] DetectionCard items
- [ ] Pull to refresh
- [ ] Pagination
- [ ] FAB → Start Detection
- [ ] Empty state
```

---

#### 8. Detection Detail Screen (P7) - ~2-3 hours
```
Target: detection_detail_screen.dart

Checklist:
- [ ] Full fundus image (hero)
- [ ] Patient info card
- [ ] Classification result
- [ ] Confidence indicator
- [ ] Detection info (date, device, operator)
- [ ] Comparison with previous (if exists)
- [ ] AI Recommendations list
- [ ] Action buttons (Share, Download, Delete)
```

---

### **ESTIMATED TOTAL: ~25-30 hours**

---

## 📁 Prompt Files for New Conversation

```
/mnt/user-data/outputs/
├── PROMPT_00_PROFILE_SCREEN.md    # P0 - Logout + Export + Language
├── PROMPT_01_SIGNUP_SCREEN.md     # P1 - Registration + Wilayah
├── PROMPT_02_PATIENT_LIST_SCREEN.md
├── PROMPT_03_ADD_PATIENT_SCREEN.md
├── PROMPT_04_START_DETECTION_SCREEN.md
├── PROMPT_05_DETECTION_RESULT_SCREEN.md
├── PROMPT_06_DETECTION_HISTORY_SCREEN.md
├── PROMPT_07_DETECTION_DETAIL_SCREEN.md
├── PROMPT_08_PATIENT_DETAIL_SCREEN.md   # Includes Export
└── ROADMAP_v2.md                        # This file
```

**Cara Pakai:**
1. Buka conversation baru
2. Upload relevant files (providers, models, theme, existing screens)
3. Copy-paste prompt file content
4. Upload mockup sebagai referensi (DESIGN HARUS LEBIH BAGUS)
5. Start development

---

**END OF ROADMAP v2.0**