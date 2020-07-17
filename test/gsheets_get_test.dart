import 'package:flutter_test/flutter_test.dart';
import 'package:gsheets_get/gsheets_get.dart';

void main() {

final GoogleSheetsApi sheet =
        GoogleSheetsApi(sheetId: "18vGdHBzCs_qmUDjaxxS2voljmJ5F45buq1-cI-0rA64", page: 1, skipRows: 1);

  test('adds one to input values', () async {
    GSheetsResult result = await sheet.getSheet();

     result.rows.forEach((row) {
        StringBuffer buffer = new StringBuffer();
        buffer.write(">");
        row.cells.forEach((cell) { 
          buffer.write(cell.toString() + "|");
        });
       print(buffer.toString());
    });


    expect(result.sucess , true );
    expect(result.rows.length, 2 );

   

    
  });
}
