import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/constants.dart';
import 'package:intl/intl.dart';

class AddTrainingSessionScreen extends StatefulWidget {
  final dynamic userId;
  final dynamic sessionData;

  const AddTrainingSessionScreen({
    Key? key, 
    required this.userId, 
    this.sessionData,
  }) : super(key: key);

  @override
  _AddTrainingSessionScreenState createState() => _AddTrainingSessionScreenState();
}

class _AddTrainingSessionScreenState extends State<AddTrainingSessionScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isLoadingHorses = false;
  String _errorMessage = '';
  List<dynamic> _userHorses = [];

  // Valeurs par défaut
  String _selectedLocation = 'carriere';
  String _selectedDuration = '60';
  String _selectedDiscipline = 'dressage';
  DateTime _selectedDate = DateTime.now().add(Duration(days: 1));
  TimeOfDay _selectedTime = TimeOfDay(hour: 10, minute: 0);
  dynamic _selectedHorse;

  // Options pour les menus déroulants
  final Map<String, String> _locationLabels = {
    'carriere': 'Carrière',
    'manege': 'Manège',
  };

  final Map<String, String> _durationLabels = {
    '30': '30 minutes',
    '60': '1 heure',
  };

  final Map<String, String> _disciplineLabels = {
    'dressage': 'Dressage',
    'jumping': 'Saut d\'obstacle',
    'endurance': 'Endurance',
  };

  @override
  void initState() {
    super.initState();
    _loadUserHorses();
    
    // Si on a des données de session, on initialise les champs
    if (widget.sessionData != null) {
      _selectedLocation = widget.sessionData['location'];
      _selectedDuration = widget.sessionData['duration'];
      _selectedDiscipline = widget.sessionData['discipline'];
      
      if (widget.sessionData['training_date'] != null) {
        try {
          DateTime dateTime = DateTime.parse(widget.sessionData['training_date']);
          _selectedDate = dateTime;
          _selectedTime = TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
        } catch (e) {
          // Garder les valeurs par défaut en cas d'erreur
        }
      }
    }
  }

  Future<void> _loadUserHorses() async {
    setState(() {
      _isLoadingHorses = true;
    });

    try {
      final response = await http.get(
        Uri.parse('${Constants.apiUrl}/get_user_horses.php?user_id=${widget.userId}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success']) {
          setState(() {
            _userHorses = data['horses'];
            
            // Si on a des données de session avec un cheval, on le sélectionne
            if (widget.sessionData != null && widget.sessionData['horse_id'] != null) {
              for (var horse in _userHorses) {
                if (horse['id'].toString() == widget.sessionData['horse_id'].toString()) {
                  _selectedHorse = horse;
                  break;
                }
              }
            }
          });
        }
      }
    } catch (e) {
      // Gérer l'erreur silencieusement
    } finally {
      setState(() {
        _isLoadingHorses = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _saveTrainingSession() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Combiner date et heure
      final DateTime trainingDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );
      
      // Formater pour MySQL
      final String formattedDateTime = trainingDateTime.toIso8601String();
      
      // Préparer les données
      Map<String, String> formData = {
        'user_id': widget.userId.toString(),
        'location': _selectedLocation,
        'training_date': formattedDateTime,
        'duration': _selectedDuration,
        'discipline': _selectedDiscipline,
      };
      
      // Ajouter l'ID du cheval s'il est sélectionné
      if (_selectedHorse != null) {
        formData['horse_id'] = _selectedHorse['id'].toString();
      }
      
      // Ajouter l'ID de session si on est en mode édition
      if (widget.sessionData != null) {
        formData['session_id'] = widget.sessionData['id'].toString();
      }

      final response = await http.post(
        Uri.parse('${Constants.apiUrl}/save_training_session.php'),
        body: formData,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'])),
          );
          Navigator.pop(context, true);
        } else {
          setState(() {
            _errorMessage = data['message'] ?? 'Erreur lors de l\'enregistrement de la session';
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

  @override
  Widget build(BuildContext context) {
    final bool isEditMode = widget.sessionData != null;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Modifier le cours' : 'Programmer un cours'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    _errorMessage,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              
              Text(
                'Terrain d\'entraînement',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedLocation,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                items: _locationLabels.entries.map((entry) {
                  return DropdownMenuItem<String>(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedLocation = value!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez sélectionner un terrain';
                  }
                  return null;
                },
              ),
              
              SizedBox(height: 16),
              Text(
                'Date et heure',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(context),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        child: Text(
                          DateFormat('dd/MM/yyyy').format(_selectedDate),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectTime(context),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        child: Text(
                          _selectedTime.format(context),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 16),
              Text(
                'Durée',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedDuration,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                items: _durationLabels.entries.map((entry) {
                  return DropdownMenuItem<String>(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedDuration = value!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez sélectionner une durée';
                  }
                  return null;
                },
              ),
              
              SizedBox(height: 16),
              Text(
                'Discipline',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedDiscipline,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                items: _disciplineLabels.entries.map((entry) {
                  return DropdownMenuItem<String>(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedDiscipline = value!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez sélectionner une discipline';
                  }
                  return null;
                },
              ),
              
              SizedBox(height: 16),
              Text(
                'Cheval (optionnel)',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 8),
              _isLoadingHorses
                ? Center(child: CircularProgressIndicator())
                : DropdownButtonFormField<dynamic>(
                    value: _selectedHorse,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      hintText: 'Sélectionner un cheval (optionnel)',
                    ),
                    items: [
                      DropdownMenuItem<dynamic>(
                        value: null,
                        child: Text('Aucun cheval sélectionné'),
                      ),
                      ..._userHorses.map((horse) {
                        return DropdownMenuItem<dynamic>(
                          value: horse,
                          child: Text(horse['name']),
                        );
                      }).toList(),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedHorse = value;
                      });
                    },
                  ),
              
              SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveTrainingSession,
                  child: _isLoading
                      ? CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : Text(isEditMode ? 'Mettre à jour' : 'Programmer le cours'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
