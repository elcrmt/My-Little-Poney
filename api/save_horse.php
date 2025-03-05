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
    $id = isset($_POST['id']) ? $_POST['id'] : null;
    $name = isset($_POST['name']) ? $_POST['name'] : null;
    $age = isset($_POST['age']) && !empty($_POST['age']) ? $_POST['age'] : null;
    $color = isset($_POST['color']) ? $_POST['color'] : null;
    $breed = isset($_POST['breed']) ? $_POST['breed'] : null;
    $gender = isset($_POST['gender']) ? $_POST['gender'] : null;
    $specialty = isset($_POST['specialty']) ? $_POST['specialty'] : null;
    $relationship_type = isset($_POST['relationship_type']) ? $_POST['relationship_type'] : 'owner';
    $existing_photo = isset($_POST['existing_photo']) ? $_POST['existing_photo'] : null;

    // Valider les données
    if (!$user_id || !$name) {
        echo json_encode([
            'success' => false,
            'message' => 'ID utilisateur et nom du cheval requis'
        ]);
        exit;
    }

    // Gérer le téléchargement de la photo
    $photo = $existing_photo;
    if (isset($_FILES['photo']) && $_FILES['photo']['error'] == 0) {
        $upload_dir = '../uploads/';
        
        // Créer le répertoire s'il n'existe pas
        if (!file_exists($upload_dir)) {
            mkdir($upload_dir, 0777, true);
        }
        
        $file_name = time() . '_' . $_FILES['photo']['name'];
        $upload_path = $upload_dir . $file_name;
        
        if (move_uploaded_file($_FILES['photo']['tmp_name'], $upload_path)) {
            $photo = $file_name;
        }
    }

    // Commencer une transaction
    $conn->begin_transaction();

    try {
        if ($id) {
            // Mettre à jour un cheval existant
            $sql = "UPDATE horse SET 
                    name = ?, 
                    age = ?, 
                    color = ?, 
                    breed = ?, 
                    gender = ?, 
                    specialty = ?";
            
            // Ajouter la photo à la requête si elle existe
            if ($photo) {
                $sql .= ", photo = ?";
            }
            
            $sql .= " WHERE id = ?";
            
            $stmt = $conn->prepare($sql);
            
            if ($photo) {
                $stmt->bind_param("sisssssi", $name, $age, $color, $breed, $gender, $specialty, $photo, $id);
            } else {
                $stmt->bind_param("sissssi", $name, $age, $color, $breed, $gender, $specialty, $id);
            }
            
            $stmt->execute();
        } else {
            // Créer un nouveau cheval
            $sql = "INSERT INTO horse (name, age, color, breed, gender, specialty, photo) 
                    VALUES (?, ?, ?, ?, ?, ?, ?)";
            
            $stmt = $conn->prepare($sql);
            $stmt->bind_param("sisssss", $name, $age, $color, $breed, $gender, $specialty, $photo);
            $stmt->execute();
            
            // Récupérer l'ID du cheval nouvellement créé
            $id = $conn->insert_id;
            
            // Créer la relation entre l'utilisateur et le cheval
            $sql = "INSERT INTO user_horse (user_id, horse_id, relationship_type) 
                    VALUES (?, ?, ?)";
            
            $stmt = $conn->prepare($sql);
            $stmt->bind_param("iis", $user_id, $id, $relationship_type);
            $stmt->execute();
        }
        
        // Valider la transaction
        $conn->commit();
        
        echo json_encode([
            'success' => true,
            'message' => 'Cheval ' . ($id ? 'mis à jour' : 'ajouté') . ' avec succès',
            'horse_id' => $id
        ]);
    } catch (Exception $e) {
        // Annuler la transaction en cas d'erreur
        $conn->rollback();
        
        echo json_encode([
            'success' => false,
            'message' => 'Erreur lors de l\'enregistrement du cheval: ' . $e->getMessage()
        ]);
    }
} else {
    echo json_encode([
        'success' => false,
        'message' => 'Méthode non autorisée'
    ]);
}

$conn->close();
?>
