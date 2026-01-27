// lib/core/utils/error_mapper.dart

import '../network/api_error_handler.dart';
import '../l10n/app_localizations.dart';

/// Extension to map ApiException keys to Localized Strings
/// Ini adalah "Jembatan" antara Logic Backend dengan Bahasa UI
extension ApiExceptionMapper on ApiException {
  /// Get translated message based on error key
  
  // ===========================================================================
  // [SOP 2] METHOD BEST PRACTICE (SAFE FOR ASYNC)
  // Gunanya: Dipakai setelah 'await' agar tidak butuh BuildContext.
  // ===========================================================================
  String getTranslatedMessageFromL10n(AppLocalizations l10n) {

    switch (errorKey) {
      // ========================================================================
      // NETWORK ERRORS
      // ========================================================================
      case 'error_connection_timeout':
        return l10n.errorConnectionTimeout;
      case 'error_send_timeout':
        return l10n.errorSendTimeout;
      case 'error_receive_timeout':
        return l10n.errorReceiveTimeout;
      case 'error_request_cancelled':
        return l10n.errorRequestCancelled;
      case 'error_no_internet':
        return l10n.errorNoInternet;
      case 'error_security_certificate':
        return l10n.errorSecurityCertificate;

      // ========================================================================
      // BAD REQUEST (400) & CONFLICT (409)
      // ========================================================================
      case 'error_patient_not_found':
        return l10n.errorPatientNotFound;
      case 'error_patient_already_exists':
        return l10n.errorPatientAlreadyExists;
      case 'error_session_not_found':
        return l10n.errorSessionNotFound;
      case 'error_session_expired':
        return l10n.errorSessionExpired;
      case 'error_image_too_large':
        return l10n.errorImageTooLarge;
      case 'error_image_invalid_format':
        return l10n.errorImageInvalidFormat;
      case 'error_email_already_exists':
        return l10n.errorEmailAlreadyExists;
      case 'error_invalid_otp':
        return l10n.errorInvalidOtp;
      case 'error_no_profile_photo':
        return l10n.errorNoProfilePhoto;
      case 'error_conflict':
        return l10n.errorConflict;
      case 'error_bad_request':
        return l10n.errorBadRequest;

      // ========================================================================
      // UNAUTHORIZED (401)
      // ========================================================================
      case 'error_invalid_credentials':
        return l10n.errorInvalidCredentials;
      case 'error_email_not_found': 
        return l10n.errorEmailNotFound;
      case 'error_token_expired':
        return l10n.errorTokenExpired;
      case 'error_token_revoked':
        return l10n.errorTokenRevoked;
      case 'error_not_authenticated':
        return l10n.errorNotAuthenticated;
      case 'error_unauthorized':
        return l10n.errorUnauthorized;

      // ========================================================================
      // FORBIDDEN (403)
      // ========================================================================
      case 'error_no_permission':
        return l10n.errorNoPermission;
      case 'error_forbidden':
        return l10n.errorForbidden;

      // ========================================================================
      // NOT FOUND (404)
      // ========================================================================
      case 'error_user_not_found':
        return l10n.errorUserNotFound;
      case 'error_detection_not_found':
        return l10n.errorDetectionNotFound;
      case 'error_not_found':
        return l10n.errorNotFound;

      // ========================================================================
      // VALIDATION (422)
      // ========================================================================
      case 'error_email_invalid':
        return l10n.errorEmailInvalid;
      case 'error_password_too_short':
        return l10n.errorPasswordTooShort;
      case 'error_password_weak':
        return l10n.errorPasswordWeak;
      case 'error_phone_invalid':
        return l10n.errorPhoneInvalid;
      case 'error_otp_invalid':
        return l10n.errorOtpInvalid;
      case 'error_date_invalid':
        return l10n.errorDateInvalid;
      case 'error_validation':
        return l10n.errorValidation;

      // ========================================================================
      // SERVER ERRORS (500+)
      // ========================================================================
      case 'error_too_many_requests':
        return l10n.errorTooManyRequests;
      case 'error_server_internal':
        return l10n.errorServerInternal;
      case 'error_server_bad_gateway':
        return l10n.errorServerBadGateway;
      case 'error_server_unavailable':
        return l10n.errorServerUnavailable;
      case 'error_server_timeout':
        return l10n.errorServerTimeout;

      // ========================================================================
      // CLIENT-SIDE ERRORS (Image Handling)
      // ========================================================================
      case 'error_file_picker_cancelled':
        return l10n.errorFilePickerCancelled;
      case 'error_file_picker_failed':
        return l10n.errorFilePickerFailed;
      case 'error_image_crop_cancelled':
        return l10n.errorImageCropCancelled;
      case 'error_image_crop_failed':
        return l10n.errorImageCropFailed;
      case 'error_image_conversion_failed':
        return l10n.errorImageConversionFailed;
      case 'error_no_image_selected':
        return l10n.errorNoImageSelected;

      // ========================================================================
      // DEFAULT FALLBACK
      // ========================================================================
      case 'error_unknown':
      default:
        return l10n.errorUnknown;
    }
  }
}
