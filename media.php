<?php

/* 
 * fichier pour créer la page media
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
require_once BUSINESS_DIR . 'Imagerie.php';

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
                            <small><strong><?php if (isset($traduction['header_media'])) echo $traduction['header_media']; ?></strong></small> 
                        </h2>   
                        <hr>
                    </div>
                    <!-- FIN de ROW DU TITRE --> 
                    <!-- GALERIE -->
                    <div class="span12">
                        <ul class="tiles-wrap">  
                            <?php                          
                            echo "<!-- GRILLE MEDIAS -->\n";
                            $resultat=  Imagerie::GetGalerieDetail($_SESSION['language']);
                            foreach ($resultat as $v){
                                echo "\t\t\t\t\t\t\t<li>\n\t\t\t\t\t\t\t\t";
                                echo '<a href="images/media/'.$v['fichier'].'" rel="prettyPhoto[gal1]" title="'.$v['titre'].'">';
                                echo "\n\t\t\t\t\t\t\t\t\t";
                                echo '<img src="images/media/'.$v['thumb'].'" width="'.$v['width'].'" height="'.$v['height'].'" alt="'.$v['alt'].'">';
                                echo "\n\t\t\t\t\t\t\t\t</a>\n";
                                //ici on vérifie qu'il y a le reste du texte à afficher sys_variable : affiche_legende_galerie = 1
                                //pour cela on regarde si l'index header exists
                                if (isset($v['header'])) {
                                    echo "\t\t\t\t\t\t\t\t<h3>".$v['header']."</h3>\n\t\t\t\t\t\t\t\t<p>".$v['texte']."</p>\n";
                                    echo "\t\t\t\t\t\t\t\t<i>".$v['ladate']."</i>\n";
                                }
                                echo "\t\t\t\t\t\t\t</li>\n";
                            }
                            echo "\t\t\t\t\t\t\t<!-- FIN de GRILLE MEDIAS -->\n";
                            ?>
                         </ul>
                    </div>
                    <!-- FIN de GALERIE -->  
                    <p>&nbsp;</p>
                </div>                
            </div>            
            <!-- FIN de ROW DU SITE -->          
        </div>
        <!-- FIN de CONTENU DE LA PAGE -->
<?php
include 'footer.php';
