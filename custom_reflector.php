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
    <script>
        function checkFields() {
            const designator = document.querySelector('input[name="designator"]').value;
            const sponsor = document.querySelector('input[name="sponsor"]').value;
            const ip_address = document.querySelector('input[name="ip_address"]').value;
            const country = document.querySelector('input[name="country"]').value;
            const url = document.querySelector('input[name="url"]').value;

            const submitButton = document.querySelector('button[type="submit"]');

            // Enable the button only if all fields are filled
            submitButton.disabled = !(designator && sponsor && ip_address && country && url);
        }

        window.onload = function() {
            // Check fields initially and on input
            const inputs = document.querySelectorAll('input');
            inputs.forEach(input => {
                input.addEventListener('input', checkFields);
            });
            checkFields(); // Initial check
        };
    </script>
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
        <button type="submit" disabled>Add Reflector</button> <!-- Initially disabled -->
    </form>
    <button onclick="location.href='index.html'">Back to Main</button>
</body>
</html>
