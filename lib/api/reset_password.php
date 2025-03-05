<?php
// Add CORS headers
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Content-Type: application/json");

// Enable error reporting for debugging
error_reporting(E_ALL);
ini_set('display_errors', 1);

// Database connection
$host = "localhost";
$user = "root";
$pass = "";
$db = "flutter";

$conn = new mysqli($host, $user, $pass, $db);

if ($conn->connect_error) {
    die(json_encode([
        "success" => false,
        "message" => "Database connection failed: " . $conn->connect_error
    ]));
}

// Check if it's a POST request
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Get username and email from request
    $username = isset($_POST['username']) ? $_POST['username'] : '';
    $email = isset($_POST['email']) ? $_POST['email'] : '';

    // Validate input
    if (empty($username) || empty($email)) {
        echo json_encode([
            "success" => false,
            "message" => "Username and email are required"
        ]);
        exit;
    }

    // Check if user exists with the provided username and email
    $stmt = $conn->prepare("SELECT * FROM user WHERE name = ? AND email = ?");
    $stmt->bind_param("ss", $username, $email);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows > 0) {
        // User exists, generate a new password
        $new_password = generateRandomPassword();
        
        // Update user's password
        $update_stmt = $conn->prepare("UPDATE user SET password = ? WHERE name = ? AND email = ?");
        $update_stmt->bind_param("sss", $new_password, $username, $email);
        
        if ($update_stmt->execute()) {
            // In a real application, you would send an email with the new password
            // For this demo, we'll just return the new password in the response
            echo json_encode([
                "success" => true,
                "message" => "Password has been reset. Your new password is: " . $new_password
            ]);
        } else {
            echo json_encode([
                "success" => false,
                "message" => "Failed to reset password: " . $update_stmt->error
            ]);
        }
        
        $update_stmt->close();
    } else {
        // User not found
        echo json_encode([
            "success" => false,
            "message" => "No user found with the provided username and email"
        ]);
    }

    $stmt->close();
} else {
    // Not a POST request
    echo json_encode([
        "success" => false,
        "message" => "Invalid request method"
    ]);
}

// Function to generate a random password
function generateRandomPassword($length = 8) {
    $chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    $password = '';
    
    for ($i = 0; $i < $length; $i++) {
        $password .= $chars[rand(0, strlen($chars) - 1)];
    }
    
    return $password;
}

$conn->close();
?>
