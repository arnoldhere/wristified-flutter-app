import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

// Conditional import
import 'csv_exporter_web.dart'
if (dart.library.io) 'csv_exporter_io.dart';

abstract class CsvExporter {
  Future<void> export(String csvData);
}
