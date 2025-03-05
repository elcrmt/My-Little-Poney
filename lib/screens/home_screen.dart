import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/constants.dart';
import 'profile_screen.dart';
import 'horse_list_screen.dart';
import 'news_feed_screen.dart';
import 'training_session_screen.dart';

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const HomeScreen({Key? key, required this.userData}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Map<String, dynamic> _userData;
  List<dynamic> _userHorses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _userData = widget.userData;
    _loadUserHorses();
  }

  Future<void> _loadUserHorses() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('${Constants.apiUrl}/get_user_horses.php?user_id=${_userData['id']}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            _userHorses = data['horses'];
          });
        }
      }
    } catch (e) {
      // Gérer l'erreur
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileScreen(userData: _userData),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _userData = result;
      });
    }
  }

  void _navigateToHorseList() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HorseListScreen(userId: _userData['id']),
      ),
    );

    if (result == true) {
      _loadUserHorses();
    }
  }

  void _navigateToNewsFeed() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewsFeedScreen(userId: _userData['id']),
      ),
    );
  }

  void _navigateToTrainingSessions() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TrainingSessionScreen(userId: _userData['id']),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Accueil'),
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: _navigateToProfile,
            tooltip: 'Profil',
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Carte utilisateur
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.blue.shade100,
                                child: Icon(
                                  Icons.person,
                                  size: 40,
                                  color: Colors.blue,
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Bienvenue, ${_userData['username']}',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      _userData['email'],
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Niveau: ${_userData['level'] ?? 'Débutant'}',
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          if (_userData['discipline'] != null)
                            Padding(
                              padding: EdgeInsets.only(top: 4),
                              child: Text(
                                'Discipline: ${_userData['discipline']}',
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 24),
                  
                  // Section des chevaux
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Mes chevaux',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: _navigateToHorseList,
                        child: Text('Voir tous'),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  _userHorses.isEmpty
                      ? Card(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.no_photography,
                                  size: 48,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Vous n\'avez pas encore de chevaux',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                  ),
                                ),
                                SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: _navigateToHorseList,
                                  child: Text('Ajouter un cheval'),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Container(
                          height: 200,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _userHorses.length > 3 ? 3 : _userHorses.length,
                            itemBuilder: (context, index) {
                              final horse = _userHorses[index];
                              return Card(
                                margin: EdgeInsets.only(right: 16),
                                child: Container(
                                  width: 160,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        height: 100,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(4),
                                            topRight: Radius.circular(4),
                                          ),
                                          image: horse['photo'] != null
                                              ? DecorationImage(
                                                  image: NetworkImage('${Constants.apiUrl}/${horse['photo']}'),
                                                  fit: BoxFit.cover,
                                                )
                                              : null,
                                        ),
                                        child: horse['photo'] == null
                                            ? Center(
                                                child: Icon(
                                                  Icons.pets,
                                                  size: 40,
                                                  color: Colors.grey[400],
                                                ),
                                              )
                                            : null,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(8),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              horse['name'],
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              horse['breed'] ?? 'Inconnu',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              '${horse['age'] ?? '?'} ans',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
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
                  
                  SizedBox(height: 24),
                  
                  // Section des fonctionnalités
                  Text(
                    'Fonctionnalités',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildFeatureCard(
                          icon: Icons.newspaper,
                          title: 'Actualités',
                          onTap: _navigateToNewsFeed,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: _buildFeatureCard(
                          icon: Icons.school,
                          title: 'Cours',
                          onTap: _navigateToTrainingSessions,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildFeatureCard(
                          icon: Icons.emoji_events,
                          title: 'Concours',
                          onTap: () {
                            // TODO: Implémenter la navigation vers les concours
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Fonctionnalité à venir')),
                            );
                          },
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: _buildFeatureCard(
                          icon: Icons.people,
                          title: 'Communauté',
                          onTap: () {
                            // TODO: Implémenter la navigation vers la communauté
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Fonctionnalité à venir')),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                icon,
                size: 40,
                color: Colors.blue,
              ),
              SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
