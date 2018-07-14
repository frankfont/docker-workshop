<html>
    <head>
        <title>Hello PHP</title>
    </head>
    <body>
        <h1>Hello!</h1>
        <p>You are looking at the <strong><?php echo basename($_SERVER['SCRIPT_FILENAME']); ?></strong> page 
            on the <strong><?php echo gethostname(); ?></strong> server
            on the date of <strong><?php echo date('Y-m-d'); ?></strong></p>
        <ul>
            <li><a href="phpinfo.php">See PHP detail</a>
        </ul>
    </body>
</html>