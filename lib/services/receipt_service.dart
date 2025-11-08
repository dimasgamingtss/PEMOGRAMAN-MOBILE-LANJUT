import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import '../models/transaction.dart';
import '../models/receipt_template.dart';
import 'receipt_template_service.dart';

class ReceiptService {
  // Enum jenis printer
  static const String printerType58mm = '58mm';
  static const String printerType80mm = '80mm';
  static const String printerTypeA4 = 'A4';

  /// Print receipt sesuai tipe printer
  static Future<void> printReceipt(
    Transaction transaction, {
    String printerType = printerType58mm,
  }) async {
    try {
      // Ambil template struk
      final template = await ReceiptTemplateService.getTemplate();

      // Generate PDF sesuai jenis printer
      final pdf = await _generatePDF(transaction, template, printerType);

      // Cetak atau simpan PDF
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf,
      );
    } catch (e) {
      throw Exception('Gagal mencetak struk: $e');
    }
  }

  static Future<Uint8List> _generatePDF(
    Transaction transaction,
    ReceiptTemplate template,
    String printerType,
  ) async {
    final pdf = pw.Document();
    final format = NumberFormat('#,###');

    // Tentukan ukuran halaman
    PdfPageFormat pageFormat;

    switch (printerType) {
      case printerType58mm:
        // Kertas 58mm, area cetak efektif 48mm
        pageFormat = PdfPageFormat(
          58 * PdfPageFormat.mm,
          double.infinity,
          marginAll: 1.5 * PdfPageFormat.mm,
        );
        break;
      case printerType80mm:
        // Kertas 80mm, area cetak efektif 72mm
        pageFormat = PdfPageFormat(
          80 * PdfPageFormat.mm,
          double.infinity,
          marginAll: 2 * PdfPageFormat.mm,
        );
        break;
      case printerTypeA4:
        // Printer biasa (A4)
        pageFormat = PdfPageFormat.a4.copyWith(
          marginLeft: 20,
          marginRight: 20,
          marginTop: 20,
          marginBottom: 20,
        );
        break;
      default:
        pageFormat = PdfPageFormat(
          58 * PdfPageFormat.mm,
          double.infinity,
          marginAll: 2 * PdfPageFormat.mm,
        );
    }

    pdf.addPage(
      pw.Page(
        pageFormat: pageFormat,
        build: (pw.Context context) {
          final bool isA4 = printerType == printerTypeA4;
          final double headerFontSize = isA4 ? 18 : 12;
          final double bodyFontSize = isA4 ? 11 : 8;
          final double smallFontSize = isA4 ? 9 : 6.5;
          final double titleFontSize = isA4 ? 13 : 9.5;

          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              // Header toko
              pw.Text(
                template.storeName,
                style: pw.TextStyle(
                  fontSize: headerFontSize,
                  fontWeight: pw.FontWeight.bold,
                ),
                textAlign: pw.TextAlign.center,
              ),
              if (template.description.isNotEmpty)
                pw.Text(
                  template.description,
                  style: pw.TextStyle(fontSize: smallFontSize),
                  textAlign: pw.TextAlign.center,
                ),
              if (template.address.isNotEmpty)
                pw.Text(
                  template.address,
                  style: pw.TextStyle(fontSize: smallFontSize),
                  textAlign: pw.TextAlign.center,
                ),
              if (template.phone.isNotEmpty)
                pw.Text(
                  template.phone,
                  style: pw.TextStyle(fontSize: smallFontSize),
                  textAlign: pw.TextAlign.center,
                ),

              pw.SizedBox(height: 4),
              pw.Divider(thickness: 0.5),
              pw.SizedBox(height: 3),

              // Info transaksi
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Tanggal:', style: pw.TextStyle(fontSize: bodyFontSize)),
                  pw.Text(
                    DateFormat('dd/MM/yyyy HH:mm').format(transaction.date),
                    style: pw.TextStyle(fontSize: bodyFontSize),
                  ),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Invoice:', style: pw.TextStyle(fontSize: bodyFontSize)),
                  pw.Text(
                    '#${transaction.id.substring(transaction.id.length - 8)}',
                    style: pw.TextStyle(fontSize: bodyFontSize),
                  ),
                ],
              ),
              pw.SizedBox(height: 4),
              pw.Divider(thickness: 0.5),
              pw.SizedBox(height: 3),

              // Header item
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Expanded(
                    flex: 3,
                    child: pw.Text('Item', style: pw.TextStyle(fontSize: bodyFontSize, fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.SizedBox(width: 6),
                  pw.Text('Qty', style: pw.TextStyle(fontSize: bodyFontSize, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(width: 10),
                  pw.Text('Harga', style: pw.TextStyle(fontSize: bodyFontSize, fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.Divider(thickness: 0.5),

              // Daftar item
              ...transaction.items.map((item) => pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Expanded(
                            flex: 3,
                            child: pw.Text(
                              item.productName,
                              style: pw.TextStyle(fontSize: bodyFontSize),
                              maxLines: 2,
                            ),
                          ),
                          pw.SizedBox(width: 6),
                          pw.Text('${item.quantity}', style: pw.TextStyle(fontSize: bodyFontSize)),
                          pw.SizedBox(width: 10),
                          pw.Text(format.format(item.price), style: pw.TextStyle(fontSize: bodyFontSize)),
                        ],
                      ),
                      pw.Align(
                        alignment: pw.Alignment.centerRight,
                        child: pw.Text(
                          'Subtotal: ${format.format(item.subtotal)}',
                          style: pw.TextStyle(fontSize: smallFontSize),
                        ),
                      ),
                      pw.Divider(thickness: 0.3),
                    ],
                  )),

              pw.SizedBox(height: 4),
              pw.Divider(thickness: 0.8),
              pw.SizedBox(height: 4),

              // Total
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('TOTAL:', style: pw.TextStyle(fontSize: titleFontSize, fontWeight: pw.FontWeight.bold)),
                  pw.Text(format.format(transaction.totalPrice),
                      style: pw.TextStyle(fontSize: titleFontSize, fontWeight: pw.FontWeight.bold)),
                ],
              ),

              pw.SizedBox(height: 10),
              pw.Divider(thickness: 0.5),

              // Footer
              if (template.footer1.isNotEmpty)
                pw.Text(
                  template.footer1,
                  style: pw.TextStyle(fontSize: smallFontSize, fontWeight: pw.FontWeight.bold),
                  textAlign: pw.TextAlign.center,
                ),
              if (template.footer2.isNotEmpty)
                pw.Text(
                  template.footer2,
                  style: pw.TextStyle(fontSize: smallFontSize),
                  textAlign: pw.TextAlign.center,
                ),
              pw.SizedBox(height: 6),
              pw.Text(
                'Terima Kasih Atas Kunjungan Anda',
                style: pw.TextStyle(fontSize: smallFontSize),
                textAlign: pw.TextAlign.center,
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }
}
