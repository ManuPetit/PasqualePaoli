<?php

/*
 * Classe pour la navigation
 * Comprend toutes les navigations du site
 *      - navbar
 *      - sidecolleft menu page index
 */

class Navigation {

    //retrouve les traductions du menu
    private static function GetNavigationItem($currentLangue) {
        //requête
        $sql = 'CALL sel_NavigationItem(:langue)';
        $param = array(':langue' => $currentLangue);
        //retourner le resultat
        return DatabaseHandler::GetAll($sql, $param);
    }

    //permet de savoir si on doit afficher ou non les icones
    private static function IsNavIconOn()
    {
        $sql = "SELECT actif FROM sys_variables WHERE abr_nom = 'affiche_icone_navigation'";
        return DatabaseHandler::GetOne($sql);
    }
    //creation des liens de navigation
    public static function GetNavigationLien($currentLangue, $currentFile) {
        //retrouver si icone active
        $iconNav = self::IsNavIconOn();
        $result = self::GetNavigationItem($currentLangue);
        //intialise le message
        $mess = null;
        foreach ($result as $v) {
            $mess .="\t\t\t\t\t\t";
            $mess .="<li";
            if ($v['fichier'] == $currentFile) {
                $mess.=' class="active"';
            }
            $mess.=">\n\t\t\t\t\t\t\t";
            $mess .='<a href="' . $v['fichier'] . '.php" title="' . $v['trad_title'].'">';
            if ($iconNav == 1) {
                $mess .= '<span class="fa ' . $v['icon'] . '"></span> ';
            }
            $mess .= $v['traduction'] . '</a>';
            $mess.="\n\t\t\t\t\t\t</li>\n";
        }
        return $mess;
    }

    //permet de retrouver le détail de la navigation de la page index
    //sidecolleft selon la catégorie
    private static function GetSideMenu($currentLangue, $categorie) {
        //requête
        $sql = 'call sel_SidecolMenu(:langue,:categorie)';
        $params = array(':langue' => $currentLangue, ':categorie' => $categorie);
        //resultat
        return DatabaseHandler::GetAll($sql, $params);
    }

    //permet de créer les liens pour sidecolleft Menus
    public static function GetSideMenuLien($currentLangue) {
        $resultat = self::GetSideMenu($currentLangue, 'menu');
        //creation des liens
        $mess = null;
        //creation du modal
        $modalclass = null;
        foreach ($resultat as $v) {
            $mess.="\t\t\t\t\t\t\t\t";
            $mess.='<a data-toggle="modal" href="menu/' . $v['fichier'] . '.php" ';
            $mess.= 'data-target="#' . $v['fichier'] . '" class="btn btn-link" ';
            $mess.='title="' . $v['title'] . '">' . $v['traduction'] . '</a><br>';
            $mess.="\n";
            $modalclass .= "\t\t\t\t\t\t\t";
            $modalclass.='<div class="modal fade" id="' . $v['fichier'] . '">';
            $modalclass.="\n\t\t\t\t\t\t\t\t";
            $modalclass.='<div class="modal-dialog">';
            $modalclass.="\n\t\t\t\t\t\t\t\t\t";
            $modalclass.='<div class="modal-content"></div>';
            $modalclass.="\n\t\t\t\t\t\t\t\t</div>";
            $modalclass.="\n\t\t\t\t\t\t\t</div>\n";
        }
        $modal = $mess . "\t\t\t\t\t\t\t</div>\n" . $modalclass;
        return $modal;
    }

    //permet de creer les liens pour sidecolleft actu
    public static function GetSideActuLien($currentLangue) {
        $resultat = self::GetSideMenu($currentLangue, 'actu');
        //creation des liens
        $mess = null;
        //creation du modal
        $modalclass = null;
        foreach ($resultat as $v) {
            $mess.="\t\t\t\t\t\t\t\t";
            $mess.='<a data-toggle="modal" href="menu/' . $v['fichier'] . '.php" ';
            $mess.= 'data-target="#' . $v['fichier'] . '" class="btn btn-link" ';
            $mess.='title="' . $v['title'] . '">' . $v['traduction'] . '</a><br>';
            $mess.="\n";
            $modalclass .= "\t\t\t\t\t\t\t";
            $modalclass.='<div class="modal fade" id="' . $v['fichier'] . '">';
            $modalclass.="\n\t\t\t\t\t\t\t\t";
            $modalclass.='<div class="modal-dialog">';
            $modalclass.="\n\t\t\t\t\t\t\t\t\t";
            $modalclass.='<div class="modal-content"></div>';
            $modalclass.="\n\t\t\t\t\t\t\t\t</div>";
            $modalclass.="\n\t\t\t\t\t\t\t</div>\n";
        }
        $modal = $mess . "\t\t\t\t\t\t\t</div>\n" . $modalclass;
        return $modal;
    }
    
    //retrouve les liens du blog traduit
    //retourne les archives des blogs la mise en page se fait sur la page blog
    private static function GetAllActifPost($currentLangue) {
        //requêtes
        $sql = 'CALL sel_ArchivesBlog(:langue)';
        $param = array(':langue' => $currentLangue);
        //retourne le résultat
        return DatabaseHandler::GetAll($sql, $param);
    }
    
    //retrouve l'ensemble de la navigation pour faire le sitemap
    public static function GetSiteMap($currentLangue){
        //requête pour trouver les élément de la navigation
        $navigations=self::GetNavigationItem($currentLangue);
        foreach ($navigations as $v){
            echo "\t\t\t\t\t\t\t<li>\n\t\t\t\t\t\t\t\t";
            echo '<a href="'.$v['fichier'].'.php" title="'.$v['trad_title'].'">'.$v['traduction'].'</a>';
            echo "\n";
            //vérifier pour la partie blog
            if ($v['fichier'] == 'blog') {
                //il va faloir retrouver la partie blog
                $posts = self::GetAllActifPost($currentLangue);
                echo "\t\t\t\t\t\t\t\t<ul>\n";
                foreach ($posts as $p){
                    echo "\t\t\t\t\t\t\t\t\t<li>\n\t\t\t\t\t\t\t\t\t\t";
                    echo '<a href="blog.php?bloid='.$p['id_post'].'" title="'.$p['lien'].'">'.$p['titre'].'</a>';
                    echo "\n\t\t\t\t\t\t\t\t\t</li>\n";
                }
                echo "\t\t\t\t\t\t\t\t</ul>\n";
            }
            echo "\t\t\t\t\t\t\t</li>\n";
        }
        
    }

}
