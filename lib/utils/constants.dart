class Constants {
  // API URL
  static const String apiUrl = 'http://localhost/api';
  
  // Image paths
  static const String profileImagePath = 'uploads/profiles';
  static const String horseImagePath = 'uploads';
  
  // Other constants
  static const int passwordMinLength = 6;
  
  // Horse constants
  static const Map<String, String> genderLabels = {
    'male': 'Mâle',
    'female': 'Femelle',
    'gelding': 'Hongre',
  };
  
  static const Map<String, String> specialtyLabels = {
    'dressage': 'Dressage',
    'jumping': 'Saut d\'obstacle',
    'endurance': 'Endurance',
    'eventing': 'Complet',
  };
  
  static const Map<String, String> relationshipLabels = {
    'owner': 'Propriétaire',
    'half_pension': 'Demi-pension',
  };
}
