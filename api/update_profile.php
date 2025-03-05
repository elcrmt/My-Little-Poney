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
    $id = isset($_POST['id']) ? $_POST['id'] : null;
    $name = isset($_POST['name']) ? $_POST['name'] : null;
    $email = isset($_POST['email']) ? $_POST['email'] : null;
    $phone_number = isset($_POST['phone_number']) && !empty($_POST['phone_number']) ? $_POST['phone_number'] : 0;
    $age = isset($_POST['age']) && !empty($_POST['age']) ? $_POST['age'] : 0;
    $ffe_profile_link = isset($_POST['ffe_profile_link']) ? $_POST['ffe_profile_link'] : '';
    $is_dp = isset($_POST['is_dp']) ? $_POST['is_dp'] : 0;

    // Valider les données
    if (!$id || !$name || !$email) {
        echo json_encode([
            'success' => false,
            'message' => 'Tous les champs obligatoires doivent être remplis'
        ]);
        exit;
    }

    // Mettre à jour les informations de l'utilisateur
    $sql = "UPDATE `user` SET 
            `name` = ?, 
            `email` = ?, 
            `phone_number` = ?, 
            `age` = ?, 
            `ffe_profile_link` = ?, 
            `is_dp` = ? 
            WHERE `id` = ?";
    
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("ssiisii", $name, $email, $phone_number, $age, $ffe_profile_link, $is_dp, $id);
    
    if ($stmt->execute()) {
        // Récupérer les informations mises à jour de l'utilisateur
        $sql = "SELECT * FROM `user` WHERE `id` = ?";
        $stmt = $conn->prepare($sql);
        $stmt->bind_param("i", $id);
        $stmt->execute();
        $result = $stmt->get_result();
        $user = $result->fetch_assoc();
        
        echo json_encode([
            'success' => true,
            'message' => 'Profil mis à jour avec succès',
            'user' => $user
        ]);
    } else {
        echo json_encode([
            'success' => false,
            'message' => 'Erreur lors de la mise à jour du profil: ' . $stmt->error
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
