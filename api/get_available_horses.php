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
    // Récupérer tous les chevaux
    $sql = "SELECT * FROM horse";
    
    $result = $conn->query($sql);
    
    $horses = [];
    while ($row = $result->fetch_assoc()) {
        $horses[] = $row;
    }
    
    echo json_encode([
        'success' => true,
        'horses' => $horses
    ]);
} else {
    echo json_encode([
        'success' => false,
        'message' => 'Méthode non autorisée'
    ]);
}

$conn->close();
?>
