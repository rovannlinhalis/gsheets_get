library gsheets_get;

import 'dart:convert';
import 'dart:io';

class GoogleSheetsApi {
  final String sheetId;
  final int page;
  final int skipRows;

  GoogleSheetsApi({this.sheetId, this.page, this.skipRows});

  String get urlSheet =>
      "https://spreadsheets.google.com/feeds/cells/${sheetId}/${page}/public/full?alt=json";

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

  Future<GSheetsResult> getSheet() async {
    var result = await httpGet();

    if (result.sucess) {
      var r = json.decode(result.content);
      GoogleSheet sheet = GoogleSheet.fromJson(r);

      int countRows = int.parse(sheet.feed.gsRowCount.t);
      int countColumns = int.parse(sheet.feed.gsColCount.t);

      List<Row> lista = new List<Row>(countRows);

      sheet.feed.entry.forEach((element) {
        int row = int.parse(element.gsCell.row);
        int listIndex = row - skipRows - 1;
        if (row > skipRows) {
          //primeira linha, nome das colunas
          int column = int.parse(element.gsCell.col);
          // if (lista.length < (row - skipRows)) {
          //   lista.add(new Row(cells: new List<GsCell>(countColumns)));
          // }
          // while (lista[listIndex].cells.length < column-1)
          // {
          //   lista[listIndex].cells.add(GsCell());
          // }
          if (lista[listIndex] == null) {
            lista[listIndex] = new Row(cells: new List<GsCell>(countColumns));
          }

          lista[listIndex].cells[column - 1] = element.gsCell;
        }
      });

      return GSheetsResult(message: "sucess", rows: lista.where((element) => element != null).toList(), sucess: true);
    } else {
      return GSheetsResult(message: result.content, sucess: false);
    }
  }
}

class Row {
  final List<GsCell> cells;
  Row({this.cells});
}

class GSheetsResult {
  List<Row> rows;
  bool sucess;
  String message;
  GSheetsResult({this.rows, this.sucess, this.message});
}

class HTTPResponse {
  String content;
  bool sucess;
  int code;
  HTTPResponse({this.sucess, this.content, this.code});
}

/// A Calculator.
class GoogleSheet {
  String version;
  String encoding;
  Feed feed;

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

class Feed {
  String xmlns;
  String xmlnsOpenSearch;
  String xmlnsBatch;
  String xmlnsGs;
  Id id;
  Id updated;
  List<Category> category;
  Title title;
  List<Link> link;
  List<Author> author;
  Id openSearchTotalResults;
  Id openSearchStartIndex;
  Id gsRowCount;
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

class Id {
  String t;

  Id({this.t});

  Id.fromJson(Map<String, dynamic> json) {
    t = json['\$t'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['\$t'] = this.t;
    return data;
  }
}

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

class Title {
  String type;
  String t;

  Title({this.type, this.t});

  Title.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    t = json['\$t'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['\$t'] = this.t;
    return data;
  }
}

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

class GsCell {
  String row;
  String col;
  String inputValue;
  String t;
  String numericValue;

  GsCell({this.row, this.col, this.inputValue, this.t, this.numericValue});

  GsCell.fromJson(Map<String, dynamic> json) {
    row = json['row'];
    col = json['col'];
    inputValue = json['inputValue'];
    t = json['\$t'];
    numericValue = json['numericValue'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['row'] = this.row;
    data['col'] = this.col;
    data['inputValue'] = this.inputValue;
    data['\$t'] = this.t;
    data['numericValue'] = this.numericValue;
    return data;
  }
}
