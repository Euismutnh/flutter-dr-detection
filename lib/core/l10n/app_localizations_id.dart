// lib/core/l10n/app_localizations_id.dart

import 'app_localizations.dart';

class AppLocalizationsId extends AppLocalizations {
  // ============================================================================
  // COMMON
  // ============================================================================
  @override
  String get appName => 'Deteksi DR';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Batal';

  @override
  String get save => 'Simpan';

  @override
  String get delete => 'Hapus';

  @override
  String get edit => 'Ubah';

  @override
  String get back => 'Kembali';

  @override
  String get next => 'Selanjutnya';

  @override
  String get submit => 'Kirim';

  @override
  String get search => 'Cari';

  @override
  String get filter => 'Filter';

  @override
  String get loading => 'Memuat...';

  @override
  String get retry => 'Coba Lagi';

  @override
  String get confirm => 'Konfirmasi';

  @override
  String get yes => 'Ya';

  @override
  String get no => 'Tidak';

  @override
  String get home => 'Beranda';

  @override
  String get history => 'Riwayat';

  @override
  String get seeAll => 'Lihat Semua';
  @override
  String get refresh => 'Segarkan';
  @override
  String get share => 'Bagikan';
  @override
  String get proceed => 'Lanjutkan';
  @override
  String get comingSoon => 'Segera Hadir';
  @override
  String get all => 'Semua';

  @override
  String get minAge => 'Usia Min';

  @override
  String get maxAge => 'Usia Maks';

  @override
  String get clear => 'Hapus';

  @override
  String get ageRangeError => 'Usia min tidak boleh lebih dari usia maks';
  @override
  String get reset => 'Atur Ulang';
  @override
  String get apply => 'Terapkan';
  @override
  String get period => 'Periode';
  @override
  String get noResultsFound => 'Tidak ada hasil ditemukan';

  // ============================================================================
  // AUTH
  // ============================================================================
  @override
  String get login => 'Masuk';

  @override
  String get signup => 'Daftar';

  @override
  String get signOut => 'Keluar';

  @override
  String get email => 'Email';

  @override
  String get password => 'Kata Sandi';

  @override
  String get forgotPassword => 'Lupa Kata Sandi?';

  @override
  String get resetPassword => 'Atur Ulang Kata Sandi';

  @override
  String get fullName => 'Nama Lengkap';

  @override
  String get phoneNumber => 'Nomor Telepon';

  @override
  String get profession => 'Profesi';

  @override
  String get dateOfBirth => 'Tanggal Lahir';
  @override
  String get addPhoto => 'Tambah Foto';
  @override
  String get changePhoto => 'Ganti Foto';
  @override
  String get optional => 'Opsional';

  @override
  String get confirmPassword => 'Konfirmasi Kata Sandi';

  @override
  String get otpVerification => 'Verifikasi OTP';

  @override
  String get enterOtp => 'Masukkan OTP';

  @override
  String get resendOtp => 'Kirim Ulang OTP';

  @override
  String get verifyAccount => 'Verifikasi Akun';

  @override
  String get welcomeBack => 'Selamat Datang Kembali';

  @override
  String get signInToContinue => 'Masuk untuk melanjutkan';

  @override
  String get enterEmail => 'Masukkan email Anda';

  @override
  String get enterPassword => 'Masukkan kata sandi Anda';

  @override
  String get noAccount => 'Belum punya akun?';
  @override
  String get alreadyHaveAccount => 'Sudah punya akun?';
  @override
  String get otpSentTo => 'Kami telah mengirim kode verifikasi ke';

  @override
  String get resendCodeIn => 'Kirim ulang dalam';

  @override
  String get checkSpam => 'Cek folder spam jika kode tidak muncul.';

  @override
  String get verifyProceed => 'Verifikasi & Lanjut';
  @override
  String get createYourAccount => 'Buat Akun Anda';
  @override
  String get fillFormToRegister => 'Isi formulir di bawah untuk mendaftar';
  @override
  String get personalInformation => 'Informasi Pribadi';
  @override
  String get security => 'Keamanan';
  @override
  String get addressInformation => 'Informasi Alamat';
  @override
  String get enterFullName => 'Masukkan nama lengkap';
  @override
  String get reenterPassword => 'Masukkan ulang kata sandi';
  @override
  String get selectDateOfBirth => 'Pilih tanggal lahir';
  @override
  String get selectProfession => 'Pilih profesi Anda';
  @override
  String get assignmentLocationHint => 'contoh, RSUD Abdul Moeloek';
  @override
  String get detailedAddressHint => 'Nama jalan, nomor gedung, RT/RW, dll.';
  @override
  String get passwordRequirements => 'Min 8 karakter, 1 huruf, 1 angka';
  @override
  String get phoneRequirements => 'Format Indonesia: 08xxxxxxxxxx';
  @override
  String get verifyYourEmail => 'Verifikasi Email Anda';
  @override
  String get verifyCreateAccount => 'Verifikasi & Buat Akun';
  @override
  String get successAccountCreated => 'Akun berhasil dibuat!';
  @override
  String get errorPhoneRequired => 'Nomor telepon wajib diisi';
  @override
  String get errorProfessionRequired => 'Silakan pilih profesi';
  @override
  String get errorProvinceRequired => 'Silakan pilih provinsi';
  @override
  String get errorCityRequired => 'Silakan pilih kota/kabupaten';
  @override
  String get errorDistrictRequired => 'Silakan pilih kecamatan';
  @override
  String get errorVillageRequired => 'Silakan pilih desa/kelurahan';
  @override
  String get errorAddressRequired => 'Alamat lengkap wajib diisi';
  @override
  String get errorDateRequired => 'Tanggal lahir wajib diisi';
  @override
  String get errorCompleteAddress => 'Silakan lengkapi semua field alamat';

  // ============================================================================
  // PROFILE (NEW)
  // ============================================================================
  @override
  String get profile => 'Profil';
  @override
  String get editProfile => 'Ubah Profil';
  @override
  String get changePassword => 'Ubah Kata Sandi';
  @override
  String get changePasswordMessage =>
      'Anda akan diarahkan untuk mereset kata sandi melalui verifikasi email.';
  @override
  String get confirmLogout => 'Konfirmasi Keluar';
  @override
  String get logoutMessage =>
      'Apakah Anda yakin ingin keluar? Anda perlu masuk lagi untuk mengakses akun Anda.';
  @override
  String get account => 'Akun';
  @override
  String get data => 'Data';
  @override
  String get settings => 'Pengaturan';
  @override
  String get about => 'Tentang';
  @override
  String get language => 'Bahasa';
  @override
  String get helpSupport => 'Bantuan & Dukungan';
  @override
  String get termsOfService => 'Syarat Layanan';
  @override
  String get privacyPolicy => 'Kebijakan Privasi';
  @override
  String get appVersion => 'Versi Aplikasi';
  @override
  String get chooseFromGallery => 'Pilih dari Galeri';
  @override
  String get removePhoto => 'Hapus Foto';
  @override
  String get scans => 'Scan';
  @override
  String get today => 'Hari Ini';
  @override
  String get updateProfile => 'Perbarui Profil';
  @override
  String get selectLanguage => 'Pilih Bahasa';
  @override
  String get titleDr => 'dr.';
  @override
  String get titleNurse => 'Ners';
  @override
  String get titleMr => 'Tn.';
  @override
  String get titleMs => 'Ny.';

  // ============================================================================
  // EXPORT (NEW)
  // ============================================================================
  @override
  String get exportData => 'Ekspor Data';
  @override
  String get exportDataSubtitle => 'Ekspor data pasien & deteksi';
  @override
  String get exportDataPatient => 'Ekspor Data Pasien';
  @override
  String get exportSuccess => 'Ekspor berhasil!';
  @override
  String get exportFailed => 'Ekspor gagal. Silakan coba lagi.';
  @override
  String get exportComplete => 'Ekspor Selesai';
  @override
  String get exportCompleteMessage => 'File Anda telah berhasil dibuat.';
  @override
  String get fullReport => 'Laporan Lengkap';
  @override
  String get exportFullReportPdf => 'Ekspor Laporan Lengkap (PDF)';

  // ============================================================================
  // PATIENT
  // ============================================================================
  @override
  String get patients => 'Pasien';

  @override
  String get addPatient => 'Tambah Pasien';

  @override
  String get editPatient => 'Ubah Pasien';

  @override
  String get deletePatient => 'Hapus Pasien';

  @override
  String get patientCode => 'Kode Pasien';

  @override
  String get patientName => 'Nama Pasien';

  @override
  String get gender => 'Jenis Kelamin';

  @override
  String get male => 'Laki-laki';

  @override
  String get female => 'Perempuan';

  @override
  String get age => 'Umur';

  @override
  String get searchPatients => 'Cari pasien...';

  @override
  String get noPatients => 'Belum Ada Pasien';

  @override
  String get addFirstPatient => 'Tambahkan pasien pertama untuk memulai';

  @override
  String get noSearchResults => 'Hasil Tidak Ditemukan';

  @override
  String get tryDifferentKeywords => 'Coba kata kunci lain atau hapus filter';

  @override
  String get errorPhotoRequired => 'Foto profil wajib diisi';

  // Add Patient Screen
  @override
  String get addNewPatient => 'Tambah Pasien Baru';

  @override
  String get patientCodeHint => 'contoh: P001234';

  @override
  String get patientNameHint => 'Masukkan nama lengkap pasien';

  @override
  String get selectGender => 'Pilih Jenis Kelamin';

  @override
  String get selectDate => 'Pilih Tanggal';

  @override
  String get savePatient => 'Simpan Pasien';

  @override
  String get patientSaved => 'Pasien berhasil disimpan!';

  @override
  String get whatNext => 'Selanjutnya?';

  @override
  String get chooseNextAction => 'Pilih tindakan untuk pasien ini';

  @override
  String get fillPatientInfo => 'Isi informasi pasien untuk membuat data baru';

  // Patient Detail Screen
  @override
  String get patientDetails => 'Detail Pasien';

  @override
  String get overview => 'Ringkasan';

  @override
  String get progressChart => 'Grafik Perkembangan';

  @override
  String get latestClassification => 'Klasifikasi Terbaru';

  @override
  String get latestDetection => 'Deteksi Terbaru';

  @override
  String get patientInformation => 'Informasi Pasien';

  @override
  String get startNewDetection => 'Mulai Deteksi Baru';

  @override
  String get noDetectionsYet => 'Belum ada deteksi';

  @override
  String get startFirstDetection => 'Mulai deteksi pertama Anda';

  @override
  String get viewDetails => 'Lihat Detail';

  // Progress Chart
  @override
  String get last7Days => '7 Hari Terakhir';

  @override
  String get last30Days => '30 Hari Terakhir';

  @override
  String get last90Days => '90 Hari Terakhir';

  @override
  String get allTime => 'Semua Waktu';

  @override
  String get trend => 'Tren';

  @override
  String get improving => 'Membaik';

  @override
  String get stable => 'Stabil';

  @override
  String get worsening => 'Memburuk';

  @override
  String get filterBy => 'Filter berdasarkan';

  @override
  String get lastYear => 'Tahun Lalu';

  @override
  String get thisMonth => 'Bulan Ini';

  @override
  String get showing => 'Menampilkan';

  @override
  String get noDetectionsInPeriod =>
      'Tidak ada deteksi dalam periode yang dipilih';

  @override
  String get tryDifferentPeriod => 'Coba pilih periode waktu yang berbeda';

  @override
  String get showAllData => 'Tampilkan Semua Data';

  @override
  String get trackClassification => 'Lacak klasifikasi DR dari waktu ke waktu';

  // Export
  @override
  String get exportPatientReport => 'Ekspor Laporan Pasien (PDF)';

  @override
  String get exportPatientHistory => 'Ekspor Riwayat Pasien (Excel)';

  @override
  String get exportOptions => 'Opsi Ekspor';

  @override
  String get exportingReport => 'Mengekspor laporan...';

  // More Menu
  @override
  String get moreOptions => 'Opsi Lainnya';

  @override
  String get confirmDelete => 'Konfirmasi Hapus';

  @override
  String get deletePatientConfirm =>
      'Apakah Anda yakin ingin menghapus pasien ini? Semua rekaman deteksi akan dihapus permanen.';

  @override
  String get patientDeleted => 'Pasien berhasil dihapus';

  @override
  String get errorPatientCodeRequired => 'Kode pasien wajib diisi';

  @override
  String get errorPatientCodeInvalid =>
      'Format kode pasien tidak valid (3-50 karakter alfanumerik)';

  @override
  String get errorNameRequired => 'Nama pasien wajib diisi';

  @override
  String get errorGenderRequired => 'Silakan pilih jenis kelamin';

  @override
  String get errorDateOfBirthRequired => 'Tanggal lahir wajib diisi';

  // ============================================================================
  // DETECTION
  // ============================================================================
  @override
  String get detection => 'Deteksi';

  @override
  String get startDetection => 'Mulai Deteksi';

  @override
  String get detectionHistory => 'Riwayat Deteksi';

  @override
  String get pickImage => 'Pilih Gambar';

  @override
  String get cropImage => 'Potong Gambar';

  @override
  String get analyzeImage => 'Analisis Gambar';

  @override
  String get confidence => 'Tingkat Keyakinan';

  @override
  String get classification => 'Klasifikasi';

  @override
  String get sideEye => 'Sisi Mata';

  @override
  String get rightEye => 'Mata Kanan';

  @override
  String get leftEye => 'Mata Kiri';

  @override
  String get successImagePicked => 'Gambar berhasil dipilih!';
  @override
  String get successDetectionSaved => 'Deteksi berhasil disimpan!';
  @override
  String get successDataRefreshed => 'Data berhasil diperbarui!';

  @override
  String get errorNoImage => 'Silakan pilih gambar terlebih dahulu';

  @override
  String get confirmCancelDetection =>
      'Apakah Anda yakin ingin membatalkan deteksi ini?';
  @override
  String get confirmDeleteDetection =>
      'Apakah Anda yakin ingin menghapus deteksi ini? Tindakan ini tidak dapat dibatalkan.';
  @override
  String get notes => 'Catatan';

  @override
  String get detectionInformation => 'Informasi Deteksi';

  @override
  String get selectPatient => 'Pilih Pasien';

  @override
  String get fundusImage => 'Gambar Fundus';

  @override
  String get uploadFundusImage => 'Unggah Gambar Fundus';

  @override
  String get imageCroppedReady => 'Gambar sudah dipotong dan siap';

  @override
  String get removeImage => 'Hapus Gambar';

  @override
  String get detectionResult => 'Hasil Deteksi';

  @override
  String get enterAdditionalNotes => 'Masukkan catatan tambahan (opsional)';

  @override
  String get confirmCroppedImage => 'Konfirmasi Gambar yang Dipotong';

  @override
  String get thisImageWillBeUsed => 'Gambar ini akan digunakan untuk deteksi';

  @override
  String get done => 'Selesai';

  @override
  String get allUnsavedDataWillBeLost =>
      'Semua data yang belum disimpan akan hilang. Lanjutkan?';

  @override
  String get pleaseSelectPatient => 'Silakan pilih pasien';

  @override
  String get pleaseSelectEyeSide => 'Silakan pilih sisi mata';

  @override
  String get pleaseUploadAndCropImage => 'Silakan unggah dan potong gambar';

  @override
  String get imageCropTo299 => 'Gambar akan dipotong menjadi 299x299 piksel';

  @override
  String get detectedAt => 'Terdeteksi Pada';
  @override
  String get detectionDetails => 'Detail Deteksi';
  @override
  String get deleteDetection => 'Hapus Deteksi';
  @override
  String get deleteDetectionConfirmation =>
      'Apakah Anda yakin ingin menghapus deteksi ini? Tindakan ini tidak dapat dibatalkan.';
      @override
  String get yesDelete => 'Ya, Hapus';
  @override
  String get deletingDetection => 'Menghapus deteksi...';
  @override
  String get successDetectionDeleted => 'Deteksi berhasil dihapus';
  @override
  String get time => 'Waktu';
  @override
  String get description => 'Deskripsi';

  // ============================================================================
  // PROFESSIONS
  // ============================================================================

  @override
  String get profOphthalmologist => 'Dokter Mata (Sp.M)';
  @override
  String get profEndocrinologist => 'Dokter Spesialis Penyakit Dalam';
  @override
  String get profGeneralPractitioner => 'Dokter Umum';
  @override
  String get profOptometrist => 'Optometris (Ahli Refraksi)';
  @override
  String get profNurse => 'Perawat / Ners';
  @override
  String get profMedicalStudent => 'Mahasiswa Kedokteran';
  @override
  String get profHealthcareAssistant => 'Asisten Medis';
  @override
  String get profOther => 'Lainnya';

  // ============================================================================
  // LOCATION
  // ============================================================================
  @override
  String get address => 'Alamat';

  @override
  String get province => 'Provinsi';

  @override
  String get city => 'Kota/Kabupaten';

  @override
  String get district => 'Kecamatan';

  @override
  String get village => 'Desa/Kelurahan';

  @override
  String get assignmentLocation => 'Lokasi Penempatan';

  @override
  String get detailedAddress => 'Alamat Lengkap';

  @override
  String get selectProvince => 'Pilih Provinsi';

  @override
  String get selectCity => 'Pilih Kota/Kabupaten';

  @override
  String get selectDistrict => 'Pilih Kecamatan';

  @override
  String get selectVillage => 'Pilih Desa/Kelurahan';

  // ============================================================================
  // MESSAGES
  // ============================================================================
  @override
  String get successSave => 'Berhasil disimpan!';
  @override
  String get successUpdate => 'Berhasil diperbarui!';
  @override
  String get successDelete => 'Berhasil dihapus!';
  @override
  String get successSignup => 'Pendaftaran berhasil! Cek email untuk kode OTP.';
  @override
  String get successSignin => 'Berhasil masuk!';
  @override
  String get successLogout => 'Berhasil keluar.';
  @override
  String get successOtpSent => 'Kode OTP telah dikirim ke email Anda.';
  @override
  String get successPasswordReset =>
      'Kata sandi berhasil diatur ulang. Silakan masuk.';
  @override
  String get successProfileUpdated => 'Profil berhasil diperbarui!';
  @override
  String get successPhotoDeleted => 'Foto berhasil di hapus!';
  @override
  String get errorOccurred => 'Terjadi kesalahan';
  @override
  String get networkError => 'Kesalahan jaringan. Periksa koneksi Anda.';
  @override
  String get noDataFound => 'Data tidak ditemukan';

  // ============================================================================
  // VALIDATION
  // ============================================================================
  @override
  String get fieldRequired => 'Kolom ini wajib diisi';

  @override
  String get passwordsNotMatch => 'Kata sandi tidak cocok';

  @override
  String get errorUnknown => 'Terjadi kesalahan yang tidak diketahui.';
  @override
  String get errorConnectionTimeout =>
      'Waktu koneksi habis. Periksa internet Anda.';
  @override
  String get errorSendTimeout => 'Gagal mengirim data. Silakan coba lagi.';
  @override
  String get errorReceiveTimeout => 'Server terlalu lama merespons.';
  @override
  String get errorRequestCancelled => 'Permintaan dibatalkan.';
  @override
  String get errorNoInternet => 'Tidak ada koneksi internet.';
  @override
  String get errorSecurityCertificate => 'Kesalahan sertifikat keamanan.';
  @override
  String get errorPermissionDenied =>
      'Izin penyimpanan ditolak. Harap aktifkan di pengaturan aplikasi.';

  @override
  String get errorPatientNotFound => 'Pasien tidak ditemukan.';
  @override
  String get errorPatientAlreadyExists => 'Kode pasien sudah terdaftar.';
  @override
  String get errorSessionNotFound => 'Sesi deteksi tidak ditemukan.';
  @override
  String get errorSessionExpired =>
      'Sesi berakhir (batas 15 menit). Silakan mulai ulang.';
  @override
  String get errorImageTooLarge => 'Ukuran gambar lebih dari 5MB.';
  @override
  String get errorImageInvalidFormat =>
      'Format gambar tidak valid (JPG/JEPG/PNG/TIFF).';
  @override
  String get errorBadRequest => 'Permintaan tidak valid.';
  @override
  String get errorTokenRevoked => 'Sesi dicabut. Silakan masuk kembali.';
  @override
  String get errorNoProfilePhoto => 'Tidak ada foto profil untuk dihapus.';
  @override
  String get errorInvalidCredentials => 'Email atau kata sandi salah.';
  @override
  String get errorInvalidOtp => 'Kode OTP salah.';
  @override
  String get errorTokenExpired => 'Sesi berakhir. Silakan masuk kembali.';
  @override
  String get errorNotAuthenticated => 'Anda belum masuk.';
  @override
  String get errorUnauthorized => 'Akses tidak diizinkan.';
  @override
  String get errorNoPermission => 'Anda tidak memiliki izin.';
  @override
  String get errorForbidden => 'Akses dilarang.';
  @override
  String get errorUserNotFound => 'Pengguna tidak ditemukan.';
  @override
  String get errorDetectionNotFound => 'Hasil deteksi tidak ditemukan.';
  @override
  String get errorNotFound => 'Data tidak ditemukan.';
  @override
  String get errorEmailAlreadyExists => 'Email sudah terdaftar.';
  @override
  String get errorConflict => 'Terjadi konflik data.';
  @override
  String get errorEmailInvalid => 'Format email salah.';
  @override
  String get errorPasswordTooShort => 'Kata sandi terlalu pendek.';
  @override
  String get errorPasswordWeak => 'Kata sandi terlalu lemah.';
  @override
  String get errorPhoneInvalid => 'Nomor telepon tidak valid.';
  @override
  String get errorOtpInvalid => 'OTP harus berupa angka.';
  @override
  String get errorDateInvalid => 'Format tanggal salah.';
  @override
  String get errorValidation => 'Periksa kembali input Anda.';
  @override
  String get errorTooManyRequests => 'Terlalu banyak permintaan. Mohon tunggu.';

  @override
  String get errorServerInternal => 'Kesalahan server internal.';
  @override
  String get errorServerBadGateway => 'Server tidak tersedia sementara.';
  @override
  String get errorServerUnavailable => 'Layanan sedang tidak tersedia.';
  @override
  String get errorServerTimeout => 'Waktu koneksi server habis.';
  @override
  String get errorEmailNotFound =>
      'Email tidak terdaftar. Silakan daftar terlebih dahulu.';

  // ============================================================================
  // DASHBOARD
  // ============================================================================
  @override
  String get dashboardTitle => 'Statistik Hari Ini';
  @override
  String get drDistribution => 'Sebaran Klasifikasi DR';
  @override
  String get greetingMorning => 'Selamat Pagi';
  @override
  String get greetingAfternoon => 'Selamat Siang';
  @override
  String get greetingEvening => 'Selamat Sore';
  @override
  String get greetingNight => 'Selamat Malam';
  @override
  String get totalPatients => 'Total Pasien';
  @override
  String get totalDetections => 'Total Deteksi';
  @override
  String get detectionsToday => 'Deteksi Hari Ini';
  @override
  String get recentPatients => 'Pasien Terbaru';
  @override
  String get recentDetections => 'Deteksi Terbaru';

  @override
  String get loadingData => 'Memuat data...';
  @override
  String get failedToLoad => 'Gagal Memuat Data';
  @override
  String get noDataTitle => 'Belum Ada Data';
  @override
  String get noDataDesc => 'Mulai tambahkan pasien dan lakukan deteksi';
  @override
  String get offlineBanner =>
      'Data mungkin tidak terbaru • Terakhir diperbarui:';
  @override
  String get recentActivity => 'Aktivitas Terbaru';
  @override
  String get total => 'Total';

  // ============================================================================
  // CLIENT-SIDE ERRORS (Image Handling)
  // ============================================================================
  @override
  String get errorFilePickerCancelled => 'Tidak ada file dipilih';

  @override
  String get errorFilePickerFailed => 'Gagal memilih file';

  @override
  String get errorImageCropCancelled => 'Pemotongan gambar dibatalkan';

  @override
  String get errorImageCropFailed => 'Gagal memotong gambar';

  @override
  String get errorImageConversionFailed => 'Gagal mengkonversi format gambar';

  @override
  String get errorNoImageSelected => 'Silakan pilih gambar terlebih dahulu';
}
