<?php
// Check if the custom_reflectors.txt file exists; if not, create it
$custom_reflector_file = 'custom_reflectors.txt';
if (!file_exists($custom_reflector_file)) {
    file_put_contents($custom_reflector_file, ""); // Create an empty file
}

$message = ''; // Initialize message variable

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $designator = $_POST['designator'] ?? '';
    $sponsor = $_POST['sponsor'] ?? '';
    $ip_address = $_POST['ip_address'] ?? '';
    $country = $_POST['country'] ?? '';
    $url = $_POST['url'] ?? '';

    if ($designator && $sponsor && $ip_address && $country && $url) {
        $new_reflector = "{$designator} - {$sponsor} ({$ip_address}) - Country: {$country} - URL: {$url}\n";
        file_put_contents($custom_reflector_file, $new_reflector, FILE_APPEND | LOCK_EX);
        $message = "Custom reflector added successfully!";
    } else {
        $message = "Please fill in all fields.";
    }
}
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Add Custom Reflector</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 20px;
            background-color: black;
            color: white;
            display: flex;
            flex-direction: column;
            align-items: center;
        }
        input, button {
            margin: 10px;
            padding: 8px;
            width: 300px;
        }
        button {
            background-color: #00ff00;
            border: none;
            cursor: pointer;
        }
        button:hover {
            background-color: #008000;
        }
    </style>
</head>
<body>
    <h1>Add Custom Reflector</h1>
    <?php if ($message): ?>
        <p><?php echo $message; ?></p>
    <?php endif; ?>
    <form method="POST" action="">
        <input type="text" name="designator" placeholder="Reflector Designator (e.g., M17-000)" required>
        <input type="text" name="sponsor" placeholder="Sponsor" required>
        <input type="text" name="ip_address" placeholder="IP Address" required>
        <input type="text" name="country" placeholder="Country" required>
        <input type="text" name="url" placeholder="URL" required>
        <button type="submit">Add Reflector</button>
    </form>
    <button onclick="location.href='index.html'">Back to Main</button>
</body>
</html>
