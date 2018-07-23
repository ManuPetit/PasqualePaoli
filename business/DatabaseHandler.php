<?php

/*
 * Classe permettant les échanges avec la base de données
 */

class DatabaseHandler {

    //instance de la classe PDO
    private static $_mHandler;

    //constructeur private pour empêcher la création directe de l'objet
    private function __construct() {
        
    }

    //retourne un database handler initialisé
    private static function GetHandler() {
        //création d'une connection si il n'y en a pas déja une
        if (!isset(self::$_mHandler)) {
            //éxécution du code essayant de se connecter
            try {
                //création d'une nouvelle instance de PDO
                self::$_mHandler = new PDO(PDO_DSN, DB_USERNAME, DB_PASSWORD, array(PDO::ATTR_PERSISTENT => DB_PERSISTENCY));
                //configurer PDO pour les erreurs
                self::$_mHandler->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
            } catch (PDOException $e) {
                //fermer la base de données et envoyer l'erreur
                self::Close();
                trigger_error($e->getMessage(), E_USER_ERROR);
            }
        }
        //return le database handler
        return self::$_mHandler;
    }

    //méthode pour fermer la connexion à la base de données
    public static function Close() {
        self::$_mHandler = null;
    }

    //méthode pour PDO::execute (INSERT, UPDATE, DELETE)
    //qui ne retourne pas de données
    public static function Execute($sqlQuery, $params = null) {
        //essayer de faire la requête
        try {
            //prendre le database handler
            $database_handler = self::GetHandler();
            //préparer la requete pour éxécution
            $statement_handler = $database_handler->prepare($sqlQuery);
            //éxécuter la requête
            $statement_handler->execute($params);
        } catch (PDOException $e) {
            //Erreur lors de l'éxécution de la requête
            //fermer la base de données et envoyer l'erreur
            self::Close();
            trigger_error($e->getMessage(), E_USER_ERROR);
        }
    }

    //méthode pour PDO::fetchAll qui permet de retrouver un résultat
    //complet de méthode SELECT
    public static function GetAll($sqlQuery, $params = null, $fetchStyle = PDO::FETCH_ASSOC) {
        //initialiser la valeur de retour à null
        $result = null;
        //essayer de faire la requête
        try {
            //prendre le database handler
            $database_handler = self::GetHandler();
            //preparer la requête
            $statement_handler = $database_handler->prepare($sqlQuery);
            //executer la requête
            $statement_handler->execute($params);
            //retrouver le resultat
            $result = $statement_handler->fetchAll($fetchStyle);
        } catch (PDOException $e) {
            //Erreur lors de l'éxécution de la requête
            //fermer la base de données et envoyer l'erreur
            self::Close();
            trigger_error($e->getMessage(), E_USER_ERROR);
        }
        return $result;
    }

    //méthode pour retrouver une ligne de données PDO::fetch()
    //utilise la méthode SELECT
    public static function GetRow($sqlQuery, $params = null, $fetchStyle = PDO::FETCH_ASSOC) {
        //initialiser la valeur de retour à null
        $result = null;
        //essayer de faire la requête
        try {
            //prendre le database handler
            $database_handler = self::GetHandler();
            //preparer la requête
            $statement_handler = $database_handler->prepare($sqlQuery);
            //executer la requête
            $statement_handler->execute($params);
            //retrouver le résultat
            $result = $statement_handler->fetch($fetchStyle);
        } catch (PDOException $e) {
            //Erreur lors de l'éxécution de la requête
            //fermer la base de données et envoyer l'erreur
            self::Close();
            trigger_error($e->getMessage(), E_USER_ERROR);
        }
        return $result;
    }

    //méthode pour retrouver un seul résultat (1ère ligne 1ère colonne)
    //utilise la méthode SELECT
    public static function GetOne($sqlQuery, $params = null) {
        //initialiser la valeur de retour à null
        $result = null;
        //essayer de faire la requête
        try {
            //prendre le database handler
            $database_handler = self::GetHandler();
            //preparer la requête
            $statement_handler = $database_handler->prepare($sqlQuery);
            //executer la requête
            $statement_handler->execute($params);
            //retrouver le résultat
            $result = $statement_handler->fetch(PDO::FETCH_NUM);
            //retrouver le résultat
            $result = $result[0];
        } catch (PDOException $e) {
            //Erreur lors de l'éxécution de la requête
            //fermer la base de données et envoyer l'erreur
            self::Close();
            trigger_error($e->getMessage(), E_USER_ERROR);
        }
        return $result;
    }

}
