<?php

/*
 * Classe pour le blog
 */

class Blogger {

    //function pour retrouver les deux derniers post actifs
    private static function GetDernierPost($currentLangue) {
        //requête
        $sql = 'call sel_DerniersPost(:langue)';
        $param = array(':langue' => $currentLangue);
        //retourne le resultat
        return DatabaseHandler::GetAll($sql, $param);
    }

    //fonction qui va crée le html pour les deux derniers post
    public static function GetGreationDernierPost($currentLangue) {
        $result = self::GetDernierPost($currentLangue);
        //flag pour ajouter espace au deuxième passage
        $flag = FALSE;
        $mess = null;
        foreach ($result as $v) {
            if ($flag == true) {
                $mess.= "\t\t\t\t\t\t\t<p>&nbsp;</p>\n";
            }
            $mess.="\t\t\t\t\t\t\t";
            /* que du coté gauche c'est plus joli.
              $mess.='<img src="images/blog/thumb/' . $v['thumb'] . '" alt="' . $v['thumbalt'] . '" class="img-circle ';
              if ($flag == true) {
              $mess.= 'image-gauche">';
              } else {
              $mess.= 'image-droite">';
              }
             */
            $mess.='<img src="images/blog/thumb/' . $v['thumb'] . '" alt="' . $v['thumbalt'] . '" class="img-circle image-gauche">';
            $mess.="\n\t\t\t\t\t\t\t";
            $mess.='<p><strong>' . $v['titre'] . '</strong><br><i>' . $v['pubdate'] . '</i></p>';
            $mess.="\n\t\t\t\t\t\t\t";
            $mess.='<p>' . $v['short'] . '... <br>';
            $mess.="\n\t\t\t\t\t\t\t\t";
            $mess.='<a href="blog.php?bloid=' . $v['id'] . '" title="' . $v['title'] . '">' . $v['larticle'] . '</a>';
            $mess.="\n\t\t\t\t\t\t\t</p>\n";
            $flag = true;
        }
        return $mess;
    }

    //permet de retrouver les catégories de message et leur nombre
    private static function GetTags($currentLangue) {
        //requête
        $sql = "CALL sel_NombreCategoriesPost(:langue)";
        $param = array(':langue' => $currentLangue);
        //retourne le résultat
        return DatabaseHandler::GetAll($sql, $param);
    }

    //retourn les différentes catégories de blog
    public static function GetBlogCategories($currentLangue) {
        $result = self::GetTags($currentLangue);
        $mess = null;
        foreach ($result as $v) {
            $mess.="\t\t\t\t\t\t\t\t";
            $mess.='<a href="blog.php?catid=' . $v['id'] . '" class="btn btn-default categories" title="' . ucfirst($v['traduction']) . '">';
            $mess.=ucfirst($v['traduction']) . ' <span class="badge">' . $v['nbre'];
            $mess.="</span></a>&nbsp;\n";
        }
        return $mess;
    }

    //retourne les archives des blogs la mise en page se fait sur la page blog
    public static function GetArchives($currentLangue) {
        //requêtes
        $sql = 'CALL sel_ArchivesBlog(:langue)';
        $param = array(':langue' => $currentLangue);
        //retourne le résultat
        return DatabaseHandler::GetAll($sql, $param);
    }

    //retrouve une entrée du blog
    public static function GetPostParId($currentLangue, $messageID) {
        //requête
        $sql = 'CALL sel_PostMessage(:langue,:bid)';
        $params = array(':langue' => $currentLangue, ':bid' => $messageID);
        //renvoi le résultat
        return DatabaseHandler::GetRow($sql, $params);
    }

    //retrouve le nom des catégories d'un post
    public static function GetTagForPost($currentLangue, $messageID) {
        //requete
        $sql = 'call sel_CategorieParPost(:langue,:bid)';
        $params = array(':langue' => $currentLangue, ':bid' => $messageID);
        //retrouver le resultat
        return DatabaseHandler::GetAll($sql, $params);
    }

    //retrouve le nom de la catégorie
    public static function GetCategorieByID($currentLangue, $categorieID) {
        $sql = 'CALL sel_CategorieParLangueEtId(:langue,:catid)';
        $params = array(':langue' => $currentLangue, ':catid' => $categorieID);
        return DatabaseHandler::GetOne($sql, $params);
    }
    
    //retrouve les éléments à présenter pour le blog
    public static function GetsPostParCategorie($currentLangue,$categorieID){
        $sql = 'CALL sel_PostsParCategorie(:langue,:catid)';
        $params = array(':langue' => $currentLangue, ':catid' => $categorieID);
        return DatabaseHandler::GetAll($sql, $params);
    }

    //retrouve les 3 derniers posts 
    public static function GetThreeLastPost($currentLangue){
        $sql = 'CALL sel_LastThreePost(:langue)';
        $param = array(':langue'=>$currentLangue);
        return DatabaseHandler::GetAll($sql,$param);
    }
}
