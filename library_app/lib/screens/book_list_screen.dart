import 'package:flutter/material.dart';

import '../models/book.dart';
import '../services/book_service.dart';

class BookListScreen extends StatefulWidget {
  @override
  _BookListScreenState createState() => _BookListScreenState();
}

class _BookListScreenState extends State<BookListScreen> {
  final BookService bookService = BookService();
  late Future<List<Book>> futureBooks;

  @override
  void initState() {
    super.initState();
    futureBooks = bookService.getAllBooks();
  }

  void _deleteBook(Book book) async {
    setState(() {
      futureBooks = futureBooks.then((books) => books..removeWhere((b) => b.id == book.id));
    });

    try {
      await bookService.deleteBook(book.id!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${book.title} đã được xóa'),
          action: SnackBarAction(
            label: 'Hoàn tác',
            onPressed: () {
              _restoreBook(book);
            },
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể xóa sách: $e')),
      );
      setState(() {
        futureBooks = bookService.getAllBooks();
      });
    }
  }

  void _restoreBook(Book book) async {
    try {
      Book restoredBook = await bookService.restoreBook(book);
      setState(() {
        futureBooks = futureBooks.then((books) => books..add(restoredBook));
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${book.title} đã được khôi phục')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể khôi phục sách: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Library App'),
      ),
      body: FutureBuilder<List<Book>>(
        future: futureBooks,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(snapshot.data![index].title),
                  subtitle: Text(snapshot.data![index].author),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => _deleteBook(snapshot.data![index]),
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(child: Text("${snapshot.error}"));
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}