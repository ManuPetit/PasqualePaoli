<?php

/* 
 * fichier pour créer la page blog
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

//verification de la langue de session
if (!isset($_SESSION['language'])) {
    $_SESSION['language'] = 'fra';
}
//assigner le nom du fichier
//ici pour la partie blog on procède diférrement car il y a peut être du data à faire passer
$current_file = basename(__FILE__, '.php');
$current_content = $_SERVER['REQUEST_URI'];
$position=  strrpos( $current_content, "?");
if (isset($position)){
    $current_ext = substr($current_content, $position + 1);    
}

include 'header.php';
?>
        <!-- CONTENU DE LA PAGE -->
        <div class="container">
            <!-- PREMIER ROW DU SITE -->
            <div class="row">
                <div class="boite">
                    <!-- COLONNE DE GAUCHE -->       
                    <div class="col-md-8"> 
                        <div class="text-center">
                            <p class="visible-sm visible-xs">&nbsp;</p>
                            <h1 class="marque">Pasquale Paoli</h1>
                            <?php
                            // ici on choisi le fichier à inclure selon qu'il y a un paramètre dans l'URL
                            if (isset($_GET['bloid'])) {
                                $blogid = $_GET['bloid'];
                                include 'blogparid.php';
                            }
                            elseif (isset($_GET['catid'])){
                                $catid = $_GET['catid'];
                                include 'blogparcat.php';
                            }
                            else {
                                include 'bloggeneral.php';
                            }
                            ?>
                        
                    </div>
                    <!-- FIN de  COLONNE DE GAUCHE -->
                    <!-- COLONNE DE DROITE -->
                    <div class="col-md-4 extrapad">  
                        <?php
                        if (isset($traduction['blog_categorie_header'])) {
                            ?>
                        <!-- CATEGORIES DU BLOG -->
                        <div class="sidecolleft">                           
                            <hr class="lignecourt">
                            <h4 class="coltitre">
                                <strong><?php echo $traduction['blog_categorie_header']; ?></strong>
                            </h4>
                            <hr>
                            <?php
                            echo "<p>\n";
                            echo Blogger::GetBlogCategories($_SESSION['language']);
                        }
                            ?>
                            </p>
                        </div>
                        <!-- FIN de CATEGORIES DU BLOG -->  
                        <?php
                        if (isset($traduction['blog_dernier_comm_header'])){
                            ?>                        
                        <!-- DERNIERS COMMENTAIRES DU BLOG -->  
                        <!--
                                    FONCTIONNALITE QUI DOIT ËTRE IMPLEMENTEE
                        -->
                        <div class="sidecolleft">                           
                            <hr class="lignecourt lignespace">
                            <h4 class="coltitre">
                                <strong>Derniers Commentaires</strong>
                            </h4>
                            <hr>
                        </div>
                        <!-- FIN de DERNIERS COMMENTAIRES DU BLOG --> 
                        <?php
                        }
                        if (isset($traduction['blog_archive_header']))   {
                        ?>                                   
                        <!-- ARCHIVES DU BLOG -->     
                        <div class="sidecolleft">                           
                            <hr class="lignecourt lignespace">
                            <h4 class="coltitre">
                                <strong>Archives</strong>
                            </h4>
                            <hr>
                        </div>
                        <nav class="nav">
                        <?php 
                        echo "\t";
                        echo '<ul class="metisFolder">';
                        echo "\n";
                        $archives = Blogger::GetArchives($_SESSION['language']);
                        //création d'une array pour storer les années et mois
                        $menu=array();
                        //arrays pour compter le nombre de posts
                        $nbre_an=array();
                        $nbre_mois=array();
                        foreach ($archives as $v){
                            $year=$v['annee'];
                            $mois=$v['mois'];
                            $menu[$year][$mois][]=$v;
                            //ajouter le nombre de post au mois et année
                            if (isset($nbre_an[$year])){
                                $nbre_an[$year]++;
                            }
                            else {
                                $nbre_an[$year]=1;
                            }
                            if (isset($nbre_mois[$year][$mois])){
                                $nbre_mois[$year][$mois]++;
                            }
                            else{
                                $nbre_mois[$year][$mois]=1;
                            }
                                
                        }
                        //2 flag pour activer la première année et le premier mois
                        $flag_active_an=FALSE;
                        $flag_active_mois=FALSE;
                        //maintenant on boucle les anneés et les mois pour créer le menu
                        foreach ($menu as $_year=>$_months){
                           echo "\t\t\t\t\t\t\t\t<li";
                           if ($flag_active_an == FALSE){
                               //on vérifie si c'est la premiere année pour mettre la classe active
                               echo ' class="active"';
                               $flag_active_an = TRUE;
                           }
                           echo ">\n\t\t\t\t\t\t\t\t\t";
                           echo '<a href="#">';
                           echo "\n\t\t\t\t\t\t\t\t\t\t";
                           echo '<span class="fa fa-caret-right"></span>';
                           echo "\n\t\t\t\t\t\t\t\t\t\t" . $_year ." (". $nbre_an[$_year] . ") \n\t\t\t\t\t\t\t\t\t";
                           echo "</a>\n\t\t\t\t\t\t\t\t\t<ul>\n";
                            //boucle pour les mois
                            foreach ($_months as $_month=>$_entries){
                                echo "\t\t\t\t\t\t\t\t\t\t<li";
                                if ($flag_active_mois == FALSE){
                                    //on ajoute active à ce mois
                                    echo ' class="active"';
                                    $flag_active_mois = TRUE;
                                }
                                echo ">\n\t\t\t\t\t\t\t\t\t\t\t";
                                echo '<a href="#">';
                                echo "\n\t\t\t\t\t\t\t\t\t\t\t\t";
                                echo '<span class="fa fa-caret-right"></span>';
                                echo "\n\t\t\t\t\t\t\t\t\t\t\t\t" . ucfirst($_entries[0]['traduction']) . " (" . $nbre_mois[$_year][$_month] .") \n\t\t\t\t\t\t\t\t\t\t\t";
                                echo "</a>\n\t\t\t\t\t\t\t\t\t\t\t<ul>\n";
                                foreach ($_entries as $_entrie){
                                    echo "\t\t\t\t\t\t\t\t\t\t\t\t<li>\n\t\t\t\t\t\t\t\t\t\t\t\t\t";
                                    echo '<a href="blog.php?bloid='.$_entrie['id_post'] . '" title="'. $_entrie['lien']. '">';
                                    echo "\n\t\t\t\t\t\t\t\t\t\t\t\t\t\t".$_entrie['titre']."\n\t\t\t\t\t\t\t\t\t\t\t\t\t</a>";
                                    echo "\n\t\t\t\t\t\t\t\t\t\t\t\t</li>\n";
                                }
                            echo "\t\t\t\t\t\t\t\t\t\t\t</ul>\n\t\t\t\t\t\t\t\t\t\t</li>\n";
                            }
                        echo "\t\t\t\t\t\t\t\t\t</ul>\n\t\t\t\t\t\t\t\t</li>\n";
                        }
                        echo "\t\t\t\t\t\t\t</ul>\n\t\t\t\t\t\t</nav>\n";
                        ?>
                        <!-- FIN de ARCHIVES DU BLOG --> 
                    </div>     
                    <!-- FIN de COLONNE DE GAUCHE -->
                    
                    
                </div>            
            <!-- FIN DE PREMIER ROW DU SITE -->
        </div>
        <!-- FIN de CONTENU DE LA PAGE -->
        </div>
                    <?php
                    
                        } 
                     
                        
include 'footer.php';