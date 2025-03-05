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

// Vérifier si la requête est une méthode GET
if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    // Récupérer l'ID de l'utilisateur
    $user_id = isset($_GET['user_id']) ? $_GET['user_id'] : null;

    if (!$user_id) {
        echo json_encode([
            'success' => false,
            'message' => 'ID utilisateur requis'
        ]);
        exit;
    }

    // Récupérer les chevaux associés à l'utilisateur
    $sql = "SELECT h.*, uh.relationship_type 
            FROM horse h 
            JOIN user_horse uh ON h.id = uh.horse_id 
            WHERE uh.user_id = ?";
    
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("i", $user_id);
    $stmt->execute();
    $result = $stmt->get_result();
    
    $horses = [];
    while ($row = $result->fetch_assoc()) {
        $horses[] = $row;
    }
    
    echo json_encode([
        'success' => true,
        'horses' => $horses
    ]);
    
    $stmt->close();
} else {
    echo json_encode([
        'success' => false,
        'message' => 'Méthode non autorisée'
    ]);
}

$conn->close();
?>
