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

// Récupérer les actualités
$sql = "SELECT * FROM news_feed ORDER BY created_at DESC LIMIT 50";
$result = $conn->query($sql);

if ($result) {
    $news_items = [];
    
    while ($row = $result->fetch_assoc()) {
        // Ajouter des informations supplémentaires en fonction du type d'actualité
        switch ($row['type']) {
            case 'new_user':
                if ($row['related_id']) {
                    // Récupérer les informations de l'utilisateur
                    $user_sql = "SELECT name FROM user WHERE id = ?";
                    $stmt = $conn->prepare($user_sql);
                    $stmt->bind_param("i", $row['related_id']);
                    $stmt->execute();
                    $user_result = $stmt->get_result();
                    
                    if ($user_result && $user_row = $user_result->fetch_assoc()) {
                        // Mettre à jour la description si nécessaire
                        if (empty($row['description'])) {
                            $row['description'] = $user_row['name'] . " a rejoint la communauté!";
                        }
                    }
                }
                break;
                
            case 'new_competition':
                // Vous pourriez ajouter ici des informations supplémentaires sur la compétition
                break;
                
            case 'new_course':
                // Vous pourriez ajouter ici des informations supplémentaires sur le cours
                break;
                
            case 'new_event':
                // Vous pourriez ajouter ici des informations supplémentaires sur l'événement
                break;
        }
        
        $news_items[] = $row;
    }
    
    echo json_encode([
        'success' => true,
        'news_items' => $news_items
    ]);
} else {
    echo json_encode([
        'success' => false,
        'message' => 'Erreur lors de la récupération des actualités: ' . $conn->error
    ]);
}

$conn->close();
?>
