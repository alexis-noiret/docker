<?php
mysqli_report(MYSQLI_REPORT_OFF);
$c = @new mysqli('db', 'app', 'app123', 'appdb');
echo "<h1>Alexis Noiret - stack LAMP Docker</h1>";
echo $c->connect_errno
    ? "<p>MariaDB : ERREUR " . $c->connect_error . "</p>"
    : "<p>MariaDB : connexion OK (version " . $c->server_info . ")</p>";
echo "<p>PHP " . phpversion() . "</p>";
