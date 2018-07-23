<?php

/*
 * fichier pour créer la page index
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
require_once BUSINESS_DIR . 'Blogger.php';
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
			<!-- OUVERTURE DU SITE -->
			<?php
			//on affiche un message de bienvenue sur la page index
			if (isset($traduction['message_page_index'])) {
			?>
			<div class="row">
				<div class="boite">
					<h3 class="text-center"><small><strong>
						<?php echo $traduction['message_page_index']; ?>
					</strong></small></h3>
				</div>
			</div>
			<?php } ?>
            <!-- PREMIER ROW DU SITE -->
            <div class="row">
                <div class="boite">
                    <?php
                    //on va verifié si au moins une des catégories de gauche est prête
                    if ((isset($traduction['header_nosmenus'])) || (isset($traduction['header_nosactus'])) || (isset($traduction['header_nosblog'])) ){
                        //on peut créer la colonne de gauche
                        echo '<!-- COLONNE DE GAUCHE -->';
                        echo "\n\t\t\t\t\t<div class=";
                        echo '"col-md-4 extrapad">';
                        echo "\n\t\t\t\t\t\t";
                        echo '<div class="sidecolleft">';
                        echo "\n";
                        //variable pour savoir si il faudra ajouter un espace supplémentaire
                        $space_hr = 0;
                        //section menus
                        if (isset($traduction['header_nosmenus'])){
                            //affichage de nos menus
                            echo "\t\t\t\t\t\t\t";
                            echo '<hr class="lignecourt">';
                            echo "\n\t\t\t\t\t\t\t";
                            echo '<h4 class="coltitre">';
                            echo "\n\t\t\t\t\t\t\t\t";
                            echo '<strong>'.$traduction['header_nosmenus'].'</strong>';
                            echo "\n\t\t\t\t\t\t\t";
                            echo '</h4>';
                            echo "\n\t\t\t\t\t\t\t";
                            echo '<hr>';
                            echo "\n\t\t\t\t\t\t\t";
                            echo '<div class="mysidecol">';
                            echo "\n";
                            echo Navigation::GetSideMenuLien($_SESSION['language']);
                            //augmentation du compteur
                            $space_hr++;
                        }
                        //section actu
                        if (isset($traduction['header_nosactus']))
                        {
                            echo "\t\t\t\t\t\t\t";
                            echo '<hr class="lignecourt';
                            //vérifier si il faut ajouter une ligne d'espace sur le hr
                            if ($space_hr>0) {
                                echo ' lignespace';
                            }
                            echo '">';
                            echo "\n\t\t\t\t\t\t\t";
                            echo '<h4 class="coltitre">';
                            echo "\n\t\t\t\t\t\t\t\t<strong>" . $traduction['header_nosactus']. "</strong>\n\t\t\t\t\t\t\t";
                            echo "</h4>\n\t\t\t\t\t\t\t<hr>\n\t\t\t\t\t\t\t";
                            echo '<div class="mysidecol">';
                            echo "\n";
                            echo Navigation::GetSideActuLien($_SESSION['language']);
                            //augmentation du compteur
                            $space_hr++;
                        }
                        //section blog
                        if (isset($traduction['header_nosblog'])){
                            //implementation du blog
                            echo "\t\t\t\t\t\t\t";
                            echo '<hr class="lignecourt';
                            //vérifier si il faut ajouter une ligne d'espace sur le hr
                            if ($space_hr>0) {
                                echo ' lignespace';
                            }
                            echo '">';                            
                            echo "\n\t\t\t\t\t\t\t";
                            echo '<h4 class="coltitre">';
                            echo "\n\t\t\t\t\t\t\t\t<strong>" . $traduction['header_nosblog']. "</strong>\n\t\t\t\t\t\t\t";
                            echo "</h4>\n\t\t\t\t\t\t\t<hr>\n";
                            echo Blogger::GetGreationDernierPost($_SESSION['language']);
                        }
                        echo "\t\t\t\t\t\t</div>\n\t\t\t\t\t</div>\n\t\t\t\t\t<!-- FIN de COLONNE DE GAUCHE -->";
                        // ici on commence la colonne de droite
                        echo "\n\t\t\t\t\t<!-- COLONNE DE DROITE -->\n\t\t\t\t\t";
                        echo '<div class="col-md-8 text-center">';
                        echo "\n";
                    }
                    else {
                        //il n'y a rien à gauche donc on fait une colonne de 12
                        echo "\n\t\t\t\t\t<!-- COLONNE DE DROITE -->\n\t\t\t\t\t";
                        echo '<div class="col-lg-12 text-center">';
                        echo "\n";
                    }
                    ?>
                        <h2 class="welcome">
                            <small><?php if (isset($traduction['bienvenue_index'])) echo $traduction['bienvenue_index']; ?></small>
                        </h2>
                        <h1 class="marque">Pasquale Paoli</h1>
                        <hr>
                        <h2>
                            <small><strong><?php if (isset($traduction['sstitre_index'])) echo $traduction['sstitre_index']; ?></strong></small> 
                        </h2>  
                        <?php 
                        $mess = Imagerie::GetCarrouselSlider($_SESSION['language']); 
                        if (isset($mess)){
                            echo "<hr>\n";
                            echo $mess;
                        }
                        ?>
                        <p>&nbsp;</p>
                        <hr>
                        <p class="milieu"><?php if (isset($traduction['intro_index'])) echo $traduction['intro_index']; ?></p>
                        <hr>
                        <?php 
                            if (isset($traduction['intro_horaire'])) {
                                echo '<p class="milieu">' . $traduction['intro_horaire'] . '</p><hr>';
                            }
                        ?>
                    </div>
                    <!-- FIN de COLONNE DE DROITE -->
                </div>                
            </div>            
            <!-- FIN DE PREMIER ROW DU SITE -->
            <!-- DEUXIEME ROW DU SITE -->
            <div class="row">
                <div class="boite">
                    <div class="col-lg-12">
                        <hr>
                        <h2 class="intro-texte text-center">
                            <strong><?php if (isset($traduction['header_notre_etab'])) echo $traduction['header_notre_etab']; ?></strong>
                        </h2>
                        <hr>
                        <img class="img-responsive img-bord image-gauche" src="images/common/intro.jpg" alt="<?php if (isset($traduction['alt_image_notre_etab'])) echo $traduction['alt_image_notre_etab']; ?>">
                        <hr class="visible-xs visible-sm">
                        <p><?php if (isset($traduction['notre_etab_para1'])) echo $traduction['notre_etab_para1']; ?></p>
                        <p><?php if (isset($traduction['notre_etab_para2'])) echo $traduction['notre_etab_para2']; ?></p>
                    </div>
                </div>
            </div>
            <!-- FIN de DEUXIEME ROW DU SITE -->
        </div>
        <!-- FIN de CONTENU DE LA PAGE -->
<?php
include 'footer.php';
