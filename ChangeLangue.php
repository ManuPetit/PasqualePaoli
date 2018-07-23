<?php

/*
 * ce fichier permet de changer la langue du site
 * 
 */
//start la session
session_start();

//fichier de configuration
require_once 'include/config.php';
require_once BUSINESS_DIR . 'DatabaseHandler.php';
require_once BUSINESS_DIR . 'Langue.php';

//par defaut le language est français
$langue = 'fra';
//par defaut le fichier est index
$file = 'index';
//array contenant les fichiers du site
$file_liste = array('index', 'media', 'blog', 'infos', 'contact', 'mentions', 'plan');

//on vérifie que l'on a bien une langue
if ((isset($_GET['lan'])) && (strlen($_GET['lan']) == 3)) {
    $langue = $_GET['lan'];
    //on vérifie l'existence de la langue
    if (langue::IsLangueValid($langue) == FALSE) {
        //on affecte le français comme langue
        $langue = 'fra';
    }
}
//on vérifie ue l'on a également un fichier et qu'il est valide
if ((isset($_GET['fic'])) && (strlen($_GET['fic']) >= 3) && (in_array($_GET['fic'], $file_liste))) {
    $file = $_GET['fic'];
}
//on vérifie l'existence de l'extension pour le blog
if (isset($_GET['bloid'])) {
    //on vérifie l'existence du post
    if (Langue::IsPostValid($_GET['bloid'])==TRUE){
        $extend = "?bloid=".$_GET['bloid'];
    }
}
//on vérifie l'existence de categorie pour le blog
if (isset($_GET['catid'])){
    //on vérifie l'existence de cette catégorie
    if (Langue::IsCategorieValid($_GET['catid'])==TRUE){
        $extend = "?catid=".$_GET['catid'];
    }
}
//assigner la langue à sa variable de session
$_SESSION['language'] = $langue;

//rediriger à la page
$redirect = $file . '.php';
if (isset($extend)){
    $redirect.=$extend;
}
header("Location:$redirect");
exit();
?>