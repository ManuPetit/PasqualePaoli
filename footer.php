<?php

/* 
 * fichier créant le pied de page
 */
?>
        <!-- PIED DE PAGE -->                
        <footer role="contentinfo">
            <div class="container">
                <div class="row">
                    <div class="col-sm-4">
                        <h3><?php if (isset($traduction['footer_notre_etab_header'])) echo $traduction['footer_notre_etab_header']; ?></h3>
                        <p><?php if (isset($traduction['footer_notre_etab'])) echo $traduction['footer_notre_etab']; ?><br><br>
                            <a href="mentions.php" title="<?php if (isset($traduction['footer_mention_legal'])) echo $traduction['footer_mention_legal']; ?>"><?php if (isset($traduction['footer_mention_legal'])) echo $traduction['footer_mention_legal']; ?></a><br />
                            <a href="plan.php" title="<?php if (isset($traduction['footer_site_map'])) echo $traduction['footer_site_map']; ?>"><?php if (isset($traduction['footer_site_map'])) echo $traduction['footer_site_map']; ?></a>
                        </p>
                        <p><em><?php if (isset($traduction['footer_abus_alcool'])) echo $traduction['footer_abus_alcool']; ?></em><br></p>
                    </div>
                    <div class="col-sm-4">
                        <h3><?php if (isset($traduction['footer_horaire_header'])) echo $traduction['footer_horaire_header']; ?></h3> 
                        <?php Traduction::GetHorairesCell($_SESSION['language'], $traduction['horaire_ferme']); ?>
                    </div>
                    <div class="col-sm-4">
                        <h3><?php if (isset($traduction['footer_contactez_nous'])) echo $traduction['footer_contactez_nous']; ?></h3>  
                        <ul class="contacts">
                            <li>                                    
                                <i class="fa fa-phone icon"></i>
                                <span class="field"><?php if (isset($traduction['footer_telephone'])) echo $traduction['footer_telephone']; ?> :</span>
                                <br />
                                <?php if (isset($traduction['numero_telephone'])) echo $traduction['numero_telephone']; ?>                                                                      
                            </li>
                            <li>
                                <i class="fa fa-envelope icon"></i>
                                <span class="field"><?php if (isset($traduction['footer_email'])) echo $traduction['footer_email']; ?> :</span>
                                <br />
                                <a href="mailto:restaurant.upasqualepaoli@orange.fr" title="Email">restaurant.upasqualepaoli@orange.fr</a>
                            </li>
                            <li>
                                <i class="fa fa-home icon" style="margin-bottom:50px"></i>
                                <span class="field"><?php if (isset($traduction['footer_adresse'])) echo $traduction['footer_adresse']; ?> :</span>
                                <br />
                                2, Place Paoli<br />
                                20220 L'Ile Rousse<br />
                                Corse
                            </li>
                        </ul>
                    </div>
                </div>
                <div class="row">
                    <div class="col-lg-12">
                        <p>Copyright &copy; SARL U Pasquale Paoli 2016<br>
                            <a href="https://www.facebook.com/UPasqualePaoli/" title="facebook" class="socialspace"><span class="fa fa-facebook-official"></span> Facebook</a> 
                            <!-- Partie de TWITTER
                            <a href="#" title="twitter" class="socialspace"><span class="fa fa-twitter"></span> Twitter</a>
                            -->
                        </p>
                        <p>&nbsp;</p>
                    </div>
                </div>
            </div>
        </footer>
        <!-- FIN de PIED DE PAGE -->
        <!-- Bootstrap core JavaScript
        ================================================== -->
        <!-- Placed at the end of the document so the pages load faster -->
        <script src="js/jquery.min.js"></script>
        <script src="js/bootstrap.min.js"></script>
        <!-- IE10 viewport hack for Surface/desktop Windows 8 bug -->
        <script src="js/ie10-viewport-bug-workaround.js"></script>
        <?php
        //javascript à ajouter selon la page
        if ($current_file=='index'){
            echo "<!-- mise en route du Carousel -->\n\t\t<script type=\"text/javascript\">\n\t\t\t$('.carousel').carousel({\n";
            echo "\t\t\t\t interval: 4000 //changes the speed\n\t\t\t})\n\t\t</script>\n";
        }
        elseif ($current_file=='media'){
            echo "<!-- mise en place du script pour faire la galerie responsive -->\n\t\t<script src=\"js/wookmark.js\" type=\"text/javascript\"></script>\n";
            echo "\t\t<!-- Once the page is loaded, initalize the plug-in. -->\n\t\t<script type=\"text/javascript\">\n";
            echo "\t\t\t(function ($) {\n\t\t\t\tvar wookmark = $('.tiles-wrap').wookmark({\n";
            echo "\t\t\t\t\t// Prepare layout options.\n\t\t\t\t\tautoResize: true, // This will auto-update the layout when the browser window is resized.\n";
            echo "\t\t\t\t\toffset: 10, // Optional, the distance between grid items\n\t\t\t\t\touterOffset: 10, // Optional, the distance to the containers border\n";
            echo "\t\t\t\t\titemWidth: 210 // Optional, the width of a grid item\n\t\t\t\t});\n\t\t\t})(jQuery);\n\t\t</script>\n";
            echo "\t\t<!-- ajout pour prettyPhoto -->\n\t\t<script src=\"js/jquery.prettyPhoto.js\" type=\"text/javascript\"></script>\n";
            echo "\t\t";
            echo '<script type="text/javascript" charset="utf-8">';
            echo "\n\t\t\t$(document).ready(function () {\n\t\t\t\t$(\"a[rel^='prettyPhoto']\").prettyPhoto();\n";
            echo "\t\t\t});\n\t\t</script>\n";
        }
        elseif ($current_file=='blog'){
            echo "<!-- script pour menu -->\n\t\t<script src=\"js/metisMenu.min.js\" type=\"text/javascript\"></script>\n";
            echo "\t\t<script type=\"text/javascript\">\n\t\t\t$(function () {\n";
            echo "\t\t\t\t$('.metisFolder').metisMenu({toggle: true});\n\t\t\t});\n\t\t</script>\n";
        }
        elseif ($current_file=='infos'){
            echo "<!-- script pour mettre en route la google map -->\n\t\t";
            echo '<script src="http://maps.google.com/maps/api/js?sensor=true"></script>';
            echo "\n\t\t";
            echo'<script src="js/goomap.js" type="text/javascript"></script>';
            echo"\n";
        }
        ?>
    </body>
</html>  