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

// Vérifier si l'ID utilisateur est fourni
if (!isset($_GET['user_id'])) {
    echo json_encode([
        'success' => false,
        'message' => 'ID utilisateur requis'
    ]);
    exit;
}

$user_id = $_GET['user_id'];

// Récupérer les sessions d'entraînement de l'utilisateur
$sql = "SELECT ts.*, h.name as horse_name, h.photo as horse_photo 
        FROM training_session ts 
        LEFT JOIN horse h ON ts.horse_id = h.id 
        WHERE ts.user_id = ? 
        ORDER BY ts.training_date ASC";

$stmt = $conn->prepare($sql);
$stmt->bind_param("i", $user_id);
$stmt->execute();
$result = $stmt->get_result();

if ($result) {
    $sessions = [];
    
    while ($row = $result->fetch_assoc()) {
        // Convertir les valeurs énumérées en libellés plus lisibles
        $row['location_label'] = $row['location'] == 'carriere' ? 'Carrière' : 'Manège';
        $row['duration_label'] = $row['duration'] == '30' ? '30 minutes' : '1 heure';
        
        switch ($row['discipline']) {
            case 'dressage':
                $row['discipline_label'] = 'Dressage';
                break;
            case 'jumping':
                $row['discipline_label'] = 'Saut d\'obstacle';
                break;
            case 'endurance':
                $row['discipline_label'] = 'Endurance';
                break;
            default:
                $row['discipline_label'] = $row['discipline'];
        }
        
        $sessions[] = $row;
    }
    
    echo json_encode([
        'success' => true,
        'sessions' => $sessions
    ]);
} else {
    echo json_encode([
        'success' => false,
        'message' => 'Erreur lors de la récupération des sessions d\'entraînement: ' . $conn->error
    ]);
}

$stmt->close();
$conn->close();
?>
