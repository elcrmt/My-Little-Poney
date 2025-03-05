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
    $horse_id = isset($_POST['horse_id']) && !empty($_POST['horse_id']) ? $_POST['horse_id'] : null;
    $location = isset($_POST['location']) ? $_POST['location'] : null;
    $training_date = isset($_POST['training_date']) ? $_POST['training_date'] : null;
    $duration = isset($_POST['duration']) ? $_POST['duration'] : null;
    $discipline = isset($_POST['discipline']) ? $_POST['discipline'] : null;
    $session_id = isset($_POST['session_id']) && !empty($_POST['session_id']) ? $_POST['session_id'] : null;

    // Log des données reçues
    error_log("Données reçues: user_id=$user_id, horse_id=" . ($horse_id ?? 'NULL') . ", location=$location, date=$training_date, duration=$duration, discipline=$discipline, session_id=" . ($session_id ?? 'NULL'));

    // Valider les données
    if (!$user_id || !$location || !$training_date || !$duration || !$discipline) {
        echo json_encode([
            'success' => false,
            'message' => 'Tous les champs obligatoires sont requis'
        ]);
        exit;
    }

    // Vérifier que les valeurs énumérées sont valides
    $valid_locations = ['carriere', 'manege'];
    $valid_durations = ['30', '60'];
    $valid_disciplines = ['dressage', 'jumping', 'endurance'];

    if (!in_array($location, $valid_locations) || !in_array($duration, $valid_durations) || !in_array($discipline, $valid_disciplines)) {
        echo json_encode([
            'success' => false,
            'message' => 'Valeurs invalides pour les champs énumérés'
        ]);
        exit;
    }

    // Vérifier si c'est une mise à jour ou une nouvelle session
    if ($session_id) {
        // Mise à jour d'une session existante
        if ($horse_id) {
            $sql = "UPDATE training_session SET horse_id = ?, location = ?, training_date = ?, duration = ?, discipline = ? WHERE id = ? AND user_id = ?";
            $stmt = $conn->prepare($sql);
            $stmt->bind_param("issssii", $horse_id, $location, $training_date, $duration, $discipline, $session_id, $user_id);
        } else {
            $sql = "UPDATE training_session SET horse_id = NULL, location = ?, training_date = ?, duration = ?, discipline = ? WHERE id = ? AND user_id = ?";
            $stmt = $conn->prepare($sql);
            $stmt->bind_param("ssssii", $location, $training_date, $duration, $discipline, $session_id, $user_id);
        }
    } else {
        // Nouvelle session
        if ($horse_id) {
            $sql = "INSERT INTO training_session (user_id, horse_id, location, training_date, duration, discipline) VALUES (?, ?, ?, ?, ?, ?)";
            $stmt = $conn->prepare($sql);
            $stmt->bind_param("iissss", $user_id, $horse_id, $location, $training_date, $duration, $discipline);
        } else {
            $sql = "INSERT INTO training_session (user_id, location, training_date, duration, discipline) VALUES (?, ?, ?, ?, ?)";
            $stmt = $conn->prepare($sql);
            $stmt->bind_param("issss", $user_id, $location, $training_date, $duration, $discipline);
        }
    }

    if ($stmt->execute()) {
        $id = $session_id ? $session_id : $conn->insert_id;
        
        // Ajouter une actualité pour le nouveau cours
        if (!$session_id) {
            $title = "Nouveau cours programmé";
            $description = "Un cours de " . ($discipline == 'dressage' ? 'dressage' : ($discipline == 'jumping' ? 'saut d\'obstacle' : 'endurance')) . " a été programmé pour le " . date('d/m/Y à H:i', strtotime($training_date));
            
            $news_sql = "INSERT INTO news_feed (type, title, description, related_id) VALUES ('new_course', ?, ?, ?)";
            $news_stmt = $conn->prepare($news_sql);
            $news_stmt->bind_param("ssi", $title, $description, $id);
            $news_stmt->execute();
            $news_stmt->close();
        }
        
        echo json_encode([
            'success' => true,
            'message' => $session_id ? 'Session d\'entraînement mise à jour avec succès' : 'Session d\'entraînement créée avec succès',
            'session_id' => $id
        ]);
    } else {
        echo json_encode([
            'success' => false,
            'message' => 'Erreur lors de l\'enregistrement de la session d\'entraînement: ' . $stmt->error
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
