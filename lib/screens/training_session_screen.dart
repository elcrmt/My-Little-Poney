import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/constants.dart';
import 'package:intl/intl.dart';
import 'add_training_session_screen.dart';

class TrainingSessionScreen extends StatefulWidget {
  final dynamic userId;

  const TrainingSessionScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _TrainingSessionScreenState createState() => _TrainingSessionScreenState();
}

class _TrainingSessionScreenState extends State<TrainingSessionScreen> {
  List<dynamic> _sessions = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadTrainingSessions();
  }

  Future<void> _loadTrainingSessions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await http.get(
        Uri.parse('${Constants.apiUrl}/get_user_training_sessions.php?user_id=${widget.userId}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success']) {
          setState(() {
            _sessions = data['sessions'];
          });
        } else {
          setState(() {
            _errorMessage = data['message'] ?? 'Erreur lors du chargement des sessions d\'entraînement';
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

  Widget _buildSessionItem(dynamic session) {
    // Formater la date
    String formattedDate = '';
    if (session['training_date'] != null) {
      try {
        DateTime dateTime = DateTime.parse(session['training_date']);
        formattedDate = DateFormat('dd/MM/yyyy à HH:mm').format(dateTime);
      } catch (e) {
        formattedDate = session['training_date'];
      }
    }

    // Déterminer l'icône et la couleur en fonction de la discipline
    IconData iconData;
    Color iconColor;
    
    switch(session['discipline']) {
      case 'dressage':
        iconData = Icons.sports_gymnastics;
        iconColor = Colors.blue;
        break;
      case 'jumping':
        iconData = Icons.height;
        iconColor = Colors.amber;
        break;
      case 'endurance':
        iconData = Icons.directions_run;
        iconColor = Colors.green;
        break;
      default:
        iconData = Icons.sports;
        iconColor = Colors.grey;
    }

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: iconColor.withOpacity(0.2),
          child: Icon(iconData, color: iconColor),
        ),
        title: Text(session['discipline_label'] ?? 'Session d\'entraînement'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text('${session['location_label']} - ${session['duration_label']}'),
            SizedBox(height: 4),
            Text(
              formattedDate,
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Colors.grey[600],
              ),
            ),
            if (session['horse_name'] != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Cheval: ${session['horse_name']}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        isThreeLine: true,
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddTrainingSessionScreen(
                userId: widget.userId,
                sessionData: session,
              ),
            ),
          );
          
          if (result == true) {
            _loadTrainingSessions();
          }
        },
      ),
    );
  }

  void _navigateToAddTrainingSession() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTrainingSessionScreen(userId: widget.userId),
      ),
    );
    
    if (result == true) {
      _loadTrainingSessions();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mes cours d\'équitation'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadTrainingSessions,
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
                        onPressed: _loadTrainingSessions,
                        child: Text('Réessayer'),
                      ),
                    ],
                  ),
                )
              : _sessions.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Aucun cours programmé pour le moment',
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _navigateToAddTrainingSession,
                            child: Text('Programmer un cours'),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadTrainingSessions,
                      child: ListView.builder(
                        itemCount: _sessions.length,
                        itemBuilder: (context, index) {
                          return _buildSessionItem(_sessions[index]);
                        },
                      ),
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddTrainingSession,
        child: Icon(Icons.add),
        tooltip: 'Programmer un cours',
      ),
    );
  }
}
