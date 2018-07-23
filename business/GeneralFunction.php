<?php

/* 
 * Class avec des fonction général
 */

class GeneralFunction {
    
    //fonction pour vérifier un email
    public static function ValideEmail($email){
        $result= FALSE;
        if ((filter_var($email,FILTER_VALIDATE_EMAIL))!== FALSE){
            $result=TRUE;
        }
        return $result;
    }
    
    //fonction pour vérifier que le data on met est valide
    private static function TestInputData($donnees) {
        $clean = trim($donnees);
        $clean = stripcslashes($clean);
        $clean = htmlspecialchars($clean);
        return $clean;
    }
    
    //validation du nom
    public static function ValideNom($nom){
        return filter_var(trim($nom),FILTER_SANITIZE_STRING);
    }
    
    //validation du message
    public static function ValideMessage($message){
        return filter_var(trim($message),FILTER_SANITIZE_STRING);
    }
            
    //permet de vérifier un numéro de télephone
    public static function ValidePhoneNum($phoneNumber){
        //array contenant ce que l'on peut accepter dans un numéro de téléphone
        $valid = array('1','2','3','4','5','6','7','8','9','0','-','+',' ','(',')');
        //variable avec le résultat
        $result=TRUE;
        $long = strlen($phoneNumber);
        for($i=0;$i<$long;$i++){
            if (!in_array((substr($phoneNumber, $i, 1)),$valid)) {
                $result=FALSE;
            }
        }
        return $result;
    }
    
    
}
