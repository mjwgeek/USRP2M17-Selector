<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);


header('Content-Type: application/json');

$ini_file_path = '/opt/USRP2M17/USRP2M17.ini';
$ini_contents = parse_ini_file($ini_file_path, true);

if ($ini_contents === false) {
    echo json_encode(['error' => 'Failed to read INI file']);
    exit;
}

$reflector_name = $ini_contents['M17 Network']['Name'] ?? 'N/A';
$ip_address = $ini_contents['M17 Network']['Address'] ?? 'N/A';
$callsign = $ini_contents['M17 Network']['Callsign'] ?? 'N/A';

echo json_encode([
    'reflector_name' => $reflector_name,
    'ip_address' => $ip_address,
    'callsign' => $callsign,
]);
?>
