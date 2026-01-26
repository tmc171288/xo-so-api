import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  final url = 'https://az24.vn/xsmn-xo-so-mien-nam.html';
  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final body = utf8.decode(response.bodyBytes);
      var document = parser.parse(body);
      
      // MN/MT Debug
      // Usually class 'table-kq-bold-border' or similar?
      // Repository uses 'table.kqmb.extendable'?? Let's check all tables.
      var tables = document.querySelectorAll('table');
      print('Found ${tables.length} tables');
      
      for (var table in tables) {
         if (table.className.contains('kqmb') || table.className.contains('miennam') || table.className.contains('mientrung')) {
            print('--- Processing Table check ---');
            var rows = table.getElementsByTagName('tr');
            for (var i = 0; i < rows.length; i++) {
               var cells = rows[i].getElementsByTagName('td');
               if (cells.isNotEmpty) {
                  // Print first cell (Label) and count
                  print('Row $i: Label="${cells[0].text.trim()}", Cells=${cells.length}');
               }
            }
         }
      }
      
      // Also check Date finding for MN
      // ...
    }
  } catch (e) { print(e); }
}
