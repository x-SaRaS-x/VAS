<?php
   $json = $_POST['json'];
   $filename = uniqid(rand(), true) . '.json';

   $file = fopen('data/' . $filename,'w+');
   fwrite($file, $json);
   fclose($file);
?>