<?php

/*
 * Classe pour les traductions
 */

class Traduction {

    //fonction pour retrouver les entrées de la page selon la langue
    private static function GetPageTranslation($currentLanguage, $currentFile) {
        //requête
        $sql = 'CALL sel_Traductions(:langue,:fichier)';
        $params = array(':langue' => $currentLanguage, ':fichier' => $currentFile);
        //retourner le résultat
        return DatabaseHandler::GetAll($sql, $params);
    }

    //fonction qui permet de definir les différentes traduction de la page
    public static function GetTraductionPerPage($currentLangue, $currentFile) {
        $result = self::GetPageTranslation($currentLangue, $currentFile);
        //preparer array pour resultat
        $trad = array();
        foreach ($result as $v) {
            //$index="'".$v['def']."'";
            //$trad[$index] = $v['trad'];
            $trad[$v['def']] = $v['trad'];
        }
        return $trad;
    }

    //fonction qui permet de retrouver les traductions communes à chaque page
    public static function GetTraductionCommon($currentLangue) {
        $page = 'commun';
        $result = self::GetPageTranslation($currentLangue, $page);
        //preparer array pour resultat
        $trad = array();
        foreach ($result as $v) {
            //$index="'".$v['def']."'";
            //$trad[$index] = $v['trad'];
            $trad[$v['def']] = $v['trad'];
        }
        return $trad;
    }

    //fonction qui permet de retrouver les informations pour les horaires
    private static function GetHoraires($currentLangue) {
        //requête
        $sql = 'CALL sel_Horaires(:langue)';
        $param = array(':langue' => $currentLangue);
        //retourne le resultat
        return DatabaseHandler::GetAll($sql, $param);
    }

    //fonction qui permet de retrouver les fermetures annuelles
    private static function GetFermetureAnnuelle($currentLangue) {
        //requête
        $sql = 'CALL sel_FermetureAnnuel(:langue)';
        $param = array(':langue' => $currentLangue);
        //retourne le resultat
        return DatabaseHandler::GetOne($sql, $param);
    }

    //fonction qui permet de retrouver les jours de fermeture eceptionnelle
    private static function GetFermetureExceptionelle() {
        //requête
        $sql = 'CALL sel_FermetureException()';
        return DatabaseHandler::GetOne($sql);
    }

    //permet de retrouver les jours de la semaine
    private static function GetDay($currentLangue, $jourId) {
        //requête
        $sql = 'CALL sel_RetrouverJour(:langue,:jour)';
        $params = array(':langue' => $currentLangue, ':jour' => $jourId);
        //retourne le résultat
        return DatabaseHandler::GetOne($sql, $params);
    }

    //permet de trouver les traductions pour la fermeture exceptionnelle
    private static function GetTraductionFermExcept($currentLangue) {
        //requête
        $sql = 'CALL sel_TraductionFermetureException(:langue)';
        $param = array(':langue' => $currentLangue);
        //retourne le resultat
        return DatabaseHandler::GetAll($sql, $param);
    }

    //fonction qui permet de créer les horaires ($ferme est le mot ferme dans la langue choisie)
    public static function GetHorairesCell($currentLangue, $ferme) {
        //on vérifie la présence d'une fermeture exceptionnelle
        $mess = null;
        $ferme_an = self::GetFermetureAnnuelle($currentLangue);
        //Fermeture annuelle on affiche pas les jours
        if ($ferme_an != 'rien') {
            $mess.= '<p><strong>'.$ferme_an.'.</strong></p>';
        } else { //Ici on va vérifié la fermeture exceptionnelle
            $ferme_ex = self::GetFermetureExceptionelle();
            if ($ferme_ex != 'rien') {
                //ici on a des fermetures exceptionnelle on va donc créer le message avec les jours
                //création d'une array pour passer les jours
                $jourid = explode(',', $ferme_ex);
                $jours = null;
                foreach ($jourid as $v) {
                    $jours.=self::GetDay($currentLangue, $v) . ', ';
                }
                $tradFerme = self::GetTraductionFermExcept($currentLangue);
                $mess .= "<p><strong>" . $tradFerme[0]['avfer'] . "</strong><br>\n\t\t\t\t\t\t" . $jours . $tradFerme[0]['apfer'] . "</p>\n";
            }
            //maintenant on va vérifié les horaires
            $horaires = self::GetHoraires($currentLangue);
            $mess.="<table>\n";
            foreach ($horaires as $v) {
                $mess.="\t\t\t\t\t\t\t<tr>\n\t\t\t\t\t\t\t\t<td><strong>" . ucfirst($v['jour']) . " :&nbsp;&nbsp;</strong></td>\n";
                if (isset($jourid)) {
                    //on va automatisé le processus de création des fermetures exceptionnelles
                    foreach ($jourid as $j) {
                        if ($j == $v['id']) {
                            $v['debam'] = 'fermé';
                            $v['finam'] = 'fermé';
                            $v['debpm'] = 'fermé';
                            $v['finpm'] = 'fermé';
                        }
                    }
                }
                //on change le message selon que fermé ou pas
                if ($v['debam'] == 'fermé' && $v['finam'] == 'fermé' && $v['debpm'] == 'fermé' && $v['finpm'] == 'fermé') {
                    $mess.="\t\t\t\t\t\t\t\t<td colspan=\"2\">" . $ferme . "</td>\n";
                } elseif (($v['debam'] == 'fermé' && $v['finam'] == 'fermé') && ($v['debpm'] != 'fermé' || $v['finpm'] != 'fermé')) {
                    $mess.="\t\t\t\t\t\t\t\t<td>" . $ferme . "&nbsp;&nbsp;</td>\n\t\t\t\t\t\t\t\t<td>&nbsp;&nbsp;" . $v['debpm'] . " - " . $v['finpm'] . "</td>\n";
                } elseif (($v['debam'] != 'fermé' || $v['finam'] != 'fermé') && ($v['debpm'] == 'fermé' && $v['finpm'] == 'fermé')) {
                    $mess.="\t\t\t\t\t\t\t\t<td>" . $v['debam'] . " - " . $v['finam'] . "&nbsp;&nbsp;</td>\n\t\t\t\t\t\t\t\t<td>&nbsp;&nbsp;" . $ferme . "</td>\n";
                } else {
                    $mess.="\t\t\t\t\t\t\t\t<td>" . $v['debam'] . " - " . $v['finam'] . "&nbsp;&nbsp;</td>\n\t\t\t\t\t\t\t\t<td>&nbsp;&nbsp;" . $v['debpm'] . " - " . $v['finpm'] . "</td>\n";
                }
                $mess.="\t\t\t\t\t\t\t</tr>\n";
            }
            $mess.="\t\t\t\t\t\t</table>\n";
        }
        echo $mess;
    }

}
