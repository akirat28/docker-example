<?php
echo "<h1>Docker PHP Environment</h1>";
echo "<p>PHP version: " . phpversion() . "</p>";
echo "<p>Current time: " . date('Y-m-d H:i:s') . "</p>";

// MySQLの接続テスト
try {
    $pdo = new PDO('mysql:host=mysql;dbname=testdb', 'testuser', 'testpassword');
    echo "<p style='color: green;'>MySQL connection: SUCCESS</p>";
} catch (PDOException $e) {
    echo "<p style='color: red;'>MySQL connection: FAILED - " . $e->getMessage() . "</p>";
}

phpinfo();
?>