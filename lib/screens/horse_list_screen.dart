import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/constants.dart';
import 'horse_detail_screen.dart';

class HorseListScreen extends StatefulWidget {
  final dynamic userId;

  const HorseListScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _HorseListScreenState createState() => _HorseListScreenState();
}

class _HorseListScreenState extends State<HorseListScreen> {
  List<dynamic> _userHorses = [];
  List<dynamic> _availableHorses = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadHorses();
  }

  Future<void> _loadHorses() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Charger les chevaux de l'utilisateur
      final userHorsesResponse = await http.get(
        Uri.parse('${Constants.apiUrl}/get_user_horses.php?user_id=${widget.userId}'),
      );

      // Charger tous les chevaux disponibles
      final availableHorsesResponse = await http.get(
        Uri.parse('${Constants.apiUrl}/get_available_horses.php'),
      );

      if (userHorsesResponse.statusCode == 200 && availableHorsesResponse.statusCode == 200) {
        final userHorsesData = json.decode(userHorsesResponse.body);
        final availableHorsesData = json.decode(availableHorsesResponse.body);

        setState(() {
          _userHorses = userHorsesData['success'] ? userHorsesData['horses'] : [];
          
          // Filtrer les chevaux disponibles pour exclure ceux que l'utilisateur possède déjà
          final List<dynamic> allHorses = availableHorsesData['success'] ? availableHorsesData['horses'] : [];
          final List<int> userHorseIds = _userHorses.map<int>((horse) => horse['id'] as int).toList();
          
          _availableHorses = allHorses.where((horse) => !userHorseIds.contains(horse['id'])).toList();
        });
      } else {
        setState(() {
          _errorMessage = 'Erreur lors du chargement des chevaux. Veuillez réessayer.';
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

  Future<void> _addHorseRelationship(int horseId, String relationshipType) async {
    try {
      final response = await http.post(
        Uri.parse('${Constants.apiUrl}/add_horse_relationship.php'),
        body: {
          'user_id': widget.userId.toString(),
          'horse_id': horseId.toString(),
          'relationship_type': relationshipType,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'])),
          );
          _loadHorses(); // Recharger la liste
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: ${data['message']}')),
          );
          print('Erreur lors de l\'ajout de la relation: ${data['message']}');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur serveur. Veuillez réessayer plus tard. Status: ${response.statusCode}')),
        );
        print('Erreur serveur: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Une erreur est survenue: $e')),
      );
      print('Exception lors de l\'ajout de la relation: $e');
    }
  }

  Future<void> _removeHorseRelationship(int horseId) async {
    try {
      final response = await http.post(
        Uri.parse('${Constants.apiUrl}/remove_horse_relationship.php'),
        body: {
          'user_id': widget.userId.toString(),
          'horse_id': horseId.toString(),
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'])),
          );
          _loadHorses(); // Recharger la liste
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'])),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur serveur. Veuillez réessayer plus tard.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Une erreur est survenue: $e')),
      );
    }
  }

  void _showAddHorseDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Ajouter un cheval existant'),
        content: _availableHorses.isEmpty
            ? Text('Aucun cheval disponible à ajouter.')
            : SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: _availableHorses.map((horse) {
                    return ListTile(
                      leading: horse['photo'] != null
                          ? CircleAvatar(
                              backgroundImage: NetworkImage(
                                '${Constants.apiUrl}/${Constants.horseImagePath}/${horse['photo']}',
                              ),
                            )
                          : CircleAvatar(child: Icon(Icons.pets)),
                      title: Text(horse['name']),
                      subtitle: Text('${horse['breed'] ?? 'Inconnu'}, ${horse['age'] ?? 'Âge inconnu'} ans'),
                      onTap: () {
                        Navigator.pop(context);
                        _showRelationshipTypeDialog(horse['id']);
                      },
                    );
                  }).toList(),
                ),
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateToAddNewHorse();
            },
            child: Text('Ajouter un nouveau cheval'),
          ),
        ],
      ),
    );
  }

  void _showRelationshipTypeDialog(int horseId) {
    print('Sélection du type de relation pour le cheval ID: $horseId');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Type de relation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.star),
              title: Text(Constants.relationshipLabels['owner']!),
              onTap: () {
                Navigator.pop(context);
                print('Ajout de relation: user_id=${widget.userId}, horse_id=$horseId, type=owner');
                _addHorseRelationship(horseId, 'owner');
              },
            ),
            ListTile(
              leading: Icon(Icons.handshake),
              title: Text(Constants.relationshipLabels['half_pension']!),
              onTap: () {
                Navigator.pop(context);
                print('Ajout de relation: user_id=${widget.userId}, horse_id=$horseId, type=half_pension');
                _addHorseRelationship(horseId, 'half_pension');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToAddNewHorse() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HorseDetailScreen(
          userId: widget.userId,
          isNewHorse: true,
        ),
      ),
    ).then((_) => _loadHorses());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mes chevaux'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage, style: TextStyle(color: Colors.red)))
              : _userHorses.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Vous n\'avez pas encore de chevaux'),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _showAddHorseDialog,
                            child: Text('Ajouter un cheval'),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _userHorses.length,
                      itemBuilder: (context, index) {
                        final horse = _userHorses[index];
                        return Card(
                          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: ListTile(
                            leading: horse['photo'] != null
                                ? CircleAvatar(
                                    backgroundImage: NetworkImage(
                                      '${Constants.apiUrl}/${Constants.horseImagePath}/${horse['photo']}',
                                    ),
                                  )
                                : CircleAvatar(child: Icon(Icons.pets)),
                            title: Text(horse['name']),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${horse['breed'] ?? 'Inconnu'}, ${horse['age'] ?? 'Âge inconnu'} ans'),
                                Text(
                                  'Relation: ${Constants.relationshipLabels[horse['relationship_type']] ?? horse['relationship_type']}',
                                  style: TextStyle(fontStyle: FontStyle.italic),
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => HorseDetailScreen(
                                          userId: widget.userId,
                                          horse: horse,
                                        ),
                                      ),
                                    ).then((_) => _loadHorses());
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Text('Confirmer la suppression'),
                                        content: Text('Êtes-vous sûr de vouloir supprimer ce cheval de votre liste ?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: Text('Annuler'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                              _removeHorseRelationship(horse['id']);
                                            },
                                            child: Text('Supprimer'),
                                            style: TextButton.styleFrom(
                                              foregroundColor: Colors.red,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                            isThreeLine: true,
                          ),
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddHorseDialog,
        child: Icon(Icons.add),
        tooltip: 'Ajouter un cheval',
      ),
    );
  }
}
