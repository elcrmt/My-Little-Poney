import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'profile_screen.dart';
import 'horse_list_screen.dart';
import 'news_feed_screen.dart';
import '../utils/constants.dart';

class HomeScreen extends StatelessWidget {
  final Map<String, dynamic> userData;

  const HomeScreen({Key? key, required this.userData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              // Logout and navigate to login screen
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => LoginScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 24),
              CircleAvatar(
                radius: 50,
                backgroundImage: userData['profile_image'] != null
                    ? NetworkImage('${Constants.apiUrl}/${Constants.profileImagePath}/${userData['profile_image']}')
                    : null,
                child: userData['profile_image'] == null
                    ? Icon(Icons.person, size: 50)
                    : null,
              ),
              SizedBox(height: 16),
              Text(
                'Welcome, ${userData['name'].toString()}!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                userData['email'].toString(),
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 32),
              Card(
                margin: EdgeInsets.symmetric(horizontal: 16),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'User Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Divider(),
                      _buildInfoRow('ID', userData['id'].toString()),
                      _buildInfoRow('Username', userData['name'].toString()),
                      _buildInfoRow('Email', userData['email'].toString()),
                      if (userData['phone_number'] != null)
                        _buildInfoRow('Phone', userData['phone_number'].toString()),
                      if (userData['age'] != null)
                        _buildInfoRow('Age', userData['age'].toString()),
                      if (userData['ffe_profile_link'] != null)
                        _buildInfoRow('FFE Profile', userData['ffe_profile_link'].toString()),
                      if (userData['is_dp'] != null)
                        _buildInfoRow('Demi-Pension', userData['is_dp'] == 1 ? 'Oui' : 'Non'),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    icon: Icon(Icons.edit),
                    label: Text('Modifier mon profil'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfileScreen(userData: userData),
                        ),
                      ).then((value) {
                        // Refresh the screen when returning from profile screen
                        if (value != null && value == true) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Profil mis à jour avec succès')),
                          );
                        }
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                  SizedBox(width: 16),
                  ElevatedButton.icon(
                    icon: Icon(Icons.newspaper),
                    label: Text('Actualités'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NewsFeedScreen(userId: userData['id']),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              ElevatedButton.icon(
                icon: Icon(Icons.pets),
                label: Text('Gérer mes chevaux'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HorseListScreen(userId: userData['id']),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
              SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.grey[900],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
