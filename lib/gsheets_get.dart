library gsheets_get;

import 'dart:convert';
import 'dart:io';

///GSheetsGet is a service class to retrieve an Google sheet.
class GSheetsGet {
  final String sheetId;
  final int page;
  final int skipRows;

  GSheetsGet({this.sheetId, this.page, this.skipRows});

  ///return final url of sheet, with id and page
  String get urlSheet =>
      "https://spreadsheets.google.com/feeds/cells/$sheetId/$page/public/full?alt=json";

  ///execute httpget method
  Future<HTTPResponse> httpGet() async {
    HttpClient httpClient = new HttpClient();
    httpClient..badCertificateCallback = (cert, host, port) => true;
    HttpClientRequest request = await httpClient.getUrl(Uri.parse(urlSheet));
    request.headers.set('content-type', 'application/json; charset=UTF-8');
    HttpClientResponse response = await request.close();
    String jsonResponse = await response.transform(utf8.decoder).join();
    httpClient.close();
    return HTTPResponse(
        sucess: response.statusCode >= 200 && response.statusCode < 300,
        content: jsonResponse,
        code: response.statusCode);
  }

  ///return a GSheetsResult. Check if sucess before get value of sheet object
  Future<GSheetsResult> getSheet() async {
    var result = await httpGet();

    //check if result is sucess
    if (result.sucess) {
      var r = json.decode(result.content);
      GoogleSheet sheet = GoogleSheet.fromJson(r);

      int countRows = int.parse(sheet.feed.gsRowCount.text);
      int countColumns = int.parse(sheet.feed.gsColCount.text);

      List<Row> lista = new List<Row>(countRows);

      sheet.feed.entry.forEach((element) {
        int row = int.parse(element.gsCell.row);
        int listIndex = row - skipRows - 1;
        if (row > skipRows) {
          int column = int.parse(element.gsCell.col);
          if (lista[listIndex] == null) {
            lista[listIndex] = new Row(cells: new List<GsCell>(countColumns));
          }
          lista[listIndex].cells[column - 1] = element.gsCell;
        }
      });

      sheet.rows = lista.where((element) => element != null).toList();

      return GSheetsResult(message: "sucess", sheet: sheet, sucess: true);
    } else {
      return GSheetsResult(message: result.content, sucess: false);
    }
  }
}

///Each row of sheet
class Row {
  ///Collection of cell for each row
  final List<GsCell> cells;
  Row({this.cells});
}

///Object with result of method get
class GSheetsResult {
  ///Google sheet object
  GoogleSheet sheet;

  ///if true, get value of sheet, else get message
  bool sucess;

  ///message when fails
  String message;
  GSheetsResult({this.sheet, this.sucess, this.message});
}

///Http result
class HTTPResponse {
  ///content of response
  String content;

  ///if http code between 200 and 299
  bool sucess;

  ///http code
  int code;
  HTTPResponse({this.sucess, this.content, this.code});
}

///Sheet model
class GoogleSheet {
  ///version of sheet
  String version;

  ///encoding
  String encoding;

  ///feed of sheet
  Feed feed;

  ///rows of sheet
  List<Row> rows;

  GoogleSheet({this.version, this.encoding, this.feed});

  GoogleSheet.fromJson(Map<String, dynamic> json) {
    version = json['version'];
    encoding = json['encoding'];
    feed = json['feed'] != null ? new Feed.fromJson(json['feed']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['version'] = this.version;
    data['encoding'] = this.encoding;
    if (this.feed != null) {
      data['feed'] = this.feed.toJson();
    }
    return data;
  }
}

///Feed of Sheet
class Feed {
  ///xml namespace
  String xmlns;
  String xmlnsOpenSearch;
  String xmlnsBatch;
  String xmlnsGs;
  Id id;
  Id updated;

  ///categories
  List<Category> category;

  ///title of sheet
  Title title;

  ///links of sheet
  List<Link> link;

  ///Authors of sheet
  List<Author> author;
  Id openSearchTotalResults;
  Id openSearchStartIndex;

  ///total rows of sheet
  Id gsRowCount;

  ///total columns of sheet
  Id gsColCount;

  List<Entry> entry;

  Feed(
      {this.xmlns,
      this.xmlnsOpenSearch,
      this.xmlnsBatch,
      this.xmlnsGs,
      this.id,
      this.updated,
      this.category,
      this.title,
      this.link,
      this.author,
      this.openSearchTotalResults,
      this.openSearchStartIndex,
      this.gsRowCount,
      this.gsColCount,
      this.entry});

  Feed.fromJson(Map<String, dynamic> json) {
    xmlns = json['xmlns'];
    xmlnsOpenSearch = json['xmlns\$openSearch'];
    xmlnsBatch = json['xmlns\$batch'];
    xmlnsGs = json['xmlns\$gs'];
    id = json['id'] != null ? new Id.fromJson(json['id']) : null;
    updated = json['updated'] != null ? new Id.fromJson(json['updated']) : null;
    if (json['category'] != null) {
      category = new List<Category>();
      json['category'].forEach((v) {
        category.add(new Category.fromJson(v));
      });
    }
    title = json['title'] != null ? new Title.fromJson(json['title']) : null;
    if (json['link'] != null) {
      link = new List<Link>();
      json['link'].forEach((v) {
        link.add(new Link.fromJson(v));
      });
    }
    if (json['author'] != null) {
      author = new List<Author>();
      json['author'].forEach((v) {
        author.add(new Author.fromJson(v));
      });
    }
    openSearchTotalResults = json['openSearch\$totalResults'] != null
        ? new Id.fromJson(json['openSearch\$totalResults'])
        : null;
    openSearchStartIndex = json['openSearch\$startIndex'] != null
        ? new Id.fromJson(json['openSearch\$startIndex'])
        : null;
    gsRowCount = json['gs\$rowCount'] != null
        ? new Id.fromJson(json['gs\$rowCount'])
        : null;
    gsColCount = json['gs\$colCount'] != null
        ? new Id.fromJson(json['gs\$colCount'])
        : null;
    if (json['entry'] != null) {
      entry = new List<Entry>();
      json['entry'].forEach((v) {
        entry.add(new Entry.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['xmlns'] = this.xmlns;
    data['xmlns\$openSearch'] = this.xmlnsOpenSearch;
    data['xmlns\$batch'] = this.xmlnsBatch;
    data['xmlns\$gs'] = this.xmlnsGs;
    if (this.id != null) {
      data['id'] = this.id.toJson();
    }
    if (this.updated != null) {
      data['updated'] = this.updated.toJson();
    }
    if (this.category != null) {
      data['category'] = this.category.map((v) => v.toJson()).toList();
    }
    if (this.title != null) {
      data['title'] = this.title.toJson();
    }
    if (this.link != null) {
      data['link'] = this.link.map((v) => v.toJson()).toList();
    }
    if (this.author != null) {
      data['author'] = this.author.map((v) => v.toJson()).toList();
    }
    if (this.openSearchTotalResults != null) {
      data['openSearch\$totalResults'] = this.openSearchTotalResults.toJson();
    }
    if (this.openSearchStartIndex != null) {
      data['openSearch\$startIndex'] = this.openSearchStartIndex.toJson();
    }
    if (this.gsRowCount != null) {
      data['gs\$rowCount'] = this.gsRowCount.toJson();
    }
    if (this.gsColCount != null) {
      data['gs\$colCount'] = this.gsColCount.toJson();
    }
    if (this.entry != null) {
      data['entry'] = this.entry.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

///Id type
class Id {
  String text;

  Id({this.text});

  Id.fromJson(Map<String, dynamic> json) {
    text = json['\$t'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['\$t'] = this.text;
    return data;
  }
}

///Category type
class Category {
  String scheme;
  String term;

  Category({this.scheme, this.term});

  Category.fromJson(Map<String, dynamic> json) {
    scheme = json['scheme'];
    term = json['term'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['scheme'] = this.scheme;
    data['term'] = this.term;
    return data;
  }
}

///Title type
class Title {
  String type;
  String text;

  Title({this.type, this.text});

  Title.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    text = json['\$t'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['\$t'] = this.text;
    return data;
  }
}

///Link type
class Link {
  String rel;
  String type;
  String href;

  Link({this.rel, this.type, this.href});

  Link.fromJson(Map<String, dynamic> json) {
    rel = json['rel'];
    type = json['type'];
    href = json['href'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['rel'] = this.rel;
    data['type'] = this.type;
    data['href'] = this.href;
    return data;
  }
}

///Author type
class Author {
  Id name;
  Id email;

  Author({this.name, this.email});

  Author.fromJson(Map<String, dynamic> json) {
    name = json['name'] != null ? new Id.fromJson(json['name']) : null;
    email = json['email'] != null ? new Id.fromJson(json['email']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.name != null) {
      data['name'] = this.name.toJson();
    }
    if (this.email != null) {
      data['email'] = this.email.toJson();
    }
    return data;
  }
}

///Entry type
class Entry {
  Id id;
  Id updated;
  List<Category> category;
  Title title;
  Title content;
  List<Link> link;
  GsCell gsCell;

  Entry(
      {this.id,
      this.updated,
      this.category,
      this.title,
      this.content,
      this.link,
      this.gsCell});

  Entry.fromJson(Map<String, dynamic> json) {
    id = json['id'] != null ? new Id.fromJson(json['id']) : null;
    updated = json['updated'] != null ? new Id.fromJson(json['updated']) : null;
    if (json['category'] != null) {
      category = new List<Category>();
      json['category'].forEach((v) {
        category.add(new Category.fromJson(v));
      });
    }
    title = json['title'] != null ? new Title.fromJson(json['title']) : null;
    content =
        json['content'] != null ? new Title.fromJson(json['content']) : null;
    if (json['link'] != null) {
      link = new List<Link>();
      json['link'].forEach((v) {
        link.add(new Link.fromJson(v));
      });
    }
    gsCell =
        json['gs\$cell'] != null ? new GsCell.fromJson(json['gs\$cell']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.id != null) {
      data['id'] = this.id.toJson();
    }
    if (this.updated != null) {
      data['updated'] = this.updated.toJson();
    }
    if (this.category != null) {
      data['category'] = this.category.map((v) => v.toJson()).toList();
    }
    if (this.title != null) {
      data['title'] = this.title.toJson();
    }
    if (this.content != null) {
      data['content'] = this.content.toJson();
    }
    if (this.link != null) {
      data['link'] = this.link.map((v) => v.toJson()).toList();
    }
    if (this.gsCell != null) {
      data['gs\$cell'] = this.gsCell.toJson();
    }
    return data;
  }
}

///Each cell of sheet, GsCell type
class GsCell {
  ///number of row
  String row;

  ///number of column
  String col;

  ///input value of cell, example "=1+1"
  String inputValue;

  ///text of cell, example "2"
  String text;

  ///numeric value of cell, example 2
  String numericValue;

  GsCell({this.row, this.col, this.inputValue, this.text, this.numericValue});

  GsCell.fromJson(Map<String, dynamic> json) {
    row = json['row'];
    col = json['col'];
    inputValue = json['inputValue'];
    text = json['\$t'];
    numericValue = json['numericValue'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['row'] = this.row;
    data['col'] = this.col;
    data['inputValue'] = this.inputValue;
    data['\$t'] = this.text;
    data['numericValue'] = this.numericValue;
    return data;
  }
}
