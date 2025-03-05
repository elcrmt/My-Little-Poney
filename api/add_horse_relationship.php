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
    $user_id = isset($_POST['user_id']) ? $_POST['user_id'] : null;
    $horse_id = isset($_POST['horse_id']) ? $_POST['horse_id'] : null;
    $relationship_type = isset($_POST['relationship_type']) ? $_POST['relationship_type'] : null;

    // Log des données reçues
    error_log("Données reçues: user_id=$user_id, horse_id=$horse_id, relationship_type=$relationship_type");

    // Valider les données
    if (!$user_id || !$horse_id || !$relationship_type) {
        echo json_encode([
            'success' => false,
            'message' => 'Tous les champs sont requis'
        ]);
        exit;
    }

    // Vérifier si la relation existe déjà
    $sql = "SELECT * FROM user_horse WHERE user_id = ? AND horse_id = ?";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("ii", $user_id, $horse_id);
    $stmt->execute();
    $result = $stmt->get_result();
    
    if ($result->num_rows > 0) {
        // Mettre à jour la relation existante
        $sql = "UPDATE user_horse SET relationship_type = ? WHERE user_id = ? AND horse_id = ?";
        $stmt = $conn->prepare($sql);
        $stmt->bind_param("sii", $relationship_type, $user_id, $horse_id);
        error_log("Mise à jour de la relation existante");
    } else {
        // Créer une nouvelle relation
        $sql = "INSERT INTO user_horse (user_id, horse_id, relationship_type) VALUES (?, ?, ?)";
        $stmt = $conn->prepare($sql);
        $stmt->bind_param("iis", $user_id, $horse_id, $relationship_type);
        error_log("Création d'une nouvelle relation");
    }
    
    if ($stmt->execute()) {
        error_log("Opération réussie");
        echo json_encode([
            'success' => true,
            'message' => 'Relation avec le cheval ajoutée avec succès'
        ]);
    } else {
        error_log("Erreur SQL: " . $stmt->error);
        echo json_encode([
            'success' => false,
            'message' => 'Erreur lors de l\'ajout de la relation: ' . $stmt->error
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
