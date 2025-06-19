<?php
include 'dbconnect.php';

$device_id   = $_POST['device_id'] ?? '';
$temperature = $_POST['temperature'] ?? '';
$humidity    = $_POST['humidity'] ?? '';
$water_level = $_POST['water_level'] ?? '';
$leak_status = isset($_POST['leak_status']) ? $_POST['leak_status'] : '';
$relay_state = $_POST['relay_state'] ?? '';

// Validate required fields
if (
  empty($device_id) || empty($temperature) || empty($humidity) ||
  empty($water_level) || $leak_status === '' || empty($relay_state)
) {
  echo "Missing required fields.";
  exit;
}

// Prepare and insert data
$sql = "INSERT INTO sensor_logs (device_id, temperature, humidity, water_level, leak_status, relay_state)
        VALUES (?, ?, ?, ?, ?, ?)";

$stmt = $conn->prepare($sql);
$stmt->bind_param("sdddss", $device_id, $temperature, $humidity, $water_level, $leak_status, $relay_state);

if ($stmt->execute()) {
  echo "Data inserted successfully.";
} else {
  echo "Error: " . $stmt->error;
}

$stmt->close();
$conn->close();
?>