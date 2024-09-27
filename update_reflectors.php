<?php
header('Content-Type: application/json');

$output = shell_exec('python3 update.py 2>&1');
if ($output === null) {
    echo json_encode(['status' => 'error', 'message' => 'Failed to execute script.']);
} else {
    echo json_encode(['status' => 'success', 'message' => 'Reflectors updated successfully!', 'output' => $output]);
}
?>
