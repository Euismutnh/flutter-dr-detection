// lib/core/l10n/app_localizations_en.dart

import 'app_localizations.dart';

class AppLocalizationsEn extends AppLocalizations {
  // ============================================================================
  // COMMON
  // ============================================================================
  @override
  String get appName => 'DR Detection';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get back => 'Back';

  @override
  String get next => 'Next';

  @override
  String get submit => 'Submit';

  @override
  String get search => 'Search';

  @override
  String get filter => 'Filter';

  @override
  String get loading => 'Loading...';

  @override
  String get retry => 'Retry';

  @override
  String get confirm => 'Confirm';

  @override
  String get yes => 'Yes';
  @override
  String get no => 'No';
  @override
  String get home => 'Home';
  @override
  String get history => 'History';
  @override
  String get seeAll => 'See All';
  @override
  String get refresh => 'Refresh';
  @override
  String get share => 'Share';
  @override
  String get proceed => 'Proceed';
  @override
  String get comingSoon => 'Coming Soon';
  @override
  String get all => 'All';

  // ============================================================================
  // AUTH
  // ============================================================================
  @override
  String get login => 'Login';

  @override
  String get signup => 'Sign Up';

  @override
  String get signOut => 'Logout';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get resetPassword => 'Reset Password';

  @override
  String get fullName => 'Full Name';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get profession => 'Profession';

  @override
  String get dateOfBirth => 'Date of Birth';
  @override
  String get addPhoto => 'Add Photo';
  @override
  String get changePhoto => 'Change Photo';
  @override
  String get optional => 'Optional';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get otpVerification => 'OTP Verification';

  @override
  String get enterOtp => 'Enter OTP';

  @override
  String get resendOtp => 'Resend OTP';

  @override
  String get verifyAccount => 'Verify Account';

  @override
  String get welcomeBack => 'Welcome Back';

  @override
  String get signInToContinue => 'Sign in to continue';

  @override
  String get enterEmail => 'Enter your email';

  @override
  String get enterPassword => 'Enter your password';

  @override
  String get noAccount => 'Don\'t have an account?';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get otpSentTo => 'We\'ve sent a verification code to';

  @override
  String get resendCodeIn => 'Resend code in';

  @override
  String get checkSpam => 'Check your spam folder if you don\'t see the code.';

  @override
  String get verifyProceed => 'Verify & Proceed';
  @override
  String get createYourAccount => 'Create Your Account';
  @override
  String get fillFormToRegister => 'Fill in the form below to register';
  @override
  String get personalInformation => 'Personal Information';
  @override
  String get security => 'Security';
  @override
  String get addressInformation => 'Address Information';
  @override
  String get enterFullName => 'Enter your full name';
  @override
  String get reenterPassword => 'Re-enter your password';
  @override
  String get selectDateOfBirth => 'Select date of birth';
  @override
  String get selectProfession => 'Select your profession';
  @override
  String get assignmentLocationHint => 'e.g., RSUD Abdul Moeloek';
  @override
  String get detailedAddressHint => 'Street name, building number, RT/RW, etc.';
  @override
  String get passwordRequirements => 'Min 8 characters, 1 letter, 1 number';
  @override
  String get phoneRequirements => 'Indonesian format: 08xxxxxxxxxx';
  @override
  String get verifyYourEmail => 'Verify Your Email';
  @override
  String get verifyCreateAccount => 'Verify & Create Account';
  @override
  String get successAccountCreated => 'Account created successfully!';
  @override
  String get errorPhoneRequired => 'Phone number is required';
  @override
  String get errorProfessionRequired => 'Please select a profession';
  @override
  String get errorProvinceRequired => 'Please select a province';
  @override
  String get errorCityRequired => 'Please select a city/regency';
  @override
  String get errorDistrictRequired => 'Please select a district';
  @override
  String get errorVillageRequired => 'Please select a village';
  @override
  String get errorAddressRequired => 'Detailed address is required';
  @override
  String get errorDateRequired => 'Date of birth is required';
  @override
  String get errorCompleteAddress => 'Please complete all address fields';

  // ============================================================================
  // PROFILE (NEW)
  // ============================================================================
  @override
  String get profile => 'Profile';
  @override
  String get editProfile => 'Edit Profile';
  @override
  String get changePassword => 'Change Password';
  @override
  String get changePasswordMessage =>
      'You will be redirected to reset your password via email verification.';
  @override
  String get confirmLogout => 'Confirm Sign Out';
  @override
  String get logoutMessage =>
      'Are you sure you want to sign out? You will need to sign in again to access your account.';
  @override
  String get account => 'Account';
  @override
  String get data => 'Data';
  @override
  String get settings => 'Settings';
  @override
  String get about => 'About';
  @override
  String get language => 'Language';
  @override
  String get helpSupport => 'Help & Support';
  @override
  String get termsOfService => 'Terms of Service';
  @override
  String get privacyPolicy => 'Privacy Policy';
  @override
  String get appVersion => 'App Version';
  @override
  String get chooseFromGallery => 'Choose from Gallery';
  @override
  String get removePhoto => 'Remove Photo';
  @override
  String get scans => 'Scans';
  @override
  String get today => 'Today';
  @override
  String get updateProfile => 'Update Profile';
  @override
  String get selectLanguage => 'Select Language';
  @override
  String get titleDr => 'Dr.';
  @override
  String get titleNurse => 'Nurse';
  @override
  String get titleMr => 'Mr.';
  @override
  String get titleMs => 'Ms.';

  // ============================================================================
  // EXPORT (NEW)
  // ============================================================================
  @override
  String get exportData => 'Export Data';
  @override
  String get exportDataSubtitle => 'Export patients & detections data';
  @override
  String get exportDataPatient => 'Export Patient Data';
  @override
  String get exportSuccess => 'Export successful!';
  @override
  String get exportFailed => 'Export failed. Please try again.';
  @override
  String get exportComplete => 'Export Complete';
  @override
  String get exportCompleteMessage =>
      'Your file has been generated successfully.';
  @override
  String get fullReport => 'Full Report';
  @override
  String get exportFullReportPdf => 'Export Full Report (PDF)';

  // ============================================================================
  // PATIENT
  // ============================================================================
  @override
  String get patients => 'Patients';

  @override
  String get addPatient => 'Add Patient';

  @override
  String get editPatient => 'Edit Patient';

  @override
  String get deletePatient => 'Delete Patient';

  @override
  String get patientCode => 'Patient Code';

  @override
  String get patientName => 'Patient Name';

  @override
  String get gender => 'Gender';

  @override
  String get male => 'Male';

  @override
  String get female => 'Female';

  @override
  String get age => 'Age';

  @override
  String get searchPatients => 'Search patients...';

  @override
  String get noPatients => 'No Patients Yet';

  @override
  String get addFirstPatient => 'Add your first patient to get started';

  @override
  String get noSearchResults => 'No Results Found';

  @override
  String get tryDifferentKeywords => 'Try different keywords or clear filters';

  @override
  String get errorPhotoRequired => 'Profile photo is required';
  @override
  String get minAge => 'Min Age';
  @override
  String get maxAge => 'Max Age';
  @override
  String get clear => 'Clear';
  @override
  String get ageRangeError => 'Min age cannot be greater than max age';

  // Add Patient Screen
  @override
  String get addNewPatient => 'Add New Patient';

  @override
  String get patientCodeHint => 'e.g., P001234';

  @override
  String get patientNameHint => 'Enter patient\'s full name';

  @override
  String get selectGender => 'Select Gender';

  @override
  String get selectDate => 'Select Date';

  @override
  String get savePatient => 'Save Patient';

  @override
  String get patientSaved => 'Patient saved successfully!';

  @override
  String get whatNext => 'What\'s Next?';

  @override
  String get chooseNextAction => 'Choose what to do with this patient';

  @override
  String get fillPatientInfo =>
      'Fill in patient information to create a new record';

  // Patient Detail Screen
  @override
  String get patientDetails => 'Patient Details';

  @override
  String get overview => 'Overview';

  @override
  String get progressChart => 'Progress Chart';

  @override
  String get latestClassification => 'Latest Classification';

  @override
  String get latestDetection => 'Latest Detection';

  @override
  String get patientInformation => 'Patient Information';

  @override
  String get startNewDetection => 'Start New Detection';

  @override
  String get noDetectionsYet => 'No detections yet';

  @override
  String get startFirstDetection => 'Start your first detection';

  @override
  String get viewDetails => 'View Details';

  // Progress Chart
  @override
  String get last7Days => 'Last 7 Days';

  @override
  String get last30Days => 'Last 30 Days';

  @override
  String get last90Days => 'Last 90 Days';

  @override
  String get allTime => 'All Time';

  @override
  String get trend => 'Trend';

  @override
  String get improving => 'Improving';

  @override
  String get stable => 'Stable';

  @override
  String get worsening => 'Worsening';

  // ⭐ NEW - Chart Filter & Display
  @override
  String get filterBy => 'Filter by';

  @override
  String get lastYear => 'Last Year';

  @override
  String get thisMonth => 'This Month';

  @override
  String get showing => 'Showing';

  @override
  String get noDetectionsInPeriod => 'No detections in selected period';

  @override
  String get tryDifferentPeriod => 'Try selecting a different time period';

  @override
  String get showAllData => 'Show All Data';

  @override
  String get trackClassification => 'Track DR classification over time';

  // Export
  @override
  String get exportPatientReport => 'Export Patient Report (PDF)';

  @override
  String get exportPatientHistory => 'Export Patient History (Excel)';

  @override
  String get exportOptions => 'Export Options';

  @override
  String get exportingReport => 'Exporting report...';

  // More Menu
  @override
  String get moreOptions => 'More Options';

  @override
  String get confirmDelete => 'Confirm Delete';

  @override
  String get deletePatientConfirm =>
      'Are you sure you want to delete this patient? All detection records will be permanently deleted.';

  @override
  String get patientDeleted => 'Patient deleted successfully';

  // Validation - Patient Form
  @override
  String get errorPatientCodeRequired => 'Patient code is required';

  @override
  String get errorPatientCodeInvalid =>
      'Invalid patient code format (3-50 alphanumeric characters)';

  @override
  String get errorNameRequired => 'Patient name is required';

  @override
  String get errorGenderRequired => 'Please select a gender';

  @override
  String get errorDateOfBirthRequired => 'Date of birth is required';

  // ============================================================================
  // DETECTION
  // ============================================================================
  @override
  String get detection => 'Detection';

  @override
  String get startDetection => 'Start Detection';

  @override
  String get detectionHistory => 'Detection History';

  @override
  String get pickImage => 'Pick Image';

  @override
  String get cropImage => 'Crop Image';

  @override
  String get analyzeImage => 'Analyze Image';

  @override
  String get confidence => 'Confidence';

  @override
  String get classification => 'Classification';

  @override
  String get sideEye => 'Eye Side';

  @override
  String get rightEye => 'Right Eye';

  @override
  String get leftEye => 'Left Eye';
  @override
  String get successImagePicked => 'Image selected successfully!';
  @override
  String get successDetectionSaved => 'Detection saved successfully!';
  @override
  String get successDataRefreshed => 'Data refreshed successfully!';

  @override
  String get errorNoImage => 'Please select an image first';

  @override
  String get confirmCancelDetection =>
      'Are you sure you want to cancel this detection?';
  @override
  String get confirmDeleteDetection =>
      'Are you sure you want to delete this detection? This action cannot be undone.';
  @override
  String get notes => 'Notes';

  @override
  String get detectionInformation => 'Detection Information';

  @override
  String get selectPatient => 'Select Patient';

  @override
  String get fundusImage => 'Fundus Image';

  @override
  String get uploadFundusImage => 'Upload Fundus Image';

  @override
  String get imageCroppedReady => 'Image ready';

  @override
  String get removeImage => 'Remove Image';

  @override
  String get detectionResult => 'Detection Result';

  @override
  String get enterAdditionalNotes => 'Enter additional notes (optional)';

  @override
  String get confirmCroppedImage => 'Confirm Cropped Image';

  @override
  String get thisImageWillBeUsed => 'This image will be used for detection';

  @override
  String get done => 'Done';

  @override
  String get allUnsavedDataWillBeLost =>
      'All unsaved data will be lost. Continue?';

  @override
  String get pleaseSelectPatient => 'Please select a patient';

  @override
  String get pleaseSelectEyeSide => 'Please select eye side';

  @override
  String get pleaseUploadAndCropImage => 'Please upload and crop an image';

  @override
  String get imageCropTo299 => 'Image will be cropped to 299x299 pixels';

  @override
  String get detectedAt => 'Detected At';

  // ============================================================================
  // PROFESSIONS
  // ============================================================================

  @override
  String get profOphthalmologist => 'Ophthalmologist';
  @override
  String get profEndocrinologist => 'Endocrinologist';
  @override
  String get profGeneralPractitioner => 'General Practitioner';
  @override
  String get profOptometrist => 'Optometrist';
  @override
  String get profNurse => 'Nurse';
  @override
  String get profMedicalStudent => 'Medical Student';
  @override
  String get profHealthcareAssistant => 'Healthcare Assistant';
  @override
  String get profOther => 'Other';

  // ============================================================================
  // LOCATION
  // ============================================================================
  @override
  String get address => 'Address';

  @override
  String get province => 'Province';

  @override
  String get city => 'City';

  @override
  String get district => 'District';

  @override
  String get village => 'Village';
  @override
  String get assignmentLocation => 'Assignment Location';
  @override
  String get detailedAddress => 'Detailed Address';

  @override
  String get selectProvince => 'Select Province';

  @override
  String get selectCity => 'Select City';

  @override
  String get selectDistrict => 'Select District';

  @override
  String get selectVillage => 'Select Village';

  // ============================================================================
  // MESSAGES
  // ============================================================================
  @override
  String get successSave => 'Saved successfully!';
  @override
  String get successUpdate => 'Updated successfully!';
  @override
  String get successDelete => 'Deleted successfully!';
  @override
  String get successSignup =>
      'Registration successful! Check your email for OTP.';
  @override
  String get successSignin => 'Login successful!';
  @override
  String get successLogout => 'Logged out successfully.';
  @override
  String get successOtpSent => 'OTP sent to your email.';
  @override
  String get successPasswordReset => 'Password reset successful. Please login.';
  @override
  String get successProfileUpdated => 'Profile updated successfully!';
  @override
  String get successPhotoDeleted => 'Profile deleted successfully!';
  @override
  String get errorOccurred => 'An error occurred';
  @override
  String get networkError => 'Network error. Please check your connection.';
  @override
  String get noDataFound => 'No data found';

  // ============================================================================
  // VALIDATION
  // ============================================================================
  @override
  String get fieldRequired => 'This field is required';

  @override
  String get passwordsNotMatch => 'Passwords do not match';

  @override
  String get errorUnknown => 'An unexpected error occurred.';
  @override
  String get errorConnectionTimeout =>
      'Connection timeout. Please check your network.';
  @override
  String get errorSendTimeout => 'Send timeout. Please try again.';
  @override
  String get errorReceiveTimeout => 'Server took too long to respond.';
  @override
  String get errorRequestCancelled => 'Request was cancelled.';
  @override
  String get errorNoInternet => 'No internet connection.';
  @override
  String get errorSecurityCertificate => 'Security certificate error.';
  @override
  String get errorPermissionDenied =>
      'Storage permission denied. Please enable in app settings.';

  @override
  String get errorPatientNotFound => 'Patient not found.';
  @override
  String get errorPatientAlreadyExists => 'Patient code already exists.';
  @override
  String get errorSessionNotFound => 'Detection session not found.';
  @override
  String get errorSessionExpired =>
      'Session expired (15 mins limit). Please start again.';
  @override
  String get errorImageTooLarge => 'Image size exceeds 5MB limit';
  @override
  String get errorImageInvalidFormat => 'Invalid image format.';
  @override
  String get errorBadRequest => 'Invalid request.';
  @override
  String get errorTokenRevoked => 'Session revoked. Please login again.';
  @override
  String get errorNoProfilePhoto => 'No profile photo to delete.';
  @override
  String get errorInvalidCredentials => 'Incorrect email or password.';
  @override
  String get errorInvalidOtp => 'Invalid OTP code.';
  @override
  String get errorTokenExpired => 'Session expired. Please login again.';
  @override
  String get errorNotAuthenticated => 'You are not logged in.';
  @override
  String get errorUnauthorized => 'Unauthorized access.';
  @override
  String get errorNoPermission => 'You don\'t have permission.';
  @override
  String get errorForbidden => 'Access forbidden.';
  @override
  String get errorUserNotFound => 'User not found.';
  @override
  String get errorDetectionNotFound => 'Detection result not found.';
  @override
  String get errorNotFound => 'Resource not found.';
  @override
  String get errorEmailAlreadyExists => 'Email is already registered.';
  @override
  String get errorConflict => 'Data conflict occurred.';
  @override
  String get errorEmailInvalid => 'Invalid email format.';
  @override
  String get errorPasswordTooShort => 'Password is too short.';
  @override
  String get errorPasswordWeak => 'Password is too weak.';
  @override
  String get errorPhoneInvalid => 'Invalid phone number.';
  @override
  String get errorOtpInvalid => 'OTP must be digits only.';
  @override
  String get errorDateInvalid => 'Invalid date format.';
  @override
  String get errorValidation => 'Please check your input.';
  @override
  String get errorTooManyRequests => 'Too many requests. Please wait.';

  @override
  String get errorServerInternal => 'Internal server error.';
  @override
  String get errorServerBadGateway => 'Server is temporarily unavailable.';
  @override
  String get errorServerUnavailable => 'Service unavailable.';
  @override
  String get errorServerTimeout => 'Server connection timeout.';
  @override
  String get errorEmailNotFound =>
      'Email not registered. Please sign up first.';

  // ============================================================================
  // DASHBOARD
  // ============================================================================
  @override
  String get dashboardTitle => 'Today\'s Statistics';
  @override
  String get drDistribution => 'DR Classification Distribution';
  @override
  String get greetingMorning => 'Good Morning';
  @override
  String get greetingAfternoon => 'Good Afternoon';
  @override
  String get greetingEvening => 'Good Evening';
  @override
  String get greetingNight => 'Good Night';
  @override
  String get totalPatients => 'Total Patients';
  @override
  String get totalDetections => 'Total Detections';
  @override
  String get detectionsToday => 'Detections Today';
  @override
  String get recentPatients => 'Recent Patients';
  @override
  String get recentDetections => 'Recent Detections';

  @override
  String get loadingData => 'Loading data...';
  @override
  String get failedToLoad => 'Failed to Load Data';
  @override
  String get noDataTitle => 'No Data Yet';
  @override
  String get noDataDesc => 'Start adding patients and perform detection';
  @override
  String get offlineBanner => 'Data might be stale â€¢ Last updated:';
  @override
  String get recentActivity => 'Recent Activity';
  @override
  String get total => 'Total';

  // ============================================================================
  // CLIENT-SIDE ERRORS (Image Handling)
  // ============================================================================
  @override
  String get errorFilePickerCancelled => 'No file selected';

  @override
  String get errorFilePickerFailed => 'Failed to select file';

  @override
  String get errorImageCropCancelled => 'Image cropping cancelled';

  @override
  String get errorImageCropFailed => 'Failed to crop image';

  @override
  String get errorImageConversionFailed => 'Failed to convert image format';

  @override
  String get errorNoImageSelected => 'Please select an image first';
}
