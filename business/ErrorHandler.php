<?php

/*
 * Classe permettant la gestion des erreurs
 */

class ErrorHandler {

    //constructeur private pour empêcher la création directe de l'objet
    private function __construct() {
        
    }

    //definit la methode Handler comme méthode de gestion des erreurs
    public static function SetHandler($errTypes = ERROR_TYPES) {
        return set_error_handler(array('ErrorHandler', 'Handler'), $errTypes);
    }

    //méthode de gestion des erreurs
    public static function Handler($errNo, $errStr, $errFile, $errLine) {
        //on n'utilise pas les 2 premiers éléments de la backtrace array
        $backtrace = ErrorHandler::GetBacktrace(2);

        //mesage d'erreur à logger, envoyer ou afficher
        $error_message = "\nERR #   : $errNo\nTEXTE   : $errStr" .
                "\nFICHIER : $errFile, &agrave; la ligne $errLine,\n" .
                "le " . date('d/m/Y') . " &agrave; " . date('H:i:s') .
                "\nBacktrace :\n$backtrace\n\n";

        //envoyer l'email si cela est mis en route
        if (SEND_ERROR_MAIL == TRUE) {
            error_log($error_message, 1, ADMIN_ERROR_MAIL, "From: " . SENDMAIL_FROM . "\r\nTo: " . ADMIN_ERROR_MAIL);
        }

        //enregistrer l'erreur dans le fichier log sir true
        if (LOG_ERRORS == TRUE) {
            error_log($error_message, 3, LOG_ERRORS_FILE);
        }

        //ATTENTION ne pas stopper l'éxécution si IS_WARNING_FATAL est FALSE
        //E_NOTICE et E_USER_NOTICE ne stoppent pas l'éxécution
        if (($errNo == E_WARNING && IS_WARNING_FATAL == FALSE) || ($errNo == E_NOTICE || $errNo == E_USER_NOTICE)) {
            //si l'erreur n'est pas fatale
            //si DEBUGGIN est TRUE
            if (DEBUGGING == TRUE) {
                echo '<div class="text-danger bg-warning"><pre>' . $error_message . '</pre></div>';
            }
        } else {
            //si l'erreur est fatale
            //montrer le message d'urgence
            if (DEBUGGING == TRUE) {
                echo '<div class="text-danger bg-warning"><pre>' . $error_message . '</pre></div>';
            } else {
                echo SITE_GENERIC_ERROR_MESSAGE;
            }
            //arreter le processus
            exit();
        }
    }

    //construction du message de backtrace 
    public static function GetBacktrace($irrelevantFirstEntries) {
        $s = '';
        $MAXSTRLEN = 64;

        $trace_array = debug_backtrace();
        for ($i = 0; $i < $irrelevantFirstEntries; $i++) {
            array_shift($trace_array);
        }
        $tabs = sizeof($trace_array) - 1;

        foreach ($trace_array as $arr) {
            $tabs-=1;
            if (isset($arr['class'])) {
                $s.=$arr['class'] . '.';
            }
            $args = array();

            if (!empty($args['args'])) {
                foreach ($args['args'] as $s) {
                    if (is_null($v)) {
                        $args[] = 'null';
                    } elseif (is_array($v)) {
                        $args[] = 'Array[' . sizeof($v) . ']';
                    } elseif (is_object($v)) {
                        $args[] = 'Object: ' . get_class($v);
                    } elseif (is_bool($v)) {
                        $args[] = $v ? 'true' : 'false';
                    } else {
                        $v = (string) @$v;
                        $str = htmlspecialchars(substr($v, 0, $MAXSTRLEN));
                        if (strlen($v) > $MAXSTRLEN)
                            $str .= '...';
                        $args[] = '"' . $str . '"';
                    }
                }
            }

            $s .= $arr['function'] . '(' . implode(', ', $args) . ')';
            $line = (isset($arr['line']) ? $arr['line'] : 'unknown');
            $file = (isset($arr['file']) ? $arr['file'] : 'unknown');
            $s .= sprintf(' # line %4d, file: %s', $line, $file);
            $s.="\n";
        }
        return $s;
    }

}
?>