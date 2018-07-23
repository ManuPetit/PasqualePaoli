<?php

/* 
 * affiche la formule du midi
 */
session_start();
//mettre les fichiers inclus
require_once '../include/config.php';
require_once BUSINESS_DIR . 'ErrorHandler.php';
// Mettre en route le manager d'erreurs
ErrorHandler::SetHandler();
//autres fichiers requis
require_once BUSINESS_DIR . 'DatabaseHandler.php';
//verification de la langue de session
if (!isset($_SESSION['language'])) {
    $_SESSION['language'] = 'fra';
}
$thisfile=basename(__FILE__,'.php');
$mapage=array();

//retrouver l'ensemble des données pour cette page
$sql = 'CALL sel_MenusActus(:langue,:fichier)';
$params = array(':langue' => $_SESSION['language'], ':fichier' => $thisfile);
$resultpage = DatabaseHandler::GetAll($sql, $params);
foreach ($resultpage as $r){
    if ($r['typetrad'] == 'head'){
        $mapage['head']=$r['traduction'];
    }
    if ($r['typetrad'] == 'body'){
        $mapage['body']=$r['traduction'];
    }
    if ($r['typetrad'] == 'foot'){
        $mapage['foot']=$r['traduction'];
    }
}
//affichage des résultats
echo $mapage['head'];
echo $mapage['body'];
echo $mapage['foot'];