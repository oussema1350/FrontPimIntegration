import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/article.dart';
import 'package:url_launcher/url_launcher_string.dart';

class ArticleDetailScreen extends StatelessWidget {
  final Article article;

  ArticleDetailScreen({required this.article});

  // Function to launch the URL
  void _launchURL(String url) async {
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          article.title,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF004D40), Color(0xFF26A69A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (article.urlToImage != null)
              Container(
                width: double.infinity,
                height: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(
                    article.urlToImage!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: double.infinity,
                        height: 250,
                        color: Colors.grey[300],
                        child: Icon(Icons.image_not_supported, size: 50),
                      );
                    },
                  ),
                ),
              ),
            SizedBox(height: 20),
            Text(
              article.title,
              style: TextStyle(
                  fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            SizedBox(height: 10),
            Text(
              article.description,
              style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic, color: Colors.grey),
            ),
            SizedBox(height: 15),
            if (article.author != null)
              Text(
                "By ${article.author}",
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
            SizedBox(height: 8),
            Text(
              "Source: ",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            GestureDetector(
              onTap: () => _launchURL(article.url),
              child: Text(
                article.url,
                style: TextStyle(fontSize: 16, color: Colors.blue, decoration: TextDecoration.underline),
              ),
            ),
            SizedBox(height: 20),
            Text(
              article.content,
              style: TextStyle(fontSize: 18, height: 1.6, color: Colors.black87),
            ),
            SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: () => _launchURL(article.url),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                ),
                child: Text(
                  "Read Full Article",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}