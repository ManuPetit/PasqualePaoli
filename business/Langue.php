<?php

/*
 * Classe Langue
 */

class Langue {

    //Verifier si une langue existe
    private static function GetLangueExist($langue) {
        //requête
        $sql = 'CALL sel_VerifiePays(:langue)';
        $param = array(':langue' => $langue);
        //retourner le resultat
        return DatabaseHandler::GetOne($sql, $param);
    }

    //retrouver les infos des langues activées
    private static function GetLangueDetail($currentLangue) {
        //requête
        $sql = 'CALL sel_LangueDetail(:langue)';
        $param = array(':langue' => $currentLangue);
        //retourner le resultat
        return DatabaseHandler::GetAll($sql, $param);
    }

    //retourne un bool selon que la langue passée existe ou pas
    public static function IsLangueValid($langue) {
        $result = FALSE;
        if (self::GetLangueExist($langue) == 1) {
            $result = TRUE;
        }
        return $result;
    }

    //retourne les liens de la langue. extension est utilisé pour les blogs
    public static function GetLienLangue($currentLangue, $currentFile, $extension = NULL) {
        $result = self::GetLangueDetail($currentLangue);
        //initialiser le message
        $mess = null;
        foreach ($result as $v) {
            if (isset($extension)) {
                $fichier = $currentFile . '&amp;' . $extension;
            } else {
                $fichier = $currentFile;
            }
            $mess .="\t\t\t";
            $mess.='<a href="ChangeLangue.php?lan=' . $v['abr'] . '&amp;fic=' . $fichier . '" title="' . $v['langue'] . '">';
            $mess.='<img class="drapeau img-circle" src="images/common/' . $v['drapeau'] . '" alt="' . $v['traduction'] . '"></a>';
            $mess.="\n";
        }
        return $mess;
    }

    //PUBLIC permet de savoir si une catégorie existe
    public static function IsCategorieValid($catId) {
        $answer = FALSE;
        //requete
        $sql = 'CALL sel_IsTagValid(:tag)';
        $param = array(':tag' => $catId);
        $result = DatabaseHandler::GetOne($sql, $param);
        if (isset($result)) {
            $answer = TRUE;
        }
        return $answer;
    }

    //PUBLIC permet de savoir si un article existe
    public static function IsPostValid($postId) {
        $answer = FALSE;
        //requete
        $sql = 'CALL sel_IsPostValid(:post)';
        $param = array(':post' => $postId);
        $result = DatabaseHandler::GetOne($sql, $param);
        if (isset($result)) {
            $answer = TRUE;
        }
        return $answer;
    }

}
