import 'package:hive/hive.dart';

@HiveType(typeId: 0)
class NewsArticle {
  @HiveField(0)
  final String? id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String? description;

  @HiveField(3)
  final String? content;

  @HiveField(4)
  final String? imageUrl;

  @HiveField(5)
  final String? sourceName;

  @HiveField(6)
  final String? sourceUrl;

  @HiveField(7)
  final DateTime publishedAt;

  @HiveField(8)
  final String? author;

  @HiveField(9)
  final String category;

  @HiveField(10)
  final String? url;

  NewsArticle({
    this.id,
    required this.title,
    this.description,
    this.content,
    this.imageUrl,
    this.sourceName,
    this.sourceUrl,
    required this.publishedAt,
    this.author,
    required this.category,
    this.url,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    final source = json['source'] as Map<String, dynamic>?;
    return NewsArticle(
      id: source?['id'] ?? json['url'],
      title: json['title'] ?? 'No Title',
      description: json['description'],
      content: json['content'],
      imageUrl: json['urlToImage'] ?? json['image'],
      sourceName: json['source']?['name'] ?? json['source'],
      sourceUrl: json['source']?['url'],
      publishedAt: json['publishedAt'] != null ? DateTime.parse(json['publishedAt']) : DateTime.now(),
      author: json['author'],
      category: json['category'] ?? 'general',
      url: json['url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'content': content,
      'urlToImage': imageUrl,
      'source': {
        'name': sourceName,
        'url': sourceUrl
      },
      'publishedAt': publishedAt.toIso8601String(),
      'author': author,
      'category': category,
      'url': url,
    };
  }

  @override
  bool operator ==(Object other) => identical(this, other) || other is NewsArticle && runtimeType == other.runtimeType && (id == other.id || url == other.url);

  @override
  int get hashCode => id.hashCode ^ url.hashCode;
}

// This will be generated with hive_generator
class NewsArticleAdapter extends TypeAdapter<NewsArticle> {
  @override
  final int typeId = 0;

  @override
  NewsArticle read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return NewsArticle(
      id: fields[0] as String?,
      title: fields[1] as String,
      description: fields[2] as String?,
      content: fields[3] as String?,
      imageUrl: fields[4] as String?,
      sourceName: fields[5] as String?,
      sourceUrl: fields[6] as String?,
      publishedAt: fields[7] as DateTime,
      author: fields[8] as String?,
      category: fields[9] as String,
      url: fields[10] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, NewsArticle obj) {
    writer.writeByte(11);
    writer.writeByte(0);
    writer.write(obj.id);
    writer.writeByte(1);
    writer.write(obj.title);
    writer.writeByte(2);
    writer.write(obj.description);
    writer.writeByte(3);
    writer.write(obj.content);
    writer.writeByte(4);
    writer.write(obj.imageUrl);
    writer.writeByte(5);
    writer.write(obj.sourceName);
    writer.writeByte(6);
    writer.write(obj.sourceUrl);
    writer.writeByte(7);
    writer.write(obj.publishedAt);
    writer.writeByte(8);
    writer.write(obj.author);
    writer.writeByte(9);
    writer.write(obj.category);
    writer.writeByte(10);
    writer.write(obj.url);
  }
}
