import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List user = [];
  bool isLoading = true;
  String errorMessage = '';

  Future<void> fetchuser() async {
    try {
      // Make sure to use the correct URL
      final apiUrl = "http://localhost/api/api.php";
      print("Fetching data from: $apiUrl");
      
      final response = await http.get(Uri.parse(apiUrl));
      print("Response status: ${response.statusCode}");
      
      if (response.statusCode == 200) {
        // The API response contains debug comments, we need to clean it
        String responseBody = response.body;
        
        // Remove the debug comments (lines starting with /*)
        final lines = responseBody.split('\n');
        final cleanedLines = lines.where((line) => !line.trim().startsWith('/*')).join('\n');
        
        print("Cleaned response body: $cleanedLines");
        
        setState(() {
          user = jsonDecode(cleanedLines);
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = "Error: HTTP ${response.statusCode} - ${response.reasonPhrase}";
          isLoading = false;
        });
        print(errorMessage);
      }
    } catch (e) {
      setState(() {
        errorMessage = "Exception during API call: $e";
        isLoading = false;
      });
      print(errorMessage);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchuser();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("Utilisateurs"),
          actions: [
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () {
                setState(() {
                  isLoading = true;
                  errorMessage = '';
                });
                fetchuser();
              },
            ),
          ],
        ),
        body: isLoading 
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Une erreur s'est produite",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(errorMessage),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isLoading = true;
                          errorMessage = '';
                        });
                        fetchuser();
                      },
                      child: Text("Réessayer"),
                    ),
                  ],
                ),
              )
            : user.isEmpty
              ? Center(child: Text("Aucun utilisateur trouvé"))
              : ListView.builder(
                  itemCount: user.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(user[index]['name']),
                      subtitle: Text(user[index]['email']),
                    );
                  },
                ),
      ),
    );
  }
}
