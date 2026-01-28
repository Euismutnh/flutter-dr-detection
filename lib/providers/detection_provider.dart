// lib/providers/detection_provider.dart

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image/image.dart' as img;
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../data/repositories/detection_repository.dart';
import '../data/models/detection/detection_model.dart';
import '../core/network/api_error_handler.dart';
import '../core/constants/app_constants.dart';
import '../core/theme/app_colors.dart';

/// Detection Provider
///
/// State management for DR detection workflow
///
/// Features:
/// - Image handling: Pick → Convert (TIFF) → Crop (299x299) → Upload
/// - 3-step detection flow: Start → Preview → Save/Cancel
/// - Detection history with filters (in-memory cache)
/// - Progress chart for patient
/// - Rethrow errors to UI for localized message handling
///
/// Image Flow:
/// 1. pickFile() - File picker (no camera), support JPG/PNG/TIFF
/// 2. convertImage() - Convert TIFF to JPG (if needed)
/// 3. cropImage() - Crop to 299x299 (WAJIB!)
/// 4. startDetection() - Upload cropped image + AI prediction
/// 5. saveDetection() or cancelDetection()
///
/// Usage:
/// ```dart
/// final provider = Provider.of<DetectionProvider>(context, listen: false);
/// try {
///   await provider.pickFile();
///   await provider.startDetection(patientCode, sideEye);
/// } on ApiException catch (e) {
///   final message = e.getTranslatedMessage(context);
///   Helpers.showErrorSnackbar(context, message);
/// }
/// ```
class DetectionProvider extends ChangeNotifier {
  final DetectionRepository _detectionRepository;

  DetectionProvider({DetectionRepository? detectionRepository})
    : _detectionRepository = detectionRepository ?? DetectionRepository();

  // ============================================================================
  // IMAGE STATE (CROPPING FLOW)
  // ============================================================================

  /// Step 1: Picked file from file picker
  File? _pickedFile;
  File? get pickedFile => _pickedFile;

  /// Original image bytes (after read file)
  Uint8List? _originalImageBytes;

  /// Converted image bytes (after TIFF → JPG conversion)
  Uint8List? _convertedImageBytes;

  /// Step 2: Cropped image bytes (299x299) - READY TO UPLOAD
  Uint8List? _croppedImageBytes;
  Uint8List? get croppedImageBytes => _croppedImageBytes;

  /// Image picking state
  bool _isPicking = false;
  bool get isPicking => _isPicking;

  /// Image converting state (TIFF → JPG)
  bool _isConverting = false;
  bool get isConverting => _isConverting;

  /// Image cropping state
  bool _isCropping = false;
  bool get isCropping => _isCropping;

  /// Check if image is ready to upload
  bool get hasImageReady => _croppedImageBytes != null;

  // ============================================================================
  // DETECTION SESSION STATE (3-STEP FLOW)
  // ============================================================================

  /// Session ID from backend (after start detection)
  String? _sessionId;
  String? get sessionId => _sessionId;

  /// Preview data from backend (after start detection)
  DetectionPreviewModel? _previewData;
  DetectionPreviewModel? get previewData => _previewData;

  /// Detection processing state (AI prediction)
  bool _isProcessing = false;
  bool get isProcessing => _isProcessing;

  /// Saving detection state
  bool _isSaving = false;
  bool get isSaving => _isSaving;

  /// Cancelling detection state
  bool _isCancelling = false;
  bool get isCancelling => _isCancelling;

  /// Check if there's an active session
  bool get hasActiveSession => _sessionId != null && _previewData != null;

  // ============================================================================
  // DETECTION HISTORY STATE (IN-MEMORY CACHE)
  // ============================================================================

  /// In-memory cache of detections
  List<DetectionModel>? _cachedDetections;
  List<DetectionModel>? get detections => _cachedDetections;

  /// Active filters
  int? _classificationFilter;
  int? get classificationFilter => _classificationFilter;

  int? _ageMinFilter;
  int? get ageMinFilter => _ageMinFilter;

  int? _ageMaxFilter;
  int? get ageMaxFilter => _ageMaxFilter;

  String? _genderFilter;
  String? get genderFilter => _genderFilter;

  String? _periodFilter;
  String? get periodFilter => _periodFilter;

  String? _patientCodeFilter;
  String? get patientCodeFilter => _patientCodeFilter;

  /// Loading history state
  bool _isLoadingHistory = false;
  bool get isLoadingHistory => _isLoadingHistory;

  /// Last load time
  DateTime? _lastLoadTime;
  DateTime? get lastLoadTime => _lastLoadTime;

  // ============================================================================
  // DETECTION DETAIL STATE
  // ============================================================================

  /// Selected detection for detail view
  DetectionModel? _selectedDetection;
  DetectionModel? get selectedDetection => _selectedDetection;

  /// Loading detail state
  bool _isLoadingDetail = false;
  bool get isLoadingDetail => _isLoadingDetail;

  /// Deleting detection state
  bool _isDeleting = false;
  bool get isDeleting => _isDeleting;

  // ============================================================================
  // PROGRESS CHART STATE
  // ============================================================================

  /// Progress chart data
  Map<String, dynamic>? _progressChartData;
  Map<String, dynamic>? get progressChartData => _progressChartData;

  /// Loading chart state
  bool _isLoadingChart = false;
  bool get isLoadingChart => _isLoadingChart;

  // ============================================================================
  // ERROR STATE
  // ============================================================================

  /// Error key (for debugging/optional UI display)
  String? _errorKey;
  String? get errorKey => _errorKey;

  // ============================================================================
  // COMPUTED PROPERTIES
  // ============================================================================

  /// Check if there are detections
  bool get hasDetections =>
      _cachedDetections != null && _cachedDetections!.isNotEmpty;

  /// Get detections count
  int get detectionsCount => _cachedDetections?.length ?? 0;

  /// Check if any filter is active
  bool get hasActiveFilters =>
      _classificationFilter != null ||
      _ageMinFilter != null ||
      _ageMaxFilter != null ||
      _genderFilter != null ||
      _periodFilter != null ||
      _patientCodeFilter != null;

  // ============================================================================
  // IMAGE HANDLING - STEP 1: PICK FILE
  // ============================================================================

  /// Pick image file (no camera)
  ///
  /// Supported formats: JPG, JPEG, PNG, TIF, TIFF
  ///
  /// Throws: ApiException (caught by UI for localized message)
  Future<void> pickFile() async {
    _isPicking = true;
    _clearError();
    notifyListeners();

    try {
      // ======================================
      // ✅ ADD THIS PERMISSION CHECK FIRST!
      // ======================================
      debugPrint('🔐 [DetectionProvider] Checking permission...');

      PermissionStatus status;

      if (Platform.isAndroid) {
        // Check Android version
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        final sdkInt = androidInfo.version.sdkInt;

        debugPrint('📱 [DetectionProvider] Android SDK: $sdkInt');

        if (sdkInt >= 33) {
          // Android 13+ (API 33+) - Use photos permission
          status = await Permission.photos.request();
        } else {
          // Android 12 and below - Use storage permission
          status = await Permission.storage.request();
        }
      } else {
        // iOS - Use photos permission
        status = await Permission.photos.request();
      }

      // Check permission result
      if (status.isDenied) {
        debugPrint('⚠️ [DetectionProvider] Permission denied');
        _isPicking = false;
        notifyListeners();
        throw ApiException.clientError('error_permission_denied');
      } else if (status.isPermanentlyDenied) {
        debugPrint('⚠️ [DetectionProvider] Permission permanently denied');
        _isPicking = false;
        notifyListeners();
        // Could open app settings here
        // await openAppSettings();
        throw ApiException.clientError('error_permission_denied');
      }

      debugPrint('✅ [DetectionProvider] Permission granted');
      // ======================================
      // END OF PERMISSION CHECK
      // ======================================

      // Original code continues here...
      debugPrint('📁 [DetectionProvider] Opening file picker...');

      // Pick file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: AppConstants.supportedImageExtensions,
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        debugPrint('⚠️ [DetectionProvider] No file selected');
        _isPicking = false;
        notifyListeners();
        throw ApiException.clientError('error_file_picker_cancelled');
      }

      // Get file
      final filePath = result.files.single.path;
      if (filePath == null) {
        throw ApiException.clientError('error_file_picker_failed');
      }

      _pickedFile = File(filePath);
      debugPrint('✅ [DetectionProvider] File picked: ${_pickedFile!.path}');

      // Read bytes
      _originalImageBytes = await _pickedFile!.readAsBytes();
      debugPrint(
        '📊 [DetectionProvider] File size: ${(_originalImageBytes!.length / 1024 / 1024).toStringAsFixed(2)} MB',
      );

      // Check file size
      if (_originalImageBytes!.length > AppConstants.maxImageSizeBytes) {
        _isPicking = false;
        notifyListeners();
        throw ApiException.clientError('error_image_too_large');
      }

      // Get extension
      final extension = filePath.split('.').last.toLowerCase();
      debugPrint('📝 [DetectionProvider] File extension: $extension');

      // Check if needs conversion (TIFF → JPG)
      if (AppConstants.needsConversion(extension)) {
        debugPrint('🔄 [DetectionProvider] Needs conversion: $extension → JPG');
        _isPicking = false;
        notifyListeners();
        // Convert
        await convertImage();
      } else {
        // No conversion needed
        _convertedImageBytes = _originalImageBytes;
        debugPrint('✅ [DetectionProvider] No conversion needed');
      }

      _isPicking = false;

      // Auto-open cropper
      debugPrint('✂️ [DetectionProvider] Auto-opening cropper...');
      await cropImage();
    } catch (e) {
      _isPicking = false;
      notifyListeners();
      debugPrint('❌ [DetectionProvider] Pick file failed: $e');

      // Rethrow ApiException as-is
      if (e is ApiException) {
        rethrow;
      }

      // Wrap other errors as client error
      throw ApiException.clientError('error_file_picker_failed');
    }
  }

  // ============================================================================
  // IMAGE HANDLING - STEP 2: CONVERT IMAGE (TIFF → JPG)
  // ============================================================================

  /// Convert TIFF to JPG
  ///
  /// Uses 'image' package for conversion
  ///
  /// Throws: ApiException (caught by UI for localized message)
  Future<void> convertImage() async {
    if (_originalImageBytes == null) {
      throw ApiException.clientError('error_no_image_selected');
    }

    _isConverting = true;
    _clearError();
    notifyListeners();

    try {
      debugPrint('🔄 [DetectionProvider] Converting image to JPG...');

      // Decode image (supports TIFF, PNG, JPG, etc.)
      final image = img.decodeImage(_originalImageBytes!);

      if (image == null) {
        throw ApiException.clientError('error_image_conversion_failed');
      }

      debugPrint(
        '📐 [DetectionProvider] Original size: ${image.width}x${image.height}',
      );

      // Encode to JPG
      final jpgBytes = img.encodeJpg(image, quality: 90);
      _convertedImageBytes = Uint8List.fromList(jpgBytes);

      debugPrint(
        '✅ [DetectionProvider] Converted to JPG (${(_convertedImageBytes!.length / 1024).toStringAsFixed(2)} KB)',
      );
      _isConverting = false;
      notifyListeners();
    } catch (e) {
      _isConverting = false;
      notifyListeners();
      debugPrint('❌ [DetectionProvider] Conversion failed: $e');

      // Rethrow ApiException as-is
      if (e is ApiException) {
        rethrow;
      }

      // Wrap other errors as client error
      throw ApiException.clientError('error_image_conversion_failed');
    }
  }

  // ============================================================================
  // IMAGE HANDLING - STEP 3: CROP IMAGE (299x299 - WAJIB!)
  // ============================================================================

  /// Crop image to 299x299 (REQUIRED!)
  ///
  /// Uses image_cropper package
  ///
  /// Throws: ApiException (caught by UI for localized message)
  Future<void> cropImage() async {
    if (_pickedFile == null) {
      throw ApiException.clientError('error_no_image_selected');
    }

    _isCropping = true;
    _clearError();
    notifyListeners();

    try {
      debugPrint('✂️ [DetectionProvider] Opening image cropper...');

      // Crop image with fixed 1:1 aspect ratio
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: _pickedFile!.path,
        compressQuality: 100,
        maxWidth: 299,
        maxHeight: 299,
        aspectRatio: const CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Fundus Image (299x299)',
            toolbarColor: AppColors.primary,
            toolbarWidgetColor: AppColors.surface,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
            hideBottomControls: false,
            aspectRatioPresets: [
              CropAspectRatioPreset.square, 
            ],
          ),
          IOSUiSettings(
            title: 'Crop Fundus Image',
            aspectRatioLockEnabled: true,
            resetAspectRatioEnabled: false,
            aspectRatioPickerButtonHidden: true,
            aspectRatioPresets: [CropAspectRatioPreset.square],
          ),
        ],
      );

      if (croppedFile == null) {
        debugPrint('⚠️ [DetectionProvider] Cropping cancelled by user');
        _isCropping = false;
        notifyListeners();
        throw ApiException.clientError('error_image_crop_cancelled');
      }

      // Read cropped bytes
      _croppedImageBytes = await croppedFile.readAsBytes();

      // Validate size is 299x299
      final croppedImage = img.decodeImage(_croppedImageBytes!);
      if (croppedImage != null) {
        debugPrint(
          '📐 [DetectionProvider] Cropped size: ${croppedImage.width}x${croppedImage.height}',
        );

        // Ensure exactly 299x299
        if (croppedImage.width != 299 || croppedImage.height != 299) {
          debugPrint('⚠️ [DetectionProvider] Resizing to 299x299...');
          final resized = img.copyResize(croppedImage, width: 299, height: 299);
          _croppedImageBytes = Uint8List.fromList(
            img.encodeJpg(resized, quality: 90),
          );
          debugPrint('✅ [DetectionProvider] Resized to 299x299');
        }
      }

      debugPrint(
        '✅ [DetectionProvider] Image cropped successfully (${(_croppedImageBytes!.length / 1024).toStringAsFixed(2)} KB)',
      );
      _isCropping = false;
      await Future.delayed(const Duration(milliseconds: 100));
      notifyListeners();
    } catch (e) {
      _isCropping = false;
      notifyListeners();
      debugPrint('❌ [DetectionProvider] Cropping failed: $e');

      // Rethrow ApiException as-is
      if (e is ApiException) {
        rethrow;
      }

      // Wrap other errors as client error
      throw ApiException.clientError('error_image_crop_failed');
    }
  }

  // ============================================================================
  // IMAGE HANDLING - RESET
  // ============================================================================

  /// Clear image and reset picker state
  void clearImage() {
    _pickedFile = null;
    _originalImageBytes = null;
    _convertedImageBytes = null;
    _croppedImageBytes = null;
    debugPrint('🧹 [DetectionProvider] Image cleared');
    notifyListeners();
  }

  // ============================================================================
  // DETECTION FLOW - STEP 1: START DETECTION
  // ============================================================================

  /// Start detection and get preview
  ///
  /// Requirements:
  /// - Must call pickFile() first
  /// - Image must be cropped (299x299)
  ///
  /// Throws: ApiException (caught by UI for localized message)
  Future<void> startDetection({
    required String patientCode,
    required String sideEye,
  }) async {
    if (_croppedImageBytes == null) {
      throw ApiException.clientError('error_no_image_selected');
    }

    _isProcessing = true;
    _clearError();
    notifyListeners();

    try {
      debugPrint('🚀 [DetectionProvider] Starting detection...');
      debugPrint('   Patient: $patientCode');
      debugPrint('   Side Eye: $sideEye');
      debugPrint(
        '   Image size: ${(_croppedImageBytes!.length / 1024).toStringAsFixed(2)} KB',
      );

      // Create MultipartFile from croppedImageBytes
      final multipartFile = MultipartFile.fromBytes(
        _croppedImageBytes!,
        filename: 'fundus_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      // Call repository
      final preview = await _detectionRepository.startDetection(
        patientCode: patientCode,
        sideEye: sideEye,
        image: multipartFile,
      );

      // Store session data
      _sessionId = preview.sessionId;
      _previewData = preview;

      debugPrint('✅ [DetectionProvider] Detection started successfully');
      debugPrint(
        '   Classification: ${preview.classification} - ${preview.predictedLabel}',
      );
      debugPrint(
        '   Confidence: ${(preview.confidence * 100).toStringAsFixed(1)}%',
      );

      _isProcessing = false;
      notifyListeners();
    } on ApiException catch (e) {
      _setError(e.errorKey);
      _isProcessing = false;
      notifyListeners();
      rethrow;
    } catch (e) {
      _setError('error_unknown');
      _isProcessing = false;
      notifyListeners();
      throw ApiException(errorKey: 'error_unknown', error: null);
    }
  }

  // ============================================================================
  // DETECTION FLOW - STEP 2A: SAVE DETECTION
  // ============================================================================

  /// Save detection to database
  ///
  /// Requirements:
  /// - Must call startDetection() first
  ///
  /// Throws: ApiException (caught by UI for localized message)
  Future<void> saveDetection() async {
    if (!hasActiveSession) {
      throw ApiException(errorKey: 'error_session_not_found', error: null);
    }

    _isSaving = true;
    _clearError();
    notifyListeners();

    try {
      debugPrint('💾 [DetectionProvider] Saving detection...');

      await _detectionRepository.saveDetection();

      debugPrint('✅ [DetectionProvider] Detection saved successfully');

      // Clear session data
      _clearSession();

      // Clear image
      clearImage();

      // Invalidate history cache
      _cachedDetections = null;
      _lastLoadTime = null;
      debugPrint('🧹 [DetectionProvider] History cache invalidated');

      _isSaving = false;
      notifyListeners();
    } on ApiException catch (e) {
      _setError(e.errorKey);
      _isSaving = false;
      notifyListeners();
      rethrow;
    } catch (e) {
      _setError('error_unknown');
      _isSaving = false;
      notifyListeners();
      throw ApiException(errorKey: 'error_unknown', error: null);
    }
  }

  // ============================================================================
  // DETECTION FLOW - STEP 2B: CANCEL DETECTION
  // ============================================================================

  /// Cancel detection and cleanup temp data
  ///
  /// Throws: ApiException (caught by UI for localized message)
  Future<void> cancelDetection() async {
    if (!hasActiveSession) {
      debugPrint('⚠️ [DetectionProvider] No active session to cancel');
      _clearSession();
      clearImage();
      return;
    }

    _isCancelling = true;
    _clearError();
    notifyListeners();

    try {
      debugPrint('🚫 [DetectionProvider] Cancelling detection...');

      await _detectionRepository.cancelDetection();

      debugPrint('✅ [DetectionProvider] Detection cancelled successfully');

      // Clear session data
      _clearSession();

      // Clear image
      clearImage();

      _isCancelling = false;
      notifyListeners();
    } on ApiException catch (e) {
      // Clear session anyway (cleanup local state)
      _clearSession();
      clearImage();

      _setError(e.errorKey);
      _isCancelling = false;
      notifyListeners();
      rethrow;
    } catch (e) {
      // Clear session anyway
      _clearSession();
      clearImage();

      _setError('error_unknown');
      _isCancelling = false;
      notifyListeners();
      throw ApiException(errorKey: 'error_unknown', error: null);
    }
  }

  // ============================================================================
  // DETECTION FLOW - RETRY
  // ============================================================================

  /// Retry detection (go back to step 1)
  void retryDetection() {
    debugPrint('🔄 [DetectionProvider] Retrying detection...');
    _clearSession();
    clearImage();
  }

  /// Clear session data
  void _clearSession() {
    _sessionId = null;
    _previewData = null;
    debugPrint('🧹 [DetectionProvider] Session cleared');
  }

  // ============================================================================
  // DETECTION HISTORY - LOAD
  // ============================================================================

  /// Load detection history with filters
  ///
  /// Throws: ApiException (caught by UI for localized message)
  Future<void> loadDetections({bool forceRefresh = false}) async {
    // If already in memory & not force refresh & no filters → skip
    if (_cachedDetections != null && !forceRefresh && !hasActiveFilters) {
      debugPrint(
        '📋 [DetectionProvider] Using in-memory cache (${_cachedDetections!.length} detections)',
      );
      return;
    }

    _isLoadingHistory = true;
    _clearError();
    notifyListeners();

    try {
      debugPrint(
        '🔄 [DetectionProvider] Loading detections (forceRefresh: $forceRefresh)...',
      );

      final detections = await _detectionRepository.getDetections(
        classification: _classificationFilter,
        ageMin: _ageMinFilter,
        ageMax: _ageMaxFilter,
        gender: _genderFilter,
        period: _periodFilter,
        patientCode: _patientCodeFilter,
        forceRefresh: forceRefresh,
      );

      // Update in-memory cache
      _cachedDetections = detections;
      _lastLoadTime = DateTime.now();

      debugPrint(
        '✅ [DetectionProvider] Loaded ${detections.length} detections',
      );
      _isLoadingHistory = false;
      notifyListeners();
    } on ApiException catch (e) {
      _setError(e.errorKey);
      _isLoadingHistory = false;
      notifyListeners();
      rethrow;
    } catch (e) {
      _setError('error_unknown');
      _isLoadingHistory = false;
      notifyListeners();
      throw ApiException(errorKey: 'error_unknown', error: null);
    }
  }

  /// Refresh detections (force reload)
  ///
  /// Throws: ApiException (caught by UI for localized message)
  Future<void> refreshDetections() async {
    debugPrint('🔄 [DetectionProvider] Refreshing detections...');
    await loadDetections(forceRefresh: true);
  }

  // ============================================================================
  // DETECTION HISTORY - FILTERS
  // ============================================================================

  /// Set classification filter (0-4)
  void setClassificationFilter(int? classification) {
    _classificationFilter = classification;
    _cachedDetections = null; // Invalidate cache
    debugPrint(
      '🔍 [DetectionProvider] Classification filter: ${classification ?? "All"}',
    );
    notifyListeners();
  }

  /// Set age range filter
  void setAgeRangeFilter(int? min, int? max) {
    _ageMinFilter = min;
    _ageMaxFilter = max;
    _cachedDetections = null; // Invalidate cache
    debugPrint(
      '🔍 [DetectionProvider] Age filter: ${min ?? "Any"}-${max ?? "Any"}',
    );
    notifyListeners();
  }

  /// Set gender filter
  void setGenderFilter(String? gender) {
    _genderFilter = gender;
    _cachedDetections = null; // Invalidate cache
    debugPrint('🔍 [DetectionProvider] Gender filter: ${gender ?? "All"}');
    notifyListeners();
  }

  /// Set period filter
  void setPeriodFilter(String? period) {
    _periodFilter = period;
    _cachedDetections = null; // Invalidate cache
    debugPrint('🔍 [DetectionProvider] Period filter: ${period ?? "All"}');
    notifyListeners();
  }

  /// Set patient code filter
  void setPatientCodeFilter(String? patientCode) {
    _patientCodeFilter = patientCode;
    _cachedDetections = null; // Invalidate cache
    debugPrint(
      '🔍 [DetectionProvider] Patient filter: ${patientCode ?? "All"}',
    );
    notifyListeners();
  }

  /// Clear all filters
  void clearFilters() {
    _classificationFilter = null;
    _ageMinFilter = null;
    _ageMaxFilter = null;
    _genderFilter = null;
    _periodFilter = null;
    _patientCodeFilter = null;
    _cachedDetections = null; // Invalidate cache
    debugPrint('🔍 [DetectionProvider] All filters cleared');
    notifyListeners();
  }

  // ============================================================================
  // DETECTION DETAIL
  // ============================================================================

  /// Get detection detail by ID
  ///
  /// Throws: ApiException (caught by UI for localized message)
  Future<void> getDetectionById(
    int detectionId, {
    bool forceRefresh = false,
  }) async {
    _isLoadingDetail = true;
    _clearError();
    notifyListeners();

    try {
      debugPrint(
        '🔍 [DetectionProvider] Loading detection detail: $detectionId',
      );

      final detection = await _detectionRepository.getDetectionById(
        detectionId,
        forceRefresh: forceRefresh,
      );

      _selectedDetection = detection;

      debugPrint('✅ [DetectionProvider] Detection detail loaded');
      _isLoadingDetail = false;
      notifyListeners();
    } on ApiException catch (e) {
      _setError(e.errorKey);
      _isLoadingDetail = false;
      notifyListeners();
      rethrow;
    } catch (e) {
      _setError('error_unknown');
      _isLoadingDetail = false;
      notifyListeners();
      throw ApiException(errorKey: 'error_unknown', error: null);
    }
  }

  /// Delete detection
  ///
  /// Throws: ApiException (caught by UI for localized message)
  Future<void> deleteDetection(int detectionId) async {
    _isDeleting = true;
    _clearError();
    notifyListeners();

    try {
      debugPrint('🗑️ [DetectionProvider] Deleting detection: $detectionId');

      await _detectionRepository.deleteDetection(detectionId);

      // Remove from cache
      if (_cachedDetections != null) {
        _cachedDetections!.removeWhere((d) => d.id == detectionId);
      }

      // Clear selected if same
      if (_selectedDetection?.id == detectionId) {
        _selectedDetection = null;
      }

      debugPrint('✅ [DetectionProvider] Detection deleted');
      _isDeleting = false;
      notifyListeners();
    } on ApiException catch (e) {
      _setError(e.errorKey);
      _isDeleting = false;
      notifyListeners();
      rethrow;
    } catch (e) {
      _setError('error_unknown');
      _isDeleting = false;
      notifyListeners();
      throw ApiException(errorKey: 'error_unknown', error: null);
    }
  }

  /// Set selected detection
  void setSelectedDetection(DetectionModel? detection) {
    _selectedDetection = detection;
    debugPrint(
      '📋 [DetectionProvider] Selected detection: ${detection?.id ?? "None"}',
    );
    notifyListeners();
  }

  /// Clear selected detection
  void clearSelectedDetection() {
    _selectedDetection = null;
    debugPrint('📋 [DetectionProvider] Selected detection cleared');
    notifyListeners();
  }

  // ============================================================================
  // PROGRESS CHART
  // ============================================================================

  /// Load patient progress chart
  ///
  /// Throws: ApiException (caught by UI for localized message)
  Future<void> loadProgressChart(int patientId) async {
    _isLoadingChart = true;
    _clearError();
    notifyListeners();

    try {
      debugPrint(
        '📊 [DetectionProvider] Loading progress chart for patient: $patientId',
      );

      final chartData = await _detectionRepository.getPatientProgressChart(
        patientId,
      );

      _progressChartData = chartData;

      debugPrint('✅ [DetectionProvider] Progress chart loaded');
      _isLoadingChart = false;
      notifyListeners();
    } on ApiException catch (e) {
      _setError(e.errorKey);
      _isLoadingChart = false;
      notifyListeners();
      rethrow;
    } catch (e) {
      _setError('error_unknown');
      _isLoadingChart = false;
      notifyListeners();
      throw ApiException(errorKey: 'error_unknown', error: null);
    }
  }

  /// Clear progress chart data
  void clearProgressChart() {
    _progressChartData = null;
    debugPrint('📊 [DetectionProvider] Progress chart cleared');
    notifyListeners();
  }

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  /// Set error key
  void _setError(String key) {
    _errorKey = key;
    notifyListeners();
  }

  /// Clear error key
  void _clearError() {
    _errorKey = null;
  }

  /// Clear all cache
  void clearCache() {
    // Clear image
    clearImage();

    // Clear session
    _clearSession();

    // Clear history
    _cachedDetections = null;
    _lastLoadTime = null;

    // Clear filters
    _classificationFilter = null;
    _ageMinFilter = null;
    _ageMaxFilter = null;
    _genderFilter = null;
    _periodFilter = null;
    _patientCodeFilter = null;

    // Clear detail
    _selectedDetection = null;

    // Clear chart
    _progressChartData = null;

    // Clear error
    _errorKey = null;

    debugPrint('🧹 [DetectionProvider] All cache cleared');
    notifyListeners();
  }

  /// Check if cache is expired (1 hour)
  bool isCacheExpired() {
    if (_lastLoadTime == null) return true;
    final age = DateTime.now().difference(_lastLoadTime!);
    return age > const Duration(hours: 1);
  }
}
