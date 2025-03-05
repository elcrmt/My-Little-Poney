import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/constants.dart';
import 'horse_list_screen.dart';

class ProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const ProfileScreen({Key? key, required this.userData}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _ageController;
  late TextEditingController _ffeProfileLinkController;
  bool _isDP = false;
  
  bool _isLoading = false;
  String _message = '';
  bool _isSuccess = false;
  
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userData['name']);
    _emailController = TextEditingController(text: widget.userData['email']);
    _phoneController = TextEditingController(text: widget.userData['phone_number']?.toString() ?? '');
    _ageController = TextEditingController(text: widget.userData['age']?.toString() ?? '');
    _ffeProfileLinkController = TextEditingController(text: widget.userData['ffe_profile_link'] ?? '');
    _isDP = widget.userData['is_dp'] == 1;
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    _ffeProfileLinkController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _message = '';
      _isSuccess = false;
    });

    try {
      final response = await http.post(
        Uri.parse('${Constants.apiUrl}/update_profile.php'),
        body: {
          'id': widget.userData['id'].toString(),
          'name': _nameController.text,
          'email': _emailController.text,
          'phone_number': _phoneController.text,
          'age': _ageController.text,
          'ffe_profile_link': _ffeProfileLinkController.text,
          'is_dp': _isDP ? '1' : '0',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        setState(() {
          _isSuccess = data['success'] ?? false;
          _message = data['message'] ?? 'Une erreur est survenue';
          
          // Mettre à jour les données utilisateur si succès
          if (_isSuccess && data['user'] != null) {
            widget.userData.addAll(data['user']);
          }
        });
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
        title: Text('Modifier mon profil'),
        actions: [
          IconButton(
            icon: Icon(Icons.pets),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HorseListScreen(userId: widget.userData['id']),
                ),
              );
            },
            tooltip: 'Gérer mes chevaux',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: widget.userData['profile_image'] != null
                    ? NetworkImage('${Constants.apiUrl}/${Constants.profileImagePath}/${widget.userData['profile_image']}')
                    : null,
                child: widget.userData['profile_image'] == null
                    ? Icon(Icons.person, size: 50)
                    : null,
              ),
              SizedBox(height: 24.0),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nom',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre nom';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre email';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Veuillez entrer un email valide';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Numéro de téléphone',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  // Le téléphone est optionnel
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _ageController,
                decoration: InputDecoration(
                  labelText: 'Âge',
                  prefixIcon: Icon(Icons.cake),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final age = int.tryParse(value);
                    if (age == null || age <= 0) {
                      return 'Veuillez entrer un âge valide';
                    }
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _ffeProfileLinkController,
                decoration: InputDecoration(
                  labelText: 'Lien vers profil FFE',
                  prefixIcon: Icon(Icons.link),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.url,
                validator: (value) {
                  // Le lien FFE est optionnel
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              SwitchListTile(
                title: Text('Je suis une Demi-Pension (DP)'),
                value: _isDP,
                onChanged: (value) {
                  setState(() {
                    _isDP = value;
                  });
                },
                secondary: Icon(Icons.handshake),
              ),
              SizedBox(height: 24.0),
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
                onPressed: _isLoading ? null : _updateProfile,
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('ENREGISTRER LES MODIFICATIONS'),
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
