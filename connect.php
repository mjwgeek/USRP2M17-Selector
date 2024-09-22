<?php
header('Content-Type: application/json');

// Get input data
$input = file_get_contents('php://input');
$data = json_decode($input, true);

$reflector = $data['reflector'];
$module = $data['module'];

$ini_file_path = '/opt/USRP2M17/USRP2M17.ini';
$reflector_options_path = '/var/www/html/m17/reflector_options.txt';

// Fetch the IP address from the reflector options file
$ip_address = null;
$reflector_options = file($reflector_options_path, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
foreach ($reflector_options as $line) {
    if (strpos($line, $reflector) === 0) {
        preg_match('/\((.*?)\)/', $line, $matches);
        $ip_address = $matches[1] ?? null;
        break;
    }
}

if ($ip_address === null) {
    echo json_encode(['error' => 'IP address not found for selected reflector']);
    exit;
}

// Build the new INI contents from the template
$new_ini_contents = "[M17 Network]\n";
$new_ini_contents .= "Callsign=CHANGEME {$module}\n"; // Update Callsign
$new_ini_contents .= "Address={$ip_address}\n"; // Update Address
$new_ini_contents .= "Name={$reflector} {$module}\n"; // Update Name
$new_ini_contents .= "LocalPort=32010\n";
$new_ini_contents .= "DstPort=17000\n";
$new_ini_contents .= "GainAdjustdB=3\n";
$new_ini_contents .= "Daemon=1\n";
$new_ini_contents .= "Debug=0\n";
$new_ini_contents .= "[USRP Network]\n";
$new_ini_contents .= "Address=127.0.0.1\n"; // Keep this fixed
$new_ini_contents .= "DstPort=32008\n";
$new_ini_contents .= "LocalPort=34008\n";
$new_ini_contents .= "GainAdjustdB=3\n";
$new_ini_contents .= "Debug=0\n";
$new_ini_contents .= "[Log]\n";
$new_ini_contents .= "DisplayLevel=0\n";
$new_ini_contents .= "FileLevel=1\n";
$new_ini_contents .= "FilePath=/var/log/usrp/\n";
$new_ini_contents .= "FileRoot=USRP2M17\n";

// Write the new content back to the INI file
if (file_put_contents($ini_file_path, $new_ini_contents) === false) {
    echo json_encode(['error' => 'Failed to write to INI file']);
    exit;
}

// Restart the service
exec('sudo systemctl restart usrp2m17', $output, $return_var);

// Check if the service restart was successful
if ($return_var !== 0) {
    echo json_encode(['error' => 'Failed to restart service', 'output' => $output]);
} else {
    echo json_encode(['message' => 'Service restarted successfully']);
}
?>
