<?php
// DB config
$host = "localhost";
$dbname = "tensorfl_sensohydro";
$username = "tensorfl_inas";
$password = "#mUKHINSHRI26#";

// Create connection
$conn = new mysqli($host, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
  die("Connection failed: " . $conn->connect_error);
}
?>
