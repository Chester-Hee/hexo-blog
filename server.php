<?php

include "include.inc";

try {
    $response = run_request('127.0.0.1', '9000');
    echo "IPv4 ok\n";
    var_dump($response);
} catch (Exception $e) {
    echo "IPv4 error\n";
    var_dump($response);
}
