<?php

/* 
 * fichier de création dla page plan
 */
session_start();
//mettre les fichiers inclus
require_once 'include/config.php';
require_once BUSINESS_DIR . 'ErrorHandler.php';
// Mettre en route le manager d'erreurs
ErrorHandler::SetHandler();
//autres fichiers requis
require_once BUSINESS_DIR . 'DatabaseHandler.php';
require_once BUSINESS_DIR . 'Langue.php';
require_once BUSINESS_DIR . 'Traduction.php';
require_once BUSINESS_DIR . 'Navigation.php';

//verification de la langue de session
if (!isset($_SESSION['language'])) {
    $_SESSION['language'] = 'fra';
}
//assigner le nom du fichier
$current_file = basename(__FILE__, '.php');


include 'header.php';
?>
        <!-- CONTENU DE LA PAGE -->
        <div class="container">
            <!-- ROW DU SITE -->
            <div class="row">
                <div class="boite">
                    <!-- ROW DU TITRE -->
                    <div class="span12 text-center">
                        <h1 class="marque">Pasquale Paoli</h1>
                        <hr>
                        <h2>
                            <small><strong><?php if (isset($traduction['sitemap_header'])) echo $traduction['sitemap_header']; ?></strong></small> 
                        </h2>   
                        <hr>
                    </div>
                    <!-- FIN de ROW DU TITRE --> 
                    <!-- PLAN DU SITE -->
                    <div class="span12">
                        <p><?php if (isset($traduction['sitemap_intro'])) echo $traduction['sitemap_intro']; ?></p>
                    </div>
                    <div class="span12">
                        <ul>
<?php 
Navigation::GetSiteMap($_SESSION['language']); 
echo "\t\t\t\t\t\t\t<li>\n\t\t\t\t\t\t\t\t";
echo '<a href="mentions.php" title="'.$traduction['footer_mention_legal'].'">'.$traduction['footer_mention_legal'].'</a>';
echo "\n\t\t\t\t\t\t\t</li>\n\t\t\t\t\t\t\t<li>\n\t\t\t\t\t\t\t\t";
echo '<a href="mentions.php" title="'.$traduction['footer_site_map'].'">'.$traduction['footer_site_map'].'</a>';
echo "\n\t\t\t\t\t\t\t</li>\n";
?>
                        </ul>
                    </div>
                    <!-- FIN de PLAN DU SITE -->                    
                    <p>&nbsp;</p>
                </div>                
            </div>            
            <!-- FIN de ROW DU SITE -->          
        </div>
        <!-- FIN de CONTENU DE LA PAGE -->
<?php
include 'footer.php';