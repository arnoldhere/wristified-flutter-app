import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'csv_exporter.dart';

class CsvExporterImpl implements CsvExporter {
  @override
  Future<void> export(String csvData) async {
    final dir = await getTemporaryDirectory();
    final path = "${dir.path}/users.csv";
    final file = File(path);
    await file.writeAsString(csvData);
    await Share.shareXFiles([XFile(file.path)], text: "Exported Users Data");
  }
}
