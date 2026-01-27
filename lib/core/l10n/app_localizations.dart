// lib/core/l10n/app_localizations.dart

import 'package:flutter/material.dart';
import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

/// App Localizations
///
/// Main localization class that provides translated strings
///
/// Usage:
/// ```dart
/// final l10n = AppLocalizations.of(context);
/// Text(l10n.helloWorld);
/// ```
abstract class AppLocalizations {
  // ============================================================================
  // COMMON
  // ============================================================================
  String get appName;
  String get ok;
  String get cancel;
  String get save;
  String get delete;
  String get edit;
  String get back;
  String get next;
  String get submit;
  String get search;
  String get filter;
  String get loading;
  String get retry;
  String get confirm;
  String get yes;
  String get no;
  String get home;
  String get history;
  String get seeAll;
  String get refresh;
  String get share;
  String get proceed;
  String get comingSoon;
  String get all;
  String get minAge;
  String get maxAge;
  String get clear;
  String get ageRangeError;

  // ============================================================================
  // AUTH
  // ============================================================================
  String get login;
  String get signup;
  String get signOut;
  String get email;
  String get password;
  String get forgotPassword;
  String get resetPassword;
  String get fullName;
  String get phoneNumber;
  String get profession;
  String get dateOfBirth;
  String get addPhoto;
  String get changePhoto;
  String get optional;
  String get confirmPassword;
  String get otpVerification;
  String get enterOtp;
  String get resendOtp;
  String get verifyAccount;
  String get welcomeBack;
  String get signInToContinue;
  String get enterEmail;
  String get enterPassword;
  String get noAccount;
  String get alreadyHaveAccount;
  String get otpSentTo;
  String get resendCodeIn;
  String get checkSpam;
  String get verifyProceed;
  String get createYourAccount;
  String get fillFormToRegister;
  String get personalInformation;
  String get security;
  String get addressInformation;
  String get enterFullName;
  String get reenterPassword;
  String get selectDateOfBirth;
  String get selectProfession;
  String get assignmentLocationHint;
  String get detailedAddressHint;
  String get passwordRequirements;
  String get phoneRequirements;
  String get verifyYourEmail;
  String get verifyCreateAccount;
  String get successAccountCreated;
  String get errorPhoneRequired;
  String get errorProfessionRequired;
  String get errorProvinceRequired;
  String get errorCityRequired;
  String get errorDistrictRequired;
  String get errorVillageRequired;
  String get errorAddressRequired;
  String get errorDateRequired;
  String get errorCompleteAddress;

  // ============================================================================
  // PROFILE
  // ============================================================================

  String get profile;
  String get editProfile;
  String get changePassword;
  String get changePasswordMessage;
  String get confirmLogout;
  String get logoutMessage;
  String get account;
  String get data;
  String get settings;
  String get about;
  String get language;
  String get helpSupport;
  String get termsOfService;
  String get privacyPolicy;
  String get appVersion;
  String get chooseFromGallery;
  String get removePhoto;
  String get scans;
  String get today;
  String get updateProfile;
  String get selectLanguage;
  String get titleDr;
  String get titleNurse;
  String get titleMr;
  String get titleMs;

  // ============================================================================
  // EXPORT
  // ============================================================================

  String get exportData;
  String get exportDataSubtitle;
  String get exportDataPatient;
  String get exportSuccess;
  String get exportFailed;
  String get exportComplete;
  String get exportCompleteMessage;
  String get fullReport;
  String get exportFullReportPdf;

  // ============================================================================
  // PATIENT
  // ============================================================================
  String get patients;
  String get addPatient;
  String get editPatient;
  String get deletePatient;
  String get patientCode;
  String get patientName;
  String get gender;
  String get male;
  String get female;
  String get age;
  String get searchPatients;
  String get noPatients;
  String get addFirstPatient;
  String get noSearchResults;
  String get tryDifferentKeywords;
  String get errorPhotoRequired;

  // Add Patient Screen
  String get addNewPatient;
  String get patientCodeHint;
  String get patientNameHint;
  String get selectGender;
  String get selectDate;
  String get savePatient;
  String get patientSaved;
  String get whatNext;
  String get chooseNextAction;
  String get fillPatientInfo;

  // Patient Detail Screen
  String get patientDetails;
  String get overview;
  String get progressChart;
  String get latestClassification;
  String get latestDetection;
  String get patientInformation;
  String get startNewDetection;
  String get noDetectionsYet;
  String get startFirstDetection;
  String get viewDetails;

  // Progress Chart
  String get last7Days;
  String get last30Days;
  String get last90Days;
  String get allTime;
  String get trend;
  String get improving;
  String get stable;
  String get worsening;

  // ⭐ NEW - Chart Filter & Display
  String get filterBy;
  String get lastYear;
  String get thisMonth;
  String get showing;
  String get noDetectionsInPeriod;
  String get tryDifferentPeriod;
  String get showAllData;
  String get trackClassification;

  // export
  String get exportPatientReport;
  String get exportPatientHistory;
  String get exportOptions;
  String get exportingReport;

  // More Menu
  String get moreOptions;
  String get confirmDelete;
  String get deletePatientConfirm;
  String get patientDeleted;

  // Validation - Patient Form
  String get errorPatientCodeRequired;
  String get errorPatientCodeInvalid;
  String get errorNameRequired;
  String get errorGenderRequired;
  String get errorDateOfBirthRequired;

  // ============================================================================
  // DETECTION
  // ============================================================================
  String get detection;
  String get startDetection;
  String get detectionHistory;
  String get pickImage;
  String get cropImage;
  String get analyzeImage;
  String get confidence;
  String get classification;
  String get sideEye;
  String get rightEye;
  String get leftEye;
  String get successImagePicked;
  String get successDetectionSaved;
  String get successDataRefreshed;
  String get errorNoImage;
  String get confirmCancelDetection;
  String get confirmDeleteDetection;
  String get notes;
  String get detectionInformation;
  String get selectPatient;
  String get fundusImage;
  String get uploadFundusImage;
  String get imageCroppedReady;
  String get removeImage;
  String get detectionResult;
  String get enterAdditionalNotes;
  String get confirmCroppedImage;
  String get thisImageWillBeUsed;
  String get done;
  String get allUnsavedDataWillBeLost;
  String get pleaseSelectPatient;
  String get pleaseSelectEyeSide;
  String get pleaseUploadAndCropImage;
  String get imageCropTo299;
  String get detectedAt;

  // ============================================================================
  // PROFESSIONS
  // ============================================================================
  String get profOphthalmologist;
  String get profEndocrinologist;
  String get profGeneralPractitioner;
  String get profOptometrist;
  String get profNurse;
  String get profMedicalStudent;
  String get profHealthcareAssistant;
  String get profOther;

  // ============================================================================
  // LOCATION
  // ============================================================================
  String get address;
  String get province;
  String get city;
  String get district;
  String get village;
  String get assignmentLocation;
  String get detailedAddress;
  String get selectProvince;
  String get selectCity;
  String get selectDistrict;
  String get selectVillage;

  // ============================================================================
  // MESSAGES
  // ============================================================================
  String get successSave;
  String get successUpdate;
  String get successDelete;
  String get successSignup;
  String get successSignin;
  String get successLogout;
  String get successOtpSent;
  String get successPasswordReset;
  String get successProfileUpdated;
  String get successPhotoDeleted;
  String get errorOccurred;
  String get networkError;
  String get noDataFound;

  // ============================================================================
  // VALIDATION
  // ============================================================================
  String get fieldRequired;
  String get passwordsNotMatch;
  String get errorUnknown;
  String get errorConnectionTimeout;
  String get errorSendTimeout;
  String get errorReceiveTimeout;
  String get errorRequestCancelled;
  String get errorNoInternet;
  String get errorSecurityCertificate;
  String get errorPermissionDenied;

  // Specific Errors
  String get errorPatientNotFound;
  String get errorPatientAlreadyExists;
  String get errorSessionNotFound;
  String get errorSessionExpired;
  String get errorImageTooLarge;
  String get errorImageInvalidFormat;
  String get errorBadRequest;
  String get errorInvalidCredentials;
  String get errorInvalidOtp;
  String get errorTokenExpired;
  String get errorNotAuthenticated;
  String get errorUnauthorized;
  String get errorNoPermission;
  String get errorForbidden;
  String get errorUserNotFound;
  String get errorDetectionNotFound;
  String get errorNotFound;
  String get errorEmailAlreadyExists;
  String get errorConflict;
  String get errorEmailInvalid;
  String get errorPasswordTooShort;
  String get errorPasswordWeak;
  String get errorPhoneInvalid;
  String get errorOtpInvalid;
  String get errorDateInvalid;
  String get errorValidation;
  String get errorTooManyRequests;
  String get errorTokenRevoked;
  String get errorNoProfilePhoto;
  String get errorEmailNotFound;

  // Server Errors
  String get errorServerInternal;
  String get errorServerBadGateway;
  String get errorServerUnavailable;
  String get errorServerTimeout;

  // ============================================================================
  // DASHBOARD (NEW)
  // ============================================================================
  String get dashboardTitle; // "Statistik Hari Ini"
  String get drDistribution; // "Sebaran Klasifikasi DR"
  String get greetingMorning; // "Selamat Pagi"
  String get greetingAfternoon; // "Selamat Siang"
  String get greetingEvening; // "Selamat Sore"
  String get greetingNight; // "Selamat Malam"
  String get totalPatients; // "Total Pasien"
  String get totalDetections; // "Total Deteksi"
  String get detectionsToday; // "Deteksi Hari Ini"
  String get recentPatients;
  String get recentDetections;

  // Empty/Error States di Dashboard
  String get loadingData; // "Memuat data..."
  String get failedToLoad; // "Gagal Memuat Data"
  String get noDataTitle; // "Belum Ada Data"
  String get noDataDesc; // "Mulai tambahkan pasien..."
  String get offlineBanner; // "Data mungkin tidak terbaru..."
  String get recentActivity; // NEW
  String get total; // NEW

  // ============================================================================
  // CLIENT-SIDE ERRORS (Image Handling)
  // ============================================================================
  String get errorFilePickerCancelled;
  String get errorFilePickerFailed;
  String get errorImageCropCancelled;
  String get errorImageCropFailed;
  String get errorImageConversionFailed;
  String get errorNoImageSelected;

  // ============================================================================
  // STATIC HELPER
  // ============================================================================

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('en'), // English
    Locale('id'), // Indonesian
  ];
}

/// Localizations Delegate
class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'id'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    switch (locale.languageCode) {
      case 'id':
        return AppLocalizationsId();
      case 'en':
      default:
        return AppLocalizationsEn();
    }
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
