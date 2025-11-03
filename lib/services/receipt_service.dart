import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import '../models/transaction.dart';
import '../models/receipt_template.dart';
import 'receipt_template_service.dart';

class ReceiptService {
  static Future<void> printReceipt(Transaction transaction) async {
    try {
      // Ambil template dari service
      final template = await ReceiptTemplateService.getTemplate();
      
      // Generate PDF
      final pdf = await _generatePDF(transaction, template);
      
      // Print menggunakan printing package
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
  ) async {
    final pdf = pw.Document();
    final format = NumberFormat('#,###');

    // Format struk 80mm untuk thermal printer
    const width = 80.0 * (72.0 / 25.4); // 80mm dalam points
    const height = 297.0 * (72.0 / 25.4); // 297mm (A4 height) dalam points
    final pageFormat = PdfPageFormat(width, height);

    pdf.addPage(
      pw.Page(
        pageFormat: pageFormat,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              // Header - Nama Toko
              pw.Text(
                template.storeName,
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
                textAlign: pw.TextAlign.center,
              ),
              pw.SizedBox(height: 4),
              
              // Deskripsi
              if (template.description.isNotEmpty)
                pw.Text(
                  template.description,
                  style: const pw.TextStyle(fontSize: 10),
                  textAlign: pw.TextAlign.center,
                ),
              
              // Alamat
              if (template.address.isNotEmpty)
                pw.Text(
                  template.address,
                  style: const pw.TextStyle(fontSize: 9),
                  textAlign: pw.TextAlign.center,
                ),
              
              // Telepon
              if (template.phone.isNotEmpty)
                pw.Text(
                  template.phone,
                  style: const pw.TextStyle(fontSize: 9),
                  textAlign: pw.TextAlign.center,
                ),
              
              pw.Divider(),
              pw.SizedBox(height: 8),
              
              // Informasi Transaksi
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Tanggal: ',
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                  pw.Text(
                    DateFormat('dd/MM/yyyy HH:mm').format(transaction.date),
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                ],
              ),
              pw.SizedBox(height: 4),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Invoice: ',
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                  pw.Text(
                    '#${transaction.id.substring(transaction.id.length - 8)}',
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                ],
              ),
              
              pw.Divider(),
              pw.SizedBox(height: 8),
              
              // Header Tabel Item
              pw.Row(
                children: [
                  pw.Expanded(
                    flex: 2,
                    child: pw.Text(
                      'Item',
                      style: pw.TextStyle(
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                  pw.Expanded(
                    flex: 1,
                    child: pw.Text(
                      'Qty',
                      style: pw.TextStyle(
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                      ),
                      textAlign: pw.TextAlign.right,
                    ),
                  ),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Text(
                      'Harga',
                      style: pw.TextStyle(
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                      ),
                      textAlign: pw.TextAlign.right,
                    ),
                  ),
                ],
              ),
              
              pw.Divider(thickness: 0.5),
              
              // List Item
              ...transaction.items.map((item) => pw.Column(
                    children: [
                      pw.Row(
                        children: [
                          pw.Expanded(
                            flex: 2,
                            child: pw.Text(
                              item.productName,
                              style: const pw.TextStyle(fontSize: 9),
                            ),
                          ),
                          pw.Expanded(
                            flex: 1,
                            child: pw.Text(
                              '${item.quantity}',
                              style: const pw.TextStyle(fontSize: 9),
                              textAlign: pw.TextAlign.right,
                            ),
                          ),
                          pw.Expanded(
                            flex: 2,
                            child: pw.Text(
                              format.format(item.price),
                              style: const pw.TextStyle(fontSize: 9),
                              textAlign: pw.TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 2),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.end,
                        children: [
                          pw.Text(
                            'Subtotal: ${format.format(item.subtotal)}',
                            style: const pw.TextStyle(fontSize: 8),
                          ),
                        ],
                      ),
                      pw.Divider(thickness: 0.3),
                    ],
                  )),
              
              pw.SizedBox(height: 8),
              
              // Total
              pw.Container(
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'TOTAL:',
                      style: pw.TextStyle(
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      format.format(transaction.totalPrice),
                      style: pw.TextStyle(
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              
              pw.SizedBox(height: 16),
              
              // Footer
              if (template.footer1.isNotEmpty)
                pw.Text(
                  template.footer1,
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
              if (template.footer2.isNotEmpty)
                pw.Text(
                  template.footer2,
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
              
              pw.SizedBox(height: 16),
              
              pw.Text(
                'Terima Kasih Atas Kunjungan Anda',
                style: const pw.TextStyle(fontSize: 9),
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

