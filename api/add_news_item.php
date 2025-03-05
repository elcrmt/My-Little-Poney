<?php
// Autoriser les requêtes CORS
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: *");
header("Access-Control-Allow-Methods: *");
header("Content-Type: application/json");

// Connexion à la base de données
include 'db_connect.php';

// Vérifier la méthode OPTIONS pour les requêtes préliminaires CORS
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// Vérifier si la requête est une méthode POST
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Récupérer les données du formulaire
    $type = isset($_POST['type']) ? $_POST['type'] : null;
    $title = isset($_POST['title']) ? $_POST['title'] : null;
    $description = isset($_POST['description']) ? $_POST['description'] : null;
    $related_id = isset($_POST['related_id']) && !empty($_POST['related_id']) ? $_POST['related_id'] : null;

    // Log des données reçues
    error_log("Données reçues: type=$type, title=$title, related_id=" . ($related_id ?? 'NULL'));

    // Valider les données
    if (!$type || !$title) {
        echo json_encode([
            'success' => false,
            'message' => 'Le type et le titre sont requis'
        ]);
        exit;
    }

    // Vérifier que le type est valide
    $valid_types = ['new_user', 'new_competition', 'new_course', 'new_event'];
    if (!in_array($type, $valid_types)) {
        echo json_encode([
            'success' => false,
            'message' => 'Type d\'actualité non valide'
        ]);
        exit;
    }

    // Préparer la requête SQL
    if ($related_id === null) {
        $sql = "INSERT INTO news_feed (type, title, description) VALUES (?, ?, ?)";
        $stmt = $conn->prepare($sql);
        $stmt->bind_param("sss", $type, $title, $description);
    } else {
        $sql = "INSERT INTO news_feed (type, title, description, related_id) VALUES (?, ?, ?, ?)";
        $stmt = $conn->prepare($sql);
        $stmt->bind_param("sssi", $type, $title, $description, $related_id);
    }
    
    if ($stmt->execute()) {
        echo json_encode([
            'success' => true,
            'message' => 'Actualité ajoutée avec succès',
            'news_id' => $conn->insert_id
        ]);
    } else {
        echo json_encode([
            'success' => false,
            'message' => 'Erreur lors de l\'ajout de l\'actualité: ' . $stmt->error
        ]);
    }
    
    $stmt->close();
} else {
    echo json_encode([
        'success' => false,
        'message' => 'Méthode non autorisée'
    ]);
}

$conn->close();
?>
