import 'package:flutter/material.dart';
import 'package:library_app/models/book.dart';
import 'package:library_app/services/auth_service.dart';
import 'package:library_app/services/book_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  final BookService _bookService = BookService();
  List<Book> _books = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final books = await _bookService.getAllBooks();
      setState(() {
        _books = books;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading books: $e');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load books. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadBooks,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[900],
              image: DecorationImage(
                image: AssetImage('assets/images.jpg'),
                fit: BoxFit.cover,
                opacity: 0.1,
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    SizedBox(height: 40),
                    _buildFeatures(),
                    SizedBox(height: 40),
                    _buildStartReadingButton(),
                    SizedBox(height: 20),
                    _buildFeaturedBooksSection(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Library\nCompanion',
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Your reading buddy',
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey[300],
          ),
        ),
      ],
    );
  }

  Widget _buildFeatures() {
    return Column(
      children: [
        _buildFeatureItem(Colors.pink[400]!, 'Read stories'),
        SizedBox(height: 16),
        _buildFeatureItem(Colors.purple[400]!, 'Track your progress'),
        SizedBox(height: 16),
        _buildFeatureItem(Colors.blue[400]!, 'Get recommendations'),
      ],
    );
  }

  Widget _buildFeatureItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 16),
        Text(
          text,
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildStartReadingButton() {
    return ElevatedButton(
      onPressed: () {
      },
      child: Text(
        'Start Reading',
        style: TextStyle(fontSize: 18),
      ),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white, backgroundColor: Colors.pink[500],
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    );
  }

  Widget _buildFeaturedBooksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Featured Books',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 16),
        _isLoading
            ? Center(child: CircularProgressIndicator())
            : _books.isEmpty
                ? Center(
                    child: Text(
                      'No books available',
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                : GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.7,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                    ),
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: _books.length,
                    itemBuilder: (context, index) {
                      return _buildBookItem(_books[index]);
                    },
                  ),
      ],
    );
  }

  Widget _buildBookItem(Book book) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: Colors.grey[800],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.asset(
              'assets/images.jpg',
              width: double.infinity,
              height: 120,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  book.author,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}