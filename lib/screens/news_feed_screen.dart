import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/constants.dart';
import 'package:intl/intl.dart';
import 'add_news_item_screen.dart';

class NewsFeedScreen extends StatefulWidget {
  final dynamic userId;

  const NewsFeedScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _NewsFeedScreenState createState() => _NewsFeedScreenState();
}

class _NewsFeedScreenState extends State<NewsFeedScreen> {
  List<dynamic> _newsItems = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadNewsFeed();
  }

  Future<void> _loadNewsFeed() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await http.get(
        Uri.parse('${Constants.apiUrl}/get_news_feed.php'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success']) {
          setState(() {
            _newsItems = data['news_items'];
          });
        } else {
          setState(() {
            _errorMessage = data['message'] ?? 'Erreur lors du chargement des actualités';
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Erreur serveur. Veuillez réessayer plus tard.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Une erreur est survenue: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildNewsItem(dynamic newsItem) {
    IconData iconData;
    Color iconColor;
    
    // Déterminer l'icône et la couleur en fonction du type d'actualité
    switch(newsItem['type']) {
      case 'new_user':
        iconData = Icons.person_add;
        iconColor = Colors.blue;
        break;
      case 'new_competition':
        iconData = Icons.emoji_events;
        iconColor = Colors.amber;
        break;
      case 'new_course':
        iconData = Icons.school;
        iconColor = Colors.green;
        break;
      case 'new_event':
        iconData = Icons.celebration;
        iconColor = Colors.purple;
        break;
      default:
        iconData = Icons.info;
        iconColor = Colors.grey;
    }

    // Formater la date
    String formattedDate = '';
    if (newsItem['created_at'] != null) {
      try {
        DateTime dateTime = DateTime.parse(newsItem['created_at']);
        formattedDate = DateFormat('dd/MM/yyyy à HH:mm').format(dateTime);
      } catch (e) {
        formattedDate = newsItem['created_at'];
      }
    }

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: iconColor.withOpacity(0.2),
          child: Icon(iconData, color: iconColor),
        ),
        title: Text(newsItem['title'] ?? 'Sans titre'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text(newsItem['description'] ?? ''),
            SizedBox(height: 4),
            Text(
              formattedDate,
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  void _navigateToAddNewsItem() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddNewsItemScreen(userId: widget.userId),
      ),
    );
    
    if (result == true) {
      _loadNewsFeed();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Actualités'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadNewsFeed,
            tooltip: 'Rafraîchir',
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _errorMessage,
                        style: TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadNewsFeed,
                        child: Text('Réessayer'),
                      ),
                    ],
                  ),
                )
              : _newsItems.isEmpty
                  ? Center(
                      child: Text(
                        'Aucune actualité disponible pour le moment',
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadNewsFeed,
                      child: ListView.builder(
                        itemCount: _newsItems.length,
                        itemBuilder: (context, index) {
                          return _buildNewsItem(_newsItems[index]);
                        },
                      ),
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddNewsItem,
        child: Icon(Icons.add),
        tooltip: 'Ajouter une actualité',
      ),
    );
  }
}
