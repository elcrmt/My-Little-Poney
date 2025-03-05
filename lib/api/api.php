<?php
// Add CORS headers
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Content-Type: application/json"); // Ensure proper content type

// Enable error reporting for debugging
error_reporting(E_ALL);
ini_set('display_errors', 1);

$host = "localhost";
$user = "root";
$pass = "";
$db = "flutter";

// Log connection attempt
// echo "/* Connecting to database... */\n";

$conn = new mysqli($host, $user, $pass, $db);

if ($conn->connect_error) {
    die(json_encode(["error" => "Database connection failed: " . $conn->connect_error]));
}

// echo "/* Connected successfully */\n";

$sql = "SELECT * FROM user";
// echo "/* Executing query: $sql */\n";

$result = $conn->query($sql);

if (!$result) {
    die(json_encode(["error" => "Query failed: " . $conn->error]));
}

// echo "/* Query executed successfully */\n";

$users = array();
if ($result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        $users[] = $row;
    }
    // echo "/* Found " . count($users) . " users */\n";
} else {
    // echo "/* No users found */\n";
}

// Return a valid JSON array even if empty
$json_response = json_encode($users, JSON_PRETTY_PRINT);
if ($json_response === false) {
    die(json_encode(["error" => "JSON encoding failed: " . json_last_error_msg()]));
}

echo $json_response;

$conn->close();
?>
