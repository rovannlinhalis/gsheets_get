# gsheets_get

Flutter package to obtain data from a public Google sheets spreadsheet.
1-The spreadsheet must be published as a web page.
2-Enter the spreadsheet Id in GSheetsGet

pt-Br: Pacote flutter para obter dados de uma planilha pública do google sheets.
1-A planilha deve estar publicada como uma página da web.
2-Informe o Id da planilha no GSheetsGet

## Getting Started

>1-The spreadsheet must be published as a web page.
>2-Enter the spreadsheet Id in GSheetsGet

---
>1-A planilha deve estar publicada como uma página da web.
>2-Informe o Id da planilha no GSheetsGet
```
  final GSheetsGet sheet = GSheetsGet(
      sheetId: "1FeiUH1ZDUvlcrn_AnFqEW62YdSvoDntBSfHfVjihjQ4",
      page: 1,
      skipRows: 0);

  GSheetsResult result = await sheet.getSheet();
  if (result.sucess) {
    result.sheet.rows.forEach((row) {
      StringBuffer buffer = new StringBuffer();
      buffer.write("Row >");
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
```
