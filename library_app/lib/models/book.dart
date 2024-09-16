class Book {
  final int? id;
  final String title;
  final String author;
  final String? isbn;
  final String? imageUrl;

  Book({this.id, required this.title, required this.author, this.isbn, this.imageUrl,});

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'],
      title: json['title'],
      author: json['author'],
      isbn: json['isbn'],
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'isbn': isbn,
      'imageUrl': imageUrl,
    };
  }
}