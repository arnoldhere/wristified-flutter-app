// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'csv_exporter.dart';

class CsvExporterImpl implements CsvExporter {
  @override
  Future<void> export(String csvData) async {
    final bytes = csvData.codeUnits;
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute("download", "users.csv")
      ..click();
    html.Url.revokeObjectUrl(url);
  }
}
