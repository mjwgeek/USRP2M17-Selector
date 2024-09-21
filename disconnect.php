<?php
header('Content-Type: application/json');

$ini_file_path = '/opt/USRP2M17/USRP2M17.ini';

// Build the new INI contents to disconnect
$new_ini_contents = "[M17 Network]\n";
$new_ini_contents .= "Callsign=DISCONNECT\n"; // Set Callsign to DISCONNECT
$new_ini_contents .= "Address=DISCONNECT\n"; // Set Address to 0.0.0.0
$new_ini_contents .= "Name=DISCONNECT\n"; // Set Name to DISCONNECT
$new_ini_contents .= "LocalPort=32010\n";
$new_ini_contents .= "DstPort=17000\n";
$new_ini_contents .= "GainAdjustdB=3\n";
$new_ini_contents .= "Daemon=1\n";
$new_ini_contents .= "Debug=1\n";
$new_ini_contents .= "[USRP Network]\n";
$new_ini_contents .= "Address=127.0.0.1\n"; // Keep this fixed
$new_ini_contents .= "DstPort=32008\n";
$new_ini_contents .= "LocalPort=34008\n";
$new_ini_contents .= "GainAdjustdB=3\n";
$new_ini_contents .= "Debug=1\n";
$new_ini_contents .= "[Log]\n";
$new_ini_contents .= "DisplayLevel=0\n";
$new_ini_contents .= "FileLevel=1\n";
$new_ini_contents .= "FilePath=/var/log/usrp/\n";
$new_ini_contents .= "FileRoot=USRP2M17\n";

// Write the new content back to the INI file
file_put_contents($ini_file_path, $new_ini_contents);

// Restart the service
exec('sudo systemctl restart usrp2m17', $output, $return_var);

// Check if the service restart was successful
if ($return_var !== 0) {
    echo json_encode(['error' => 'Failed to restart service', 'output' => $output]);
} else {
    echo json_encode(['message' => 'Service restarted successfully']);
}
?>
