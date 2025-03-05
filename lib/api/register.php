<?php
// Add CORS headers
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Content-Type: application/json; charset=UTF-8");

// Disable error display in output
ini_set('display_errors', 0);
error_reporting(0);

// Database connection
$host = "localhost";
$user = "root";
$pass = "";
$db = "flutter";

$response = [
    "success" => false,
    "message" => "",
    "debug" => []
];

try {
    // Get user data from request
    $username = isset($_POST['username']) ? $_POST['username'] : '';
    $password = isset($_POST['password']) ? $_POST['password'] : '';
    $email = isset($_POST['email']) ? $_POST['email'] : '';
    $phone = isset($_POST['phone']) ? $_POST['phone'] : '';
    
    $response["debug"][] = "Received data: username=$username, email=$email, phone=$phone";

    // Validate input
    if (empty($username) || empty($password) || empty($email)) {
        $response["message"] = "Username, password, and email are required";
        echo json_encode($response);
        exit;
    }

    // Connect to database
    $conn = new mysqli($host, $user, $pass, $db);
    
    if ($conn->connect_error) {
        throw new Exception("Database connection failed: " . $conn->connect_error);
    }
    
    $response["debug"][] = "Database connection successful";

    // Insert user into database
    $stmt = $conn->prepare("INSERT INTO user (name, password, email, phone_number) VALUES (?, ?, ?, ?)");
    $stmt->bind_param("ssss", $username, $password, $email, $phone);
    
    $result = $stmt->execute();
    
    if ($result) {
        $response["success"] = true;
        $response["message"] = "Registration successful";
    } else {
        // Check if it's a duplicate key error
        if ($conn->errno == 1062) {
            $response["message"] = "Username or email already exists";
        } else {
            $response["message"] = "Registration failed: " . $stmt->error;
        }
        $response["debug"][] = "MySQL Error: " . $conn->errno . " - " . $conn->error;
    }
    
    $stmt->close();
    $conn->close();
    
} catch (Exception $e) {
    $response["message"] = "Server error: " . $e->getMessage();
    $response["debug"][] = "Exception: " . $e->getMessage();
}

echo json_encode($response);
?>
