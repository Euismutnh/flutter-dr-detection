// lib/features/export/export_service.dart

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';

import '../../data/models/patient/patient_model.dart';
import '../../data/models/detection/detection_model.dart';
import '../../data/models/user/user_model.dart';

/// Export Service for generating PDF and Excel reports
///
/// Usage:
/// ```dart
/// final exportService = ExportService();
///
/// // Export single patient report
/// await exportService.exportPatientReportPdf(patient, detections, operator);
///
/// // Export all patients to Excel
/// await exportService.exportPatientsExcel(patients);
///
/// // Export all detections to PDF
/// await exportService.exportDetectionsPdf(detections, operator);
/// ```
class ExportService {
  // Singleton pattern
  static final ExportService _instance = ExportService._internal();
  factory ExportService() => _instance;
  ExportService._internal();

  // Date formatters
  final _dateFormat = DateFormat('dd MMM yyyy');
  final _dateTimeFormat = DateFormat('dd MMM yyyy, HH:mm');
  final _fileNameFormat = DateFormat('yyyyMMdd_HHmmss');

  // PDF Colors (matching app theme)
  static const _primaryColor = PdfColor.fromInt(0xFF2E7CF6);
  static const _primaryLight = PdfColor.fromInt(0xFF5B9DF8);
  static const _textPrimary = PdfColor.fromInt(0xFF1A1A2E);
  static const _textSecondary = PdfColor.fromInt(0xFF6B7280);
  static const _borderColor = PdfColor.fromInt(0xFFE5E7EB);
  static const _successColor = PdfColor.fromInt(0xFF10B981);
  static const _warningColor = PdfColor.fromInt(0xFFF59E0B);
  static const _warningDark = PdfColor.fromInt(0xFFD97706);
  static const _dangerColor = PdfColor.fromInt(0xFFEF4444);
  static const _dangerDark = PdfColor.fromInt(0xFFDC2626);

  // ============================================================================
  // PUBLIC METHODS - PDF EXPORTS
  // ============================================================================

  /// Export single patient report with detection history to PDF
  Future<void> exportPatientReportPdf(
    PatientModel patient,
    List<DetectionModel> detections,
    UserModel operator, {
    Uint8List? fundusImage,
  }) async {
    final pdf = pw.Document();
    final font = await _loadFont();
    final fontBold = await _loadFontBold();
    final logo = await _loadLogo();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (context) =>
            _buildHeader(font, fontBold, title: 'PATIENT REPORT', logo: logo),
        footer: (context) => _buildFooter(context, font, operator),
        build: (context) => [
          _buildPatientInfoSection(patient, font, fontBold),
          pw.SizedBox(height: 20),

          // Progress Chart (jika ada lebih dari 1 detection)
          if (detections.length > 1) ...[
            _buildProgressChartSection(detections, font, fontBold),
            pw.SizedBox(height: 20),
          ],

          _buildDetectionHistoryTable(detections, font, fontBold),

          if (detections.isNotEmpty) ...[
            pw.SizedBox(height: 20),
            _buildLatestResultSection(detections.first, font, fontBold),
          ],
        ],
      ),
    );

    await _savePdf(pdf, 'patient_report_${patient.patientCode}');
  }

  // ============================================================================
  // TAMBAHKAN METHOD BARU INI (Progress Chart)
  // ============================================================================

  pw.Widget _buildProgressChartSection(
    List<DetectionModel> detections,
    pw.Font font,
    pw.Font fontBold,
  ) {
    // Sort detections by date (oldest first for chart)
    final sortedDetections = List<DetectionModel>.from(detections)
      ..sort((a, b) => a.detectedAt.compareTo(b.detectedAt));

    // Take last 10 data points if more than 10
    final chartData = sortedDetections.length > 10
        ? sortedDetections.sublist(sortedDetections.length - 10)
        : sortedDetections;

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'PROGRESS CHART',
          style: pw.TextStyle(
            font: fontBold,
            fontSize: 12,
            color: _primaryColor,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Container(
          padding: const pw.EdgeInsets.all(15),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: _borderColor),
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
          ),
          child: _buildProgressTimeline(chartData, font, fontBold),
        ),
        pw.SizedBox(height: 8),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: [
            _buildChartLegend('No DR', _successColor, font),
            pw.SizedBox(width: 12),
            _buildChartLegend('Mild', _warningColor, font),
            pw.SizedBox(width: 12),
            _buildChartLegend('Moderate', _warningDark, font),
            pw.SizedBox(width: 12),
            _buildChartLegend('Severe', _dangerColor, font),
            pw.SizedBox(width: 12),
            _buildChartLegend('Proliferative', _dangerDark, font),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildProgressTimeline(
    List<DetectionModel> data,
    pw.Font font,
    pw.Font fontBold,
  ) {
    if (data.isEmpty) {
      return pw.Center(
        child: pw.Text(
          'No data available',
          style: pw.TextStyle(font: font, fontSize: 10, color: _textSecondary),
        ),
      );
    }

    return pw.Column(
      children: [
        // Timeline visualization
        ...data.map((detection) {
          final color = _getClassificationColor(detection.classification);
          final dateStr = _dateFormat.format(detection.detectedAt);

          return pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 12),
            child: pw.Row(
              children: [
                // Date
                pw.Container(
                  width: 90,
                  child: pw.Text(
                    dateStr,
                    style: pw.TextStyle(
                      font: font,
                      fontSize: 9,
                      color: _textSecondary,
                    ),
                  ),
                ),

                // Level indicator (visual bar)
                pw.Expanded(
                  child: pw.Row(
                    children: [
                      // Bar representing severity level (0-4)
                      ...List.generate(5, (index) {
                        final isActive = index <= detection.classification;
                        return pw.Container(
                          width: 40,
                          height: 20,
                          margin: const pw.EdgeInsets.only(right: 2),
                          decoration: pw.BoxDecoration(
                            color: isActive
                                ? color
                                : PdfColor.fromInt(0xFFE5E7EB),
                            borderRadius: const pw.BorderRadius.all(
                              pw.Radius.circular(2),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),

                pw.SizedBox(width: 10),

                // Classification label
                pw.Container(
                  width: 110,
                  child: pw.Text(
                    detection.predictedLabel,
                    style: pw.TextStyle(
                      font: fontBold,
                      fontSize: 9,
                      color: color,
                    ),
                  ),
                ),

                // Confidence
                pw.Container(
                  width: 45,
                  child: pw.Text(
                    '${(detection.confidence * 100).toStringAsFixed(0)}%',
                    style: pw.TextStyle(
                      font: font,
                      fontSize: 9,
                      color: _textSecondary,
                    ),
                    textAlign: pw.TextAlign.right,
                  ),
                ),

                // Eye side
                pw.Container(
                  width: 35,
                  alignment: pw.Alignment.centerRight,
                  child: pw.Text(
                    detection.sideEye,
                    style: pw.TextStyle(
                      font: font,
                      fontSize: 9,
                      color: _textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),

        // Scale legend at bottom
        pw.SizedBox(height: 8),
        pw.Container(
          padding: const pw.EdgeInsets.only(top: 8),
          decoration: const pw.BoxDecoration(
            border: pw.Border(
              top: pw.BorderSide(color: _borderColor, width: 1),
            ),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              pw.Text(
                'Severity Scale: ',
                style: pw.TextStyle(
                  font: font,
                  fontSize: 8,
                  color: _textSecondary,
                ),
              ),
              pw.Text(
                '0 (No DR)  ->  1 (Mild)  ->  2 (Moderate)  ->  3 (Severe)  ->  4 (Proliferative DR)',
                style: pw.TextStyle(
                  font: fontBold,
                  fontSize: 8,
                  color: _textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _buildChartLegend(String label, PdfColor color, pw.Font font) {
    return pw.Row(
      mainAxisSize: pw.MainAxisSize.min,
      children: [
        pw.Container(
          width: 10,
          height: 10,
          decoration: pw.BoxDecoration(color: color, shape: pw.BoxShape.circle),
        ),
        pw.SizedBox(width: 4),
        pw.Text(
          label,
          style: pw.TextStyle(font: font, fontSize: 8, color: _textSecondary),
        ),
      ],
    );
  }

  // ============================================================================
  // GANTI METHOD _buildLatestResultSection YANG LAMA DENGAN INI
  // ============================================================================

  /// Export all patients list to PDF
  Future<void> exportAllPatientsPdf(
    List<PatientModel> patients,
    UserModel operator,
  ) async {
    final pdf = pw.Document();
    final font = await _loadFont();
    final fontBold = await _loadFontBold();
    final logo = await _loadLogo();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (context) =>
            _buildHeader(font, fontBold, title: 'PATIENTS LIST', logo: logo),
        footer: (context) => _buildFooter(context, font, operator),
        build: (context) => [
          _buildSummaryStats(
            'Total Patients: ${patients.length}',
            'Male: ${patients.where((p) => p.isMale).length}  |  Female: ${patients.where((p) => p.isFemale).length}',
            font,
            fontBold,
          ),
          pw.SizedBox(height: 20),
          _buildPatientsTable(patients, font, fontBold),
        ],
      ),
    );

    await _savePdf(pdf, 'all_patients');
  }

  /// Export detection history to PDF
  Future<void> exportDetectionsPdf(
    List<DetectionModel> detections,
    UserModel operator, {
    PatientModel? patient,
  }) async {
    final pdf = pw.Document();
    final font = await _loadFont();
    final fontBold = await _loadFontBold();
    final logo = await _loadLogo();

    final title = patient != null
        ? 'DETECTION HISTORY - ${patient.name}'
        : 'ALL DETECTIONS';

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (context) =>
            _buildHeader(font, fontBold, title: title, logo: logo),
        footer: (context) => _buildFooter(context, font, operator),
        build: (context) => [
          _buildDetectionSummaryStats(detections, font, fontBold),
          pw.SizedBox(height: 20),
          _buildFullDetectionTable(detections, font, fontBold),
        ],
      ),
    );

    final fileName = patient != null
        ? 'detections_${patient.patientCode}'
        : 'all_detections';
    await _savePdf(pdf, fileName);
  }

  /// Export full report (summary + patients + detections) to PDF
  Future<void> exportFullReportPdf(
    List<PatientModel> patients,
    List<DetectionModel> detections,
    UserModel operator,
    int totalScans,
  ) async {
    final pdf = pw.Document();
    final font = await _loadFont();
    final fontBold = await _loadFontBold();
    final logo = await _loadLogo();

    // ========================================================================
    // PAGE 1: SUMMARY & STATISTICS
    // ========================================================================
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _buildHeader(font, fontBold, title: 'FULL REPORT', logo: logo),
            pw.SizedBox(height: 30),

            // Summary Statistics
            _buildFullReportSummary(
              patients,
              detections,
              totalScans,
              font,
              fontBold,
            ),

            pw.SizedBox(height: 30),

            // Classification Breakdown
            _buildClassificationBreakdown(detections, font, fontBold),

            pw.SizedBox(height: 30),

            // Gender Distribution
            _buildGenderDistribution(patients, font, fontBold),

            pw.Spacer(),

            // Footer manual untuk halaman pertama
            _buildFooter(context, font, operator),
          ],
        ),
      ),
    );

    // ========================================================================
    // PAGE 2+: ALL PATIENTS LIST
    // ========================================================================
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (context) => _buildHeader(
          font,
          fontBold,
          title: 'ALL PATIENTS LIST',
          logo: logo,
        ),
        footer: (context) => _buildFooter(context, font, operator),
        build: (context) => [
          _buildSummaryStats(
            'Total Patients: ${patients.length}',
            'Male: ${patients.where((p) => p.isMale).length}  |  Female: ${patients.where((p) => p.isFemale).length}',
            font,
            fontBold,
          ),
          pw.SizedBox(height: 20),
          _buildPatientsTable(patients, font, fontBold),
        ],
      ),
    );

    // ========================================================================
    // PAGE 3+: ALL DETECTIONS HISTORY
    // ========================================================================
    if (detections.isNotEmpty) {
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          header: (context) => _buildHeader(
            font,
            fontBold,
            title: 'ALL DETECTIONS HISTORY',
            logo: logo,
          ),
          footer: (context) => _buildFooter(context, font, operator),
          build: (context) => [
            _buildDetectionSummaryStats(detections, font, fontBold),
            pw.SizedBox(height: 20),
            _buildFullDetectionTable(detections, font, fontBold),
          ],
        ),
      );
    }

    await _savePdf(pdf, 'full_report');
  }

  // ========================================================================
  // HELPER METHOD: Gender Distribution (NEW!)
  // ========================================================================
  pw.Widget _buildGenderDistribution(
    List<PatientModel> patients,
    pw.Font font,
    pw.Font fontBold,
  ) {
    final maleCount = patients.where((p) => p.isMale).length;
    final femaleCount = patients.where((p) => p.isFemale).length;
    final total = patients.length;

    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _borderColor),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'GENDER DISTRIBUTION',
            style: pw.TextStyle(
              font: fontBold,
              fontSize: 12,
              color: _primaryColor,
            ),
          ),
          pw.SizedBox(height: 15),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
            children: [
              _buildGenderBox(
                'Male',
                maleCount,
                total,
                const PdfColor.fromInt(0xFF3B82F6),
                font,
                fontBold,
              ),
              _buildGenderBox(
                'Female',
                femaleCount,
                total,
                const PdfColor.fromInt(0xFFEC4899),
                font,
                fontBold,
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildGenderBox(
    String label,
    int count,
    int total,
    PdfColor color,
    pw.Font font,
    pw.Font fontBold,
  ) {
    final percentage = total > 0
        ? (count / total * 100).toStringAsFixed(1)
        : '0';

    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromInt(color.toInt() & 0xFFFFFF | 0x20000000),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              font: font,
              fontSize: 10,
              color: _textSecondary,
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            '$count',
            style: pw.TextStyle(font: fontBold, fontSize: 24, color: color),
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            '$percentage%',
            style: pw.TextStyle(
              font: font,
              fontSize: 10,
              color: _textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // PUBLIC METHODS - EXCEL EXPORTS
  // ============================================================================

  /// Export patients list to Excel
  Future<void> exportPatientsExcel(List<PatientModel> patients) async {
    final excel = Excel.createExcel();
    final sheet = excel['Patients'];

    // Header row
    final headers = [
      'No',
      'Patient Code',
      'Name',
      'Gender',
      'Date of Birth',
      'Age',
      'Created At',
    ];
    for (var i = 0; i < headers.length; i++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
        ..value = TextCellValue(headers[i])
        ..cellStyle = CellStyle(
          bold: true,
          backgroundColorHex: ExcelColor.fromHexString('#2E7CF6'),
          fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
        );
    }

    // Data rows
    for (var i = 0; i < patients.length; i++) {
      final p = patients[i];
      final row = i + 1;

      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
          .value = IntCellValue(
        i + 1,
      );
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
          .value = TextCellValue(
        p.patientCode,
      );
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row))
          .value = TextCellValue(
        p.name,
      );
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row))
          .value = TextCellValue(
        p.gender,
      );
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: row))
          .value = TextCellValue(
        _dateFormat.format(p.dateOfBirth),
      );
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: row))
          .value = IntCellValue(
        p.age ?? 0,
      );
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: row))
          .value = TextCellValue(
        _dateTimeFormat.format(p.createdAt),
      );
    }

    // Auto-fit columns
    for (var i = 0; i < headers.length; i++) {
      sheet.setColumnWidth(i, 18);
    }

    // Remove default sheet
    excel.delete('Sheet1');

    await _saveExcel(excel, 'patients');
  }

  /// Export detections to Excel
  Future<void> exportDetectionsExcel(
    List<DetectionModel> detections, {
    PatientModel? patient,
  }) async {
    final excel = Excel.createExcel();
    final sheet = excel['Detections'];

    // Header row
    final headers = [
      'No',
      'Date',
      'Patient Code',
      'Patient Name',
      'Gender',
      'Age',
      'Eye',
      'Classification',
      'Result',
      'Confidence',
      'Risk Level',
    ];
    for (var i = 0; i < headers.length; i++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
        ..value = TextCellValue(headers[i])
        ..cellStyle = CellStyle(
          bold: true,
          backgroundColorHex: ExcelColor.fromHexString('#2E7CF6'),
          fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
        );
    }

    // Data rows
    for (var i = 0; i < detections.length; i++) {
      final d = detections[i];
      final row = i + 1;

      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
          .value = IntCellValue(
        i + 1,
      );
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
          .value = TextCellValue(
        _dateTimeFormat.format(d.detectedAt),
      );
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row))
          .value = TextCellValue(
        d.patientCode,
      );
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row))
          .value = TextCellValue(
        d.patientName,
      );
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: row))
          .value = TextCellValue(
        d.patientGender,
      );
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: row))
          .value = IntCellValue(
        d.patientAge,
      );
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: row))
          .value = TextCellValue(
        d.sideEye,
      );
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: row))
          .value = IntCellValue(
        d.classification,
      );
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: row))
          .value = TextCellValue(
        d.predictedLabel,
      );
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: row))
          .value = TextCellValue(
        '${(d.confidence * 100).toStringAsFixed(1)}%',
      );
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 10, rowIndex: row))
          .value = TextCellValue(
        _getRiskLevel(d.classification),
      );
    }

    // Auto-fit columns
    for (var i = 0; i < headers.length; i++) {
      sheet.setColumnWidth(i, 15);
    }

    // Remove default sheet
    excel.delete('Sheet1');

    final fileName = patient != null
        ? 'detections_${patient.patientCode}'
        : 'all_detections';
    await _saveExcel(excel, fileName);
  }

  // ============================================================================
  // PRIVATE METHODS - PDF COMPONENTS
  // ============================================================================

  Future<pw.Font> _loadFont() async {
    final fontData = await rootBundle.load(
      'assets/fonts/PlusJakartaSans-Regular.ttf',
    );
    return pw.Font.ttf(fontData);
  }

  Future<pw.Font> _loadFontBold() async {
    final fontData = await rootBundle.load(
      'assets/fonts/PlusJakartaSans-Bold.ttf',
    );
    return pw.Font.ttf(fontData);
  }

  pw.Widget _buildHeader(
    pw.Font font,
    pw.Font fontBold, {
    String? title,
    pw.MemoryImage? logo,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 20),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: _borderColor, width: 2)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              if (logo != null)
                pw.Container(
                  width: 48,
                  height: 48,
                  margin: const pw.EdgeInsets.only(right: 12),
                  child: pw.Image(logo),
                ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    title ?? 'DR DETECTION REPORT',
                    style: pw.TextStyle(
                      font: fontBold,
                      fontSize: 18,
                      color: _primaryColor,
                    ),
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    'Diabetic Retinopathy Detection System',
                    style: pw.TextStyle(
                      font: font,
                      fontSize: 10,
                      color: _textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                'Generated: ${_dateTimeFormat.format(DateTime.now())}',
                style: pw.TextStyle(
                  font: font,
                  fontSize: 9,
                  color: _textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<pw.MemoryImage?> _loadLogo() async {
    try {
      final logoData = await rootBundle.load('assets/images/app_logo2.png');
      return pw.MemoryImage(logoData.buffer.asUint8List());
    } catch (e) {
      debugPrint('❌ [ExportService] Failed to load logo: $e');
      return null;
    }
  }

  pw.Widget _buildFooter(pw.Context context, pw.Font font, UserModel operator) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 10),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: _borderColor, width: 1)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'DR Detection App v1.0.0 | Confidential Medical Record',
            style: pw.TextStyle(font: font, fontSize: 8, color: _textSecondary),
          ),
          pw.Text(
            'Operator: ${operator.fullName} | Page ${context.pageNumber} of ${context.pagesCount}',
            style: pw.TextStyle(font: font, fontSize: 8, color: _textSecondary),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPatientInfoSection(
    PatientModel patient,
    pw.Font font,
    pw.Font fontBold,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _borderColor),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'PATIENT INFORMATION',
            style: pw.TextStyle(
              font: fontBold,
              fontSize: 12,
              color: _primaryColor,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            children: [
              pw.Expanded(
                child: _buildInfoRow('Name', patient.name, font, fontBold),
              ),
              pw.Expanded(
                child: _buildInfoRow(
                  'Patient ID',
                  patient.patientCode,
                  font,
                  fontBold,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            children: [
              pw.Expanded(
                child: _buildInfoRow('Gender', patient.gender, font, fontBold),
              ),
              pw.Expanded(
                child: _buildInfoRow(
                  'Age',
                  '${patient.age} years',
                  font,
                  fontBold,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            children: [
              pw.Expanded(
                child: _buildInfoRow(
                  'Date of Birth',
                  _dateFormat.format(patient.dateOfBirth),
                  font,
                  fontBold,
                ),
              ),
              pw.Expanded(
                child: _buildInfoRow(
                  'Registered',
                  _dateFormat.format(patient.createdAt),
                  font,
                  fontBold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildInfoRow(
    String label,
    String value,
    pw.Font font,
    pw.Font fontBold,
  ) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: 80,
          child: pw.Text(
            '$label:',
            style: pw.TextStyle(
              font: font,
              fontSize: 10,
              color: _textSecondary,
            ),
          ),
        ),
        pw.Expanded(
          child: pw.Text(
            value,
            style: pw.TextStyle(
              font: fontBold,
              fontSize: 10,
              color: _textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  pw.Widget _buildDetectionHistoryTable(
    List<DetectionModel> detections,
    pw.Font font,
    pw.Font fontBold,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'DETECTION HISTORY (Total: ${detections.length} screenings)',
          style: pw.TextStyle(
            font: fontBold,
            fontSize: 12,
            color: _primaryColor,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Table(
          border: pw.TableBorder.all(color: _borderColor),
          columnWidths: {
            0: const pw.FlexColumnWidth(2),
            1: const pw.FlexColumnWidth(1.5),
            2: const pw.FlexColumnWidth(2.5),
            3: const pw.FlexColumnWidth(1.5),
            4: const pw.FlexColumnWidth(1.5),
          },
          children: [
            // Header
            pw.TableRow(
              decoration: const pw.BoxDecoration(
                color: PdfColor.fromInt(0xFFF3F4F6),
              ),
              children: [
                _buildTableCell('Date', font, fontBold, isHeader: true),
                _buildTableCell('Eye', font, fontBold, isHeader: true),
                _buildTableCell('Result', font, fontBold, isHeader: true),
                _buildTableCell('Conf.', font, fontBold, isHeader: true),
                _buildTableCell('Risk', font, fontBold, isHeader: true),
              ],
            ),
            // Data rows
            ...detections.map(
              (d) => pw.TableRow(
                children: [
                  _buildTableCell(
                    _dateFormat.format(d.detectedAt),
                    font,
                    fontBold,
                  ),
                  _buildTableCell(d.sideEye, font, fontBold),
                  _buildTableCell(d.predictedLabel, font, fontBold),
                  _buildTableCell(
                    '${(d.confidence * 100).toStringAsFixed(0)}%',
                    font,
                    fontBold,
                  ),
                  _buildRiskCell(d.classification, font, fontBold),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildTableCell(
    String text,
    pw.Font font,
    pw.Font fontBold, {
    bool isHeader = false,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          font: isHeader ? fontBold : font,
          fontSize: 9,
          color: isHeader ? _textPrimary : _textSecondary,
        ),
      ),
    );
  }

  pw.Widget _buildRiskCell(int classification, pw.Font font, pw.Font fontBold) {
    final risk = _getRiskLevel(classification);
    final color = _getClassificationColor(classification);

    return pw.Container(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: pw.BoxDecoration(
          color: PdfColor.fromInt(color.toInt() & 0xFFFFFF | 0x20000000),
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
        ),
        child: pw.Text(
          risk,
          style: pw.TextStyle(font: fontBold, fontSize: 8, color: color),
        ),
      ),
    );
  }

  pw.Widget _buildLatestResultSection(
    DetectionModel detection,
    pw.Font font,
    pw.Font fontBold,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _primaryLight),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        color: const PdfColor.fromInt(0xFFF0F9FF),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'LATEST RESULT',
            style: pw.TextStyle(
              font: fontBold,
              fontSize: 12,
              color: _primaryColor,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow(
                      'Classification',
                      detection.predictedLabel,
                      font,
                      fontBold,
                    ),
                    pw.SizedBox(height: 4),
                    _buildInfoRow(
                      'Confidence',
                      '${(detection.confidence * 100).toStringAsFixed(1)}%',
                      font,
                      fontBold,
                    ),
                    pw.SizedBox(height: 4),
                    _buildInfoRow(
                      'Risk Level',
                      _getRiskLevel(detection.classification),
                      font,
                      fontBold,
                    ),
                    pw.SizedBox(height: 4),
                    _buildInfoRow(
                      'Eye Side',
                      detection.sideEye,
                      font,
                      fontBold,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildSummaryStats(
    String title,
    String subtitle,
    pw.Font font,
    pw.Font fontBold,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: const PdfColor.fromInt(0xFFF0F9FF),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              font: fontBold,
              fontSize: 14,
              color: _primaryColor,
            ),
          ),
          pw.Text(
            subtitle,
            style: pw.TextStyle(
              font: font,
              fontSize: 10,
              color: _textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPatientsTable(
    List<PatientModel> patients,
    pw.Font font,
    pw.Font fontBold,
  ) {
    return pw.Table(
      border: pw.TableBorder.all(color: _borderColor),
      columnWidths: {
        0: const pw.FlexColumnWidth(0.8),
        1: const pw.FlexColumnWidth(2),
        2: const pw.FlexColumnWidth(3),
        3: const pw.FlexColumnWidth(1.5),
        4: const pw.FlexColumnWidth(1),
        5: const pw.FlexColumnWidth(2),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(
            color: PdfColor.fromInt(0xFFF3F4F6),
          ),
          children: [
            _buildTableCell('No', font, fontBold, isHeader: true),
            _buildTableCell('Patient Code', font, fontBold, isHeader: true),
            _buildTableCell('Name', font, fontBold, isHeader: true),
            _buildTableCell('Gender', font, fontBold, isHeader: true),
            _buildTableCell('Age', font, fontBold, isHeader: true),
            _buildTableCell('Registered', font, fontBold, isHeader: true),
          ],
        ),
        ...patients.asMap().entries.map((entry) {
          final i = entry.key;
          final p = entry.value;
          return pw.TableRow(
            children: [
              _buildTableCell('${i + 1}', font, fontBold),
              _buildTableCell(p.patientCode, font, fontBold),
              _buildTableCell(p.name, font, fontBold),
              _buildTableCell(p.gender, font, fontBold),
              _buildTableCell('${p.age}', font, fontBold),
              _buildTableCell(_dateFormat.format(p.createdAt), font, fontBold),
            ],
          );
        }),
      ],
    );
  }

  pw.Widget _buildDetectionSummaryStats(
    List<DetectionModel> detections,
    pw.Font font,
    pw.Font fontBold,
  ) {
    final noDR = detections.where((d) => d.classification == 0).length;
    final mild = detections.where((d) => d.classification == 1).length;
    final moderate = detections.where((d) => d.classification == 2).length;
    final severe = detections.where((d) => d.classification == 3).length;
    final proliferative = detections.where((d) => d.classification == 4).length;

    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: const PdfColor.fromInt(0xFFF0F9FF),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Total Detections: ${detections.length}',
            style: pw.TextStyle(
              font: fontBold,
              fontSize: 14,
              color: _primaryColor,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'No DR: $noDR  |  Mild: $mild  |  Moderate: $moderate  |  Severe: $severe  |  Proliferative: $proliferative',
            style: pw.TextStyle(
              font: font,
              fontSize: 10,
              color: _textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildFullDetectionTable(
    List<DetectionModel> detections,
    pw.Font font,
    pw.Font fontBold,
  ) {
    return pw.Table(
      border: pw.TableBorder.all(color: _borderColor),
      columnWidths: {
        0: const pw.FlexColumnWidth(0.6),
        1: const pw.FlexColumnWidth(1.5),
        2: const pw.FlexColumnWidth(2),
        3: const pw.FlexColumnWidth(1),
        4: const pw.FlexColumnWidth(2),
        5: const pw.FlexColumnWidth(1),
        6: const pw.FlexColumnWidth(1),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(
            color: PdfColor.fromInt(0xFFF3F4F6),
          ),
          children: [
            _buildTableCell('No', font, fontBold, isHeader: true),
            _buildTableCell('Date', font, fontBold, isHeader: true),
            _buildTableCell('Patient', font, fontBold, isHeader: true),
            _buildTableCell('Eye', font, fontBold, isHeader: true),
            _buildTableCell('Result', font, fontBold, isHeader: true),
            _buildTableCell('Conf.', font, fontBold, isHeader: true),
            _buildTableCell('Risk', font, fontBold, isHeader: true),
          ],
        ),
        ...detections.asMap().entries.map((entry) {
          final i = entry.key;
          final d = entry.value;
          return pw.TableRow(
            children: [
              _buildTableCell('${i + 1}', font, fontBold),
              _buildTableCell(_dateFormat.format(d.detectedAt), font, fontBold),
              _buildTableCell(d.patientName, font, fontBold),
              _buildTableCell(d.sideEye, font, fontBold),
              _buildTableCell(d.predictedLabel, font, fontBold),
              _buildTableCell(
                '${(d.confidence * 100).toStringAsFixed(0)}%',
                font,
                fontBold,
              ),
              _buildRiskCell(d.classification, font, fontBold),
            ],
          );
        }),
      ],
    );
  }

  pw.Widget _buildFullReportSummary(
    List<PatientModel> patients,
    List<DetectionModel> detections,
    int totalScans,
    pw.Font font,
    pw.Font fontBold,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _primaryColor),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            'SUMMARY',
            style: pw.TextStyle(
              font: fontBold,
              fontSize: 16,
              color: _primaryColor,
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatBox(
                'Total Patients',
                '${patients.length}',
                font,
                fontBold,
              ),
              _buildStatBox(
                'Total Detections',
                '${detections.length}',
                font,
                fontBold,
              ),
              _buildStatBox('Total Scans', '$totalScans', font, fontBold),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildStatBox(
    String label,
    String value,
    pw.Font font,
    pw.Font fontBold,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: const PdfColor.fromInt(0xFFF0F9FF),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            value,
            style: pw.TextStyle(
              font: fontBold,
              fontSize: 24,
              color: _primaryColor,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            label,
            style: pw.TextStyle(
              font: font,
              fontSize: 10,
              color: _textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildClassificationBreakdown(
    List<DetectionModel> detections,
    pw.Font font,
    pw.Font fontBold,
  ) {
    final classifications = [
      (
        'No DR',
        detections.where((d) => d.classification == 0).length,
        _successColor,
      ),
      (
        'Mild NPDR',
        detections.where((d) => d.classification == 1).length,
        _warningColor,
      ),
      (
        'Moderate NPDR',
        detections.where((d) => d.classification == 2).length,
        _warningDark,
      ),
      (
        'Severe NPDR',
        detections.where((d) => d.classification == 3).length,
        _dangerColor,
      ),
      (
        'Proliferative DR',
        detections.where((d) => d.classification == 4).length,
        _dangerDark,
      ),
    ];

    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _borderColor),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'CLASSIFICATION BREAKDOWN',
            style: pw.TextStyle(
              font: fontBold,
              fontSize: 12,
              color: _primaryColor,
            ),
          ),
          pw.SizedBox(height: 15),
          ...classifications.map(
            (c) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 8),
              child: pw.Row(
                children: [
                  pw.Container(
                    width: 12,
                    height: 12,
                    decoration: pw.BoxDecoration(
                      color: c.$3,
                      borderRadius: const pw.BorderRadius.all(
                        pw.Radius.circular(2),
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 10),
                  pw.Expanded(
                    child: pw.Text(
                      c.$1,
                      style: pw.TextStyle(
                        font: font,
                        fontSize: 10,
                        color: _textPrimary,
                      ),
                    ),
                  ),
                  pw.Text(
                    '${c.$2}',
                    style: pw.TextStyle(
                      font: fontBold,
                      fontSize: 10,
                      color: _textPrimary,
                    ),
                  ),
                  pw.SizedBox(width: 10),
                  pw.Text(
                    detections.isEmpty
                        ? '0%'
                        : '${((c.$2 / detections.length) * 100).toStringAsFixed(1)}%',
                    style: pw.TextStyle(
                      font: font,
                      fontSize: 10,
                      color: _textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // PRIVATE METHODS - FILE OPERATIONS
  // ============================================================================

  Future<void> _savePdf(pw.Document pdf, String fileName) async {
    try {
      // 1. Generate bytes
      final bytes = await pdf.save();

      // 2. Get temp directory (Aman tanpa permission storage di Android 10+)
      final dir = await getTemporaryDirectory();

      // 3. Create file path (bersihkan nama file dari karakter aneh)
      final cleanName = fileName.replaceAll(RegExp(r'[^\w\s]+'), '');
      final file = File('${dir.path}/$cleanName.pdf');

      // 4. Write data
      await file.writeAsBytes(bytes);

      debugPrint('✅ PDF Saved at: ${file.path}');

      // 5. Share using XFile (Standard Baru)
      final result = await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          subject: 'DR Detection Report',
          text: 'Here is the exported report.',
        ),
      );

      if (result.status == ShareResultStatus.dismissed) {
        debugPrint('ℹ️ User dismissed share dialog');
      }
    } catch (e) {
      debugPrint('❌ Error saving/sharing PDF: $e');
      throw Exception('Failed to generate PDF: $e');
    }
  }

  // UPDATE JUGA FUNGSI EXCEL (Pola yang sama)
  Future<void> _saveExcel(Excel excel, String fileName) async {
    final bytes = excel.encode();
    if (bytes == null) return;

    final dir = await getTemporaryDirectory();
    final timestamp = _fileNameFormat.format(DateTime.now());
    final file = File('${dir.path}/${fileName}_$timestamp.xlsx');

    await file.writeAsBytes(bytes);

    await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path)], subject: 'DR Detection Data'),
    );
  }

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  String _getRiskLevel(int classification) {
    switch (classification) {
      case 0:
        return 'Low';
      case 1:
      case 2:
        return 'Medium';
      case 3:
      case 4:
        return 'High';
      default:
        return 'Unknown';
    }
  }

  PdfColor _getClassificationColor(int classification) {
    switch (classification) {
      case 0:
        return _successColor;
      case 1:
        return _warningColor;
      case 2:
        return _warningDark;
      case 3:
        return _dangerColor;
      case 4:
        return _dangerDark;
      default:
        return _textSecondary;
    }
  }
}
