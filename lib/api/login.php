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
    // Get username and password from request
    $username = isset($_POST['username']) ? $_POST['username'] : '';
    $password = isset($_POST['password']) ? $_POST['password'] : '';

    // Validate input
    if (empty($username) || empty($password)) {
        echo json_encode([
            "success" => false,
            "message" => "Username and password are required"
        ]);
        exit;
    }

    // Prepare SQL statement to prevent SQL injection
    $stmt = $conn->prepare("SELECT * FROM user WHERE name = ?");
    $stmt->bind_param("s", $username);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows > 0) {
        $user = $result->fetch_assoc();
        
        // Verify password (in a real app, use password_hash and password_verify)
        if ($password === $user['password']) {
            // Password is correct, return user data
            // Remove password from response
            unset($user['password']);
            
            // Add profile image URL if exists
            if (!empty($user['profile_image'])) {
                $user['profile_image'] = 'http://localhost/api/uploads/profiles/' . $user['profile_image'];
            }

            echo json_encode([
                "success" => true,
                "message" => "Login successful",
                "user" => $user
            ]);
        } else {
            // Password is incorrect
            echo json_encode([
                "success" => false,
                "message" => "Invalid password"
            ]);
        }
    } else {
        // User not found
        echo json_encode([
            "success" => false,
            "message" => "User not found"
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

$conn->close();
?>
