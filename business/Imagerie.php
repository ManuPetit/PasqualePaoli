<?php

/*
 * classe Imagerie pour toutes les fonctions d'image
 */

class Imagerie {

    //permet de retrouver le data des images du carrousel 
    private static function GetCarrouselItem($currentLangue) {
        //requête
        $sql = 'CALL sel_ImageSlider(:langue)';
        $param = array(':langue' => $currentLangue);
        //retroune le data
        return DatabaseHandler::GetAll($sql, $param);
    }

    //permet de créer les infos pour faire le carrousel
    public static function GetCarrouselSlider($currentLangue) {
        $result = self::GetCarrouselItem($currentLangue);
        //pour retrouner le html
        $mess = null;
        //on vérifie qu'il y a quelque chose dans l'array
        if (!empty($result)) {
            $mess = "\t\t\t\t\t\t<!-- CAROUSEL -->\n\t\t\t\t\t\t";
            $mess.='<div id="carousel-generic" class="carousel slide">';
            $mess.="\n\t\t\t\t\t\t\t<!-- indicateurs -->\n\t\t\t\t\t\t\t";
            $mess.='<ol class="carousel-indicators hidden-xs">';
            $mess.="\n";
            //nécessaire pour la création de li, puis des div
            $li = null;
            $div = null;
            //counter
            $count = 0;
            foreach ($result as $v) {
                //creation du li pour la première partie du carrousel
                $li .= "\t\t\t\t\t\t\t\t";
                $li .='<li data-target="#carousel-generic" data-slide-to="' . $count . '"';
                if ($count == 0) {
                    $li.=' class="active"';
                }
                $li.="></li>\n";
                //creation des div pour la deuxième partie du carrousel
                $div.="\t\t\t\t\t\t\t\t";
                $div.='<div class="item';
                if ($count == 0) {
                    $div.=' active';
                }
                $div.='">';
                $div.="\n\t\t\t\t\t\t\t\t\t";
                $div.='<img class="img-responsive img-full" src="images/common/' . $v['image'] . '" alt="' . $v['traduction'] . '">';
                $div.="\n\t\t\t\t\t\t\t\t</div>\n";
                $count++;
            }
            $mess .= $li . "\t\t\t\t\t\t\t</ol>\n\t\t\t\t\t\t\t<!-- images -->\n\t\t\t\t\t\t\t";
            $mess.= '<div class="carousel-inner">';
            $mess.= "\n" . $div . "\t\t\t\t\t\t\t</div>\n\t\t\t\t\t\t\t<!-- controles -->\n\t\t\t\t\t\t\t";
            $mess.='<a class="left carousel-control" href="#carousel-generic" data-slide="prev">';
            $mess.="\n\t\t\t\t\t\t\t\t";
            $mess.='<span class="fa fa-chevron-circle-left"></span>';
            $mess.="\n\t\t\t\t\t\t\t</a>\n\t\t\t\t\t\t\t";
            $mess.='<a class="right carousel-control" href="#carousel-generic" data-slide="next">';
            $mess.="\n\t\t\t\t\t\t\t\t";
            $mess.='<span class="fa fa-chevron-circle-right"></span>';
            $mess.="\n\t\t\t\t\t\t\t</a>\n\t\t\t\t\t\t</div>\n\t\t\t\t\t\t<!-- FIN de CAROUSEL -->\n";
        }
        return $mess;
    }

    //Fonction pour retrouver les détails de la galerie. La mise en page se fait sur la page media.php
    public static function GetGalerieDetail($currentLangue) {
        //requête 
        $sql = 'CALL  sel_GalerieDetails(:langue)';
        $param = array(':langue' => $currentLangue);
        //retourne le résultat
        return DatabaseHandler::GetAll($sql, $param);
    }

}
