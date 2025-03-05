import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import '../utils/constants.dart';

class HorseDetailScreen extends StatefulWidget {
  final dynamic userId;
  final Map<String, dynamic>? horse;
  final bool isNewHorse;

  const HorseDetailScreen({
    Key? key,
    required this.userId,
    this.horse,
    this.isNewHorse = false,
  }) : super(key: key);

  @override
  _HorseDetailScreenState createState() => _HorseDetailScreenState();
}

class _HorseDetailScreenState extends State<HorseDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _breedController = TextEditingController();
  String _gender = 'male';
  String _specialty = 'dressage';
  File? _imageFile;
  String? _existingImage;
  
  bool _isLoading = false;
  String _message = '';
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    if (widget.horse != null) {
      _nameController.text = widget.horse!['name'];
      _ageController.text = widget.horse!['age']?.toString() ?? '';
      _colorController.text = widget.horse!['color'] ?? '';
      _breedController.text = widget.horse!['breed'] ?? '';
      _gender = widget.horse!['gender'] ?? 'male';
      _specialty = widget.horse!['specialty'] ?? 'dressage';
      _existingImage = widget.horse!['photo'];
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveHorse() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _message = '';
      _isSuccess = false;
    });

    try {
      // Créer un objet request multipart
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${Constants.apiUrl}/save_horse.php'),
      );

      // Ajouter les champs texte
      request.fields['user_id'] = widget.userId.toString();
      if (widget.horse != null) {
        request.fields['id'] = widget.horse!['id'].toString();
      }
      request.fields['name'] = _nameController.text;
      request.fields['age'] = _ageController.text;
      request.fields['color'] = _colorController.text;
      request.fields['breed'] = _breedController.text;
      request.fields['gender'] = _gender;
      request.fields['specialty'] = _specialty;
      request.fields['relationship_type'] = widget.horse != null 
          ? widget.horse!['relationship_type'] 
          : 'owner'; // Par défaut, le propriétaire pour un nouveau cheval

      // Ajouter l'image si elle existe
      if (_imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'photo',
            _imageFile!.path,
          ),
        );
      } else if (_existingImage != null) {
        request.fields['existing_photo'] = _existingImage!;
      }

      // Envoyer la requête
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        setState(() {
          _isSuccess = data['success'] ?? false;
          _message = data['message'] ?? 'Une erreur est survenue';
        });
        
        if (_isSuccess) {
          // Attendre un peu pour montrer le message de succès
          await Future.delayed(Duration(seconds: 1));
          Navigator.pop(context, true);
        }
      } else {
        setState(() {
          _message = 'Erreur serveur. Veuillez réessayer plus tard.';
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Une erreur est survenue: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.horse == null ? 'Ajouter un cheval' : 'Modifier le cheval'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: _imageFile != null
                        ? FileImage(_imageFile!)
                        : (_existingImage != null
                            ? NetworkImage('${Constants.apiUrl}/${Constants.horseImagePath}/${_existingImage}') as ImageProvider
                            : null),
                    child: (_imageFile == null && _existingImage == null)
                        ? Icon(Icons.pets, size: 60)
                        : null,
                  ),
                ),
              ),
              SizedBox(height: 8),
              Center(
                child: TextButton.icon(
                  icon: Icon(Icons.photo_library),
                  label: Text('Choisir une photo'),
                  onPressed: _pickImage,
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nom du cheval',
                  prefixIcon: Icon(Icons.pets),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le nom du cheval';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _ageController,
                decoration: InputDecoration(
                  labelText: 'Âge',
                  prefixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    if (int.tryParse(value) == null) {
                      return 'Veuillez entrer un nombre valide';
                    }
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _colorController,
                decoration: InputDecoration(
                  labelText: 'Couleur',
                  prefixIcon: Icon(Icons.color_lens),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _breedController,
                decoration: InputDecoration(
                  labelText: 'Race',
                  prefixIcon: Icon(Icons.category),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _gender,
                decoration: InputDecoration(
                  labelText: 'Genre',
                  prefixIcon: Icon(Icons.transgender),
                  border: OutlineInputBorder(),
                ),
                items: Constants.genderLabels.entries.map((entry) {
                  return DropdownMenuItem<String>(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _gender = value!;
                  });
                },
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _specialty,
                decoration: InputDecoration(
                  labelText: 'Spécialité',
                  prefixIcon: Icon(Icons.sports),
                  border: OutlineInputBorder(),
                ),
                items: Constants.specialtyLabels.entries.map((entry) {
                  return DropdownMenuItem<String>(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _specialty = value!;
                  });
                },
              ),
              SizedBox(height: 24),
              if (_message.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    _message,
                    style: TextStyle(
                      color: _isSuccess ? Colors.green : Colors.red,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveHorse,
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('ENREGISTRER'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
