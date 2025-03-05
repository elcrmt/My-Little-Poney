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

    // Log des données reçues
    error_log("Suppression relation: user_id=$user_id, horse_id=$horse_id");

    // Valider les données
    if (!$user_id || !$horse_id) {
        echo json_encode([
            'success' => false,
            'message' => 'Tous les champs sont requis'
        ]);
        exit;
    }

    // Supprimer la relation
    $sql = "DELETE FROM user_horse WHERE user_id = ? AND horse_id = ?";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("ii", $user_id, $horse_id);
    
    if ($stmt->execute()) {
        if ($stmt->affected_rows > 0) {
            echo json_encode([
                'success' => true,
                'message' => 'Relation avec le cheval supprimée avec succès'
            ]);
        } else {
            echo json_encode([
                'success' => false,
                'message' => 'Aucune relation trouvée à supprimer'
            ]);
        }
    } else {
        echo json_encode([
            'success' => false,
            'message' => 'Erreur lors de la suppression de la relation: ' . $stmt->error
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
