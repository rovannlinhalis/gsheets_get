import 'package:flutter_test/flutter_test.dart';
import 'package:gsheets_get/gsheets_get.dart';

void main() async {
  final GSheetsGet sheet = GSheetsGet(
      sheetId: "1FeiUH1ZDUvlcrn_AnFqEW62YdSvoDntBSfHfVjihjQ4",
      page: 1,
      skipRows: 0);

  GSheetsResult result = await sheet.getSheet();
  if (result.sucess) {
    result.sheet.rows.forEach((row) {
      StringBuffer buffer = new StringBuffer();
      buffer.write(">");
      if (row != null) {
        row.cells.forEach((cell) {
          buffer.write(cell?.text.toString() + "|");
        });
      }
      print(buffer.toString());
    });
  } else {
    print(result.message);
  }

  test('Print Sheet', () async {
    GSheetsResult result = await sheet.getSheet();

    result.sheet.rows.forEach((row) {
      StringBuffer buffer = new StringBuffer();
      buffer.write(">");
      if (row != null) {
        row.cells.forEach((cell) {
          buffer.write(cell?.text.toString() + "|");
        });
      }
      print(buffer.toString());
    });

    expect(result.sucess, true);
    expect(result.sheet.rows.length, 2);
  });
}
