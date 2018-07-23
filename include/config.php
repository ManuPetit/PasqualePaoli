<?php

/*
 * fichier de configuration du site
 */


/*
 * 
 *              ATTENTION CONSULTER FICHIER __IMPORTANT AVANT D'ALLER LIVE
 * 
 */

//DOSSIERS ET CHEMIN D'ACCES
//racine du site
define('SITE_ROOT', dirname(dirname(__FILE__)));
//dossiers de l'application
define('BUSINESS_DIR', SITE_ROOT . '/business/');
define('CSS_DIR', SITE_ROOT . '/css/');
define('FONTS_DIR', SITE_ROOT . '/fonts/');
//define('IMAGES_DIR', SITE_ROOT . '/images/');
//define('IMAGES_DIR', 'http://localhost/paoli/ppaoli/images/');
define('JSCRIPT_DIR', SITE_ROOT . '/js/');

//pour les messages
mb_internal_encoding('UTF-8');

//TRAITEMENT DES ERREURS
//
//doit être vrai lors du développement du site
define('IS_WARNING_FATAL', FALSE);
define('DEBUGGING', FALSE);

//types d'erreurs à reporter
define('ERROR_TYPES', E_ALL);

//Email du restaurant
define('EMAIL_PRINCIPALE', 'restaurant.upasqualepaoli@orange.fr');
//settings pour envoyer un message d'erreur
define('SEND_ERROR_MAIL', TRUE);
define('ADMIN_ERROR_MAIL', 'e.petit18@laposte.net');
define('SENDMAIL_FROM', 'errors@pasqualepaoli.com');
ini_set('sendmail_from', SENDMAIL_FROM);

//par default les erreurs ne sont pas enregistrées
define('LOG_ERRORS', TRUE);
define('LOG_ERRORS_FILE', SITE_ROOT .'/meslogs/errors_log.txt'); 
//message géneric d'erreur sur le site
define('SITE_GENERIC_ERROR_MESSAGE', '<p class="text-danger">Erreur du système.<br>Veuillez essayer plus tard.</p>');

//BASE DE DONNEES
//
//constantes pour se connecter à la base de données
define('DB_PERSISTENCY', 'true');
define('DB_SERVER', 'db621031148.db.1and1.com');
define('DB_USERNAME', 'dbo621031148');
define('DB_PASSWORD', '45opMp0OB8');
define('DB_DATABASE', 'db621031148');
define('DB_CHARSET', 'utf8');
define('PDO_DSN', 'mysql:host=' . DB_SERVER . ';dbname=' . DB_DATABASE . ';charset=' . DB_CHARSET);
