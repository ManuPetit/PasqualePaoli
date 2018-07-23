<?php

/* 
 * fichier pour créer la page infos
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
            <!-- PREMIER ROW DE LA PAGE -->
            <div class="row">
                <div class="boite">
                    <!-- ROW DU TITRE -->
                    <div class="span12 text-center">
                        <h1 class="marque">Pasquale Paoli</h1>
                        <hr>
                        <h2>
                            <small><strong><?php if (isset($traduction['info_header'])) echo $traduction['info_header']; ?></strong></small> 
                        </h2>   
                        <hr>
                    </div>
                    <!-- FIN de ROW DU TITRE -->
                    <!-- CARTE ET HORAIRES -->
                    <div class="col-md-8">
                        <div id="google_map"></div>
                    </div>
                    <div class="col-md-4">
                        <hr class="visible-xs visible-sm">
                        <h3><?php if (isset($traduction['footer_horaire_header'])) echo $traduction['footer_horaire_header']; ?></h3>
                        <?php Traduction::GetHorairesCell($_SESSION['language'], $traduction['horaire_ferme']); ?>
                        <p>&nbsp;</p>
                        <p class="montext"><?php if (isset($traduction['info_message1'])) echo $traduction['info_message1']; ?></p>
                        <p class="montext"><?php if (isset($traduction['info_message2'])) echo $traduction['info_message2']; ?></p>
                        <p class="montext"><?php if (isset($traduction['info_message3'])) echo $traduction['info_message3']; ?></p>
                    </div>
                    <!-- FIN de  CARTE ET HORAIRES -->                    
                </div>
            </div>
            <!-- FIN de PREMIER ROW DE LA PAGE -->
            <!-- DEUXIEME ROW DE LA PAGE -->
            <div class="row">
                <div class="boite">
                    <!-- ROW DU TITRE -->
                    <div class="span12 text-center">
                        <hr>
                        <h2>
                            <small><strong><?php if (isset($traduction['info_venir_header'])) echo $traduction['info_venir_header']; ?></strong></small> 
                        </h2>   
                        <hr>
                    </div>
                    <!-- FIN de ROW DU TITRE -->
                    <div class="col-xs-12 col-sm-6 col-md-3">
                        <div class="text-center">
                            <span class="fa-stack fa-3x">                            
                                <i class="fa fa-circle fa-stack-2x"></i>
                                <i class="fa fa-plane fa-stack-1x textwhite"></i>
                            </span>
                            <h3><?php if (isset($traduction['info_avion_header'])) echo $traduction['info_avion_header']; ?></h3>
                        </div>
                        <p class="transport"><?php if (isset($traduction['info_avion_mess1'])) echo $traduction['info_avion_mess1']; ?></p>
                        <p class="transport"><?php if (isset($traduction['info_avion_mess2'])) echo $traduction['info_avion_mess2']; ?></p>
                    </div>
                    <div class="col-xs-12 col-sm-6 col-md-3">
                        <hr class="visible-xs">                        
                        <div class="text-center">
                            <span class="fa-stack fa-3x">                            
                                <i class="fa fa-circle fa-stack-2x"></i>
                                <i class="fa fa-ship fa-stack-1x textwhite"></i>
                            </span>
                            <h3><?php if (isset($traduction['info_bateau_header'])) echo $traduction['info_bateau_header']; ?></h3>
                        </div>
                        <p class="transport"><?php if (isset($traduction['info_bateau_mess1'])) echo $traduction['info_bateau_mess1']; ?></p>
                        <p class="transport"><?php if (isset($traduction['info_bateau_mess2'])) echo $traduction['info_bateau_mess2']; ?></p>
                        <p class="transport"><?php if (isset($traduction['info_bateau_mess3'])) echo $traduction['info_bateau_mess3']; ?></p>
                    </div>
                    <div class="col-xs-12 col-sm-6 col-md-3">
                        <hr class="visible-xs visible-sm">                       
                        <div class="text-center">
                            <span class="fa-stack fa-3x">                            
                                <i class="fa fa-circle fa-stack-2x"></i>
                                <i class="fa fa-train fa-stack-1x textwhite"></i>
                            </span>
                            <h3><?php if (isset($traduction['info_train_header'])) echo $traduction['info_train_header']; ?></h3>
                        </div>
                        <p class="transport"><?php if (isset($traduction['info_train_mess1'])) echo $traduction['info_train_mess1']; ?></p>
                        <p class="transport"><?php if (isset($traduction['info_train_mess2'])) echo $traduction['info_train_mess2']; ?></p>
                    </div>
                    <div class="col-xs-12 col-sm-6 col-md-3">
                        <hr class="visible-xs visible-sm">                       
                        <div class="text-center">
                            <span class="fa-stack fa-3x">                            
                                <i class="fa fa-circle fa-stack-2x"></i>
                                <i class="fa fa-car fa-stack-1x textwhite"></i>
                            </span>
                            <h3><?php if (isset($traduction['info_auto_header'])) echo $traduction['info_auto_header']; ?></h3>
                        </div>
                        <p class="transport"><?php if (isset($traduction['info_auto_mess1'])) echo $traduction['info_auto_mess1']; ?></p>
                        <p class="transport"><?php if (isset($traduction['info_auto_mess2'])) echo $traduction['info_auto_mess2']; ?></p>
                    </div>
                    <p>&nbsp;</p>
                </div>
            </div>
            <!-- FIN de DEUXIEME ROW DE LA PAGE -->
        </div>
        <!-- FIN de CONTENU DE LA PAGE -->
<?php
include 'footer.php';