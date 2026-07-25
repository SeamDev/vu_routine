import 'package:http/http.dart' as http;
import 'package:csv/csv.dart';

class GoogleSheetCsv {
  final String csvUrl;

  GoogleSheetCsv(this.csvUrl);

  /// Fetches the CSV text
  Future<String> _downloadCsv() async {
    final response = await http.get(Uri.parse(csvUrl));
    if (response.statusCode == 200) {
      return response.body;
    }
    throw Exception('Failed to load CSV: ${response.statusCode}');
  }


  Future<List<List<dynamic>>> fetchAndParse() async {
    final csvString = await _downloadCsv();
    return const CsvToListConverter().convert(csvString);
  }
}
