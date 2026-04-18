import 'dart:io';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:medisync_doctor/features/medical/domain/entities/patient_entity.dart';
import 'package:medisync_doctor/features/medical/domain/entities/prescription_entity.dart';
import 'package:medisync_doctor/features/auth_onboarding/domain/entities/clinic_entity.dart';
import 'package:medisync_doctor/features/auth_onboarding/domain/entities/medical_staff_entity.dart';

class PrescriptionPdfGenerator {
  static Future<void> generateAndExport({
    required PrescriptionEntity prescription,
    required PatientEntity patient,
    required ClinicEntity clinic,
    required MedicalStaffEntity doctor,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(clinic.clinicName.isNotEmpty ? clinic.clinicName : 'Clinic',
                          style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                      pw.Text(clinic.address.isNotEmpty ? clinic.address : '', style: const pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(doctor.name.isNotEmpty ? doctor.name : 'Doctor',
                          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                      pw.Text(doctor.specialistIn.isNotEmpty ? doctor.specialistIn : 'Medical Practitioner', style: const pw.TextStyle(fontSize: 10)),
                      pw.Text('ID: #${doctor.uniqueId}', style: const pw.TextStyle(fontSize: 9)),
                    ],
                  ),
                ],
              ),
              pw.Divider(thickness: 2, color: PdfColors.cyan),
              pw.SizedBox(height: 20),

              // Patient Details
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Patient: ${patient.name}',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text('Age/Sex: ${patient.age} / ${patient.gender}'),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Date: ${DateFormat('dd MMM yyyy').format(prescription.createdAt)}'),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 30),

              pw.Text('Rx', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),

              // Medicines Table
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Medicine Name', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Dosage', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Freq', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Dur', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    ],
                  ),
                  ...prescription.medicines.map((m) => pw.TableRow(
                        children: [
                          pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(m.name)),
                          pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(m.dosage)),
                          pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(m.frequency)),
                          pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(m.duration)),
                        ],
                      )),
                ],
              ),

              pw.Spacer(),

              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text('Generated by MediSync', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey)),
                  pw.Column(
                    children: [
                      pw.Container(width: 120, decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide()))),
                      pw.SizedBox(height: 4),
                      pw.Text('Authorized Signature', style: const pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    final pdfBytes = await pdf.save();

    // Export logic: Provides system choice (Share, Save to File, Print)
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/Prescription_${patient.name}_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf');
    await file.writeAsBytes(pdfBytes);

    await Share.shareXFiles([XFile(file.path)], text: 'Prescription for ${patient.name}');
  }
}
