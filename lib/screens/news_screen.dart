import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/news_viewmodel.dart';
import '../models/article.dart';
import 'article_detail_screen.dart';

class NewsScreen extends StatefulWidget {
  @override
  _NewsScreenState createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  String _searchQuery = '';
  
  @override
  void initState() {
    super.initState();
    // Load articles when the screen is first initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NewsViewModel>(context, listen: false).loadArticles();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Check if NewsViewModel is accessible through Provider
    // If not, this will throw an error that will be caught in our error handling block
    final newsViewModel = Provider.of<NewsViewModel>(context);
    
    // Create a filtered list of articles based on search query
    List<Article> filteredArticles = newsViewModel.articles
        .where((article) => article.title.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Medical News', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF004D40), Color(0xFF26A69A)], // Teal gradient
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: newsViewModel.isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Search articles...',
                      prefixIcon: Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                  SizedBox(height: 10),
                  Expanded(
                    child: filteredArticles.isEmpty 
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.article_outlined, size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text(
                                'No articles found',
                                style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                              ),
                              SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () => newsViewModel.loadArticles(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF26A69A),
                                ),
                                child: Text('Refresh'),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: filteredArticles.length,
                          itemBuilder: (context, index) {
                            Article article = filteredArticles[index];
                            return Container(
                              margin: EdgeInsets.only(bottom: 20),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    offset: Offset(0, 5),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 5,
                                shadowColor: Colors.black.withOpacity(0.1),
                                child: Column(
                                  children: [
                                    if (article.urlToImage != null)
                                      ClipRRect(
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(16),
                                          topRight: Radius.circular(16),
                                        ),
                                        child: Image.network(
                                          article.urlToImage!,
                                          width: double.infinity,
                                          height: 200,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Container(
                                              width: double.infinity,
                                              height: 200,
                                              color: Colors.grey[300],
                                              child: Icon(Icons.image_not_supported, size: 50),
                                            );
                                          },
                                        ),
                                      ),
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            article.title,
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            article.description,
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.black54,
                                            ),
                                            maxLines: 3,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          SizedBox(height: 12),
                                          Divider(),
                                          SizedBox(height: 8),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                article.author ?? "Unknown Author",
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontStyle: FontStyle.italic,
                                                  color: Colors.black54,
                                                ),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => ArticleDetailScreen(
                                                        article: article,
                                                      ),
                                                    ),
                                                  );
                                                },
                                                child: Text(
                                                  "Read More",
                                                  style: TextStyle(
                                                    color: Color(0xFF26A69A),
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                  ),
                ],
              ),
            ),
    );
  }
}