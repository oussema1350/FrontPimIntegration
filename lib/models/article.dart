class Article {
  final String title;
  final String description;
  final String url;
  final String content;
  final String? author;
  final String? urlToImage;
  final DateTime publishedAt;

  Article({
    required this.title,
    required this.description,
    required this.url,
    required this.content,
    this.author,
    this.urlToImage,
    required this.publishedAt,
  });

  // Factory method to create an Article from JSON
  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      title: json['title'] ?? 'No Title',
      description: json['description'] ?? 'No Description',
      url: json['url'],
      content: json['content'] ?? 'No Content Available',
      author: json['author'] ?? 'Unknown Author',
      urlToImage: json['urlToImage'] ?? 'https://via.placeholder.com/150',
      publishedAt: DateTime.parse(json['publishedAt']),
    );
  }
}
