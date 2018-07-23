<?php

/* 
 * fichier pour créer la page contact
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
require_once BUSINESS_DIR . 'GeneralFunction.php';

//verification de la langue de session
if (!isset($_SESSION['language'])) {
    $_SESSION['language'] = 'fra';
}
//assigner le nom du fichier
$current_file = basename(__FILE__, '.php');

include 'header.php';
?>
        <!-- CONTENU DE LA PAGE -->
        <div class="container">
            <!-- PREMIER ROW DE LA PAGE -->
            <div class="row">
                <div class="boite">
                    <!-- ROW DU TITRE -->
                    <div class="span12 text-center">
                        <h1 class="marque">Pasquale Paoli</h1>
                    </div>
                    <!-- FIN de ROW DU TITRE -->
                    <!-- COLONNE ADRESSE ET RESEAUX SOCIAUX -->
                    <div class="col-md-4 extrapad">
                        <div class="sidecolleft">                           
                            <hr class="lignecourt">
                            <h4 class="coltitre">
                                <strong><?php if (isset($traduction['cont_contacts'])) echo $traduction['cont_contacts']; ?></strong>
                            </h4>
                            <hr>
                            <p>
                                <span class="fa-stack fa-1x">                          
                                    <i class="fa fa-circle fa-stack-2x"></i>
                                    <i class="fa fa-phone fa-stack-1x textwhite"></i>
                                </span> <?php if (isset($traduction['footer_telephone'])) echo $traduction['footer_telephone']; ?> :<br>
                                <span class="margingauche"><?php if (isset($traduction['numero_telephone'])) echo $traduction['numero_telephone']; ?></span>
                                </p>
                            <p>&nbsp;</p>
                            <p>
                                <span class="fa-stack fa-1x">                          
                                    <i class="fa fa-circle fa-stack-2x"></i>
                                    <i class="fa fa-envelope fa-stack-1x textwhite"></i>
                                </span> <?php if (isset($traduction['footer_email'])) echo $traduction['footer_email']; ?> :<br>
                                <span class="margingauche"><a href="mailto:restaurant.upasqualepaoli@orange.fr" title="Email">restaurant.upasqualepaoli@orange.fr</a></span>
                            </p> 
                            <p>&nbsp;</p>
                            <p>
                                <span class="fa-stack fa-1x">                          
                                    <i class="fa fa-circle fa-stack-2x"></i>
                                    <i class="fa fa-home fa-stack-1x textwhite"></i>
                                </span> <?php if (isset($traduction['footer_adresse'])) echo $traduction['footer_adresse']; ?> :<br>
                                <span class="margingauche">2, Place Paoli<br></span>
                                <span class="margingauche">20220 L'Ile Rousse<br></span>
                                <span class="margingauche">Corse</span>
                            </p>
                            <hr class="lignecourt lignespace">
                            <h4 class="coltitre">
                                <strong><?php if (isset($traduction['cont_reseaux_soc'])) echo $traduction['cont_reseaux_soc']; ?></strong>
                            </h4>
                            <hr>
                            <p>
                                <span class="fa-stack fa-1x">                          
                                    <i class="fa fa-circle fa-stack-2x"></i>
                                    <i class="fa fa-facebook fa-stack-1x textwhite"></i>
                                </span> <a href="https://www.facebook.com/UPasqualePaoli/" title="facebook" class="socialspace">Facebook</a> 
                            </p>
                            <!-- Partie de TWITTER
                            <p>&nbsp;</p>
                            <p>
                                <span class="fa-stack fa-1x">                          
                                    <i class="fa fa-circle fa-stack-2x"></i>
                                    <i class="fa fa-twitter fa-stack-1x textwhite"></i>
                                </span> <a href="#" title="twitter" class="socialspace">twitter</a> 
                            </p>
                            -->
                        </div>
                    </div>
                    <!-- FIN de COLONNE ADRESSE ET RESEAUX SOCIAUX -->
                    <!-- COLONNE FORMULAIRE -->
                    <div class="col-md-8">
                        <div class="row">
                            <div class="span12 text-center">  
                        <hr>
                        <h4 class="coltitre">
                            <strong><?php if (isset($traduction['cont_form_contact'])) echo $traduction['cont_form_contact']; ?></strong>
                        </h4>   
                        <hr>
                            </div>
                        </div>
                        <?php
                        //validation du data
                        if (isset($_POST['saved'])){
                            //création d'une array pour les erreurs
                            $errors=array();
                            //on a du data donc on va devoir le vérifier
                            if ((isset($_POST['lenom'])) && (trim($_POST['lenom']))!='') { //verifier le nom
                                $clean_lenom = GeneralFunction::ValideNom($_POST['lenom']);
                            }else{
                                $errors['lenom']=$traduction['cont_missing_nom'];
                            }
                            if ((isset($_POST['lemail'])) && (trim($_POST['lemail']))!=''){ //verifier email
                                if ((GeneralFunction::ValideEmail($_POST['lemail'])) == TRUE){
                                    $clean_lemail=$_POST['lemail'];
                                }else{
                                    $errors['lemail']=$traduction['cont_invalid_mail'];
                                }
                            }else{
                                $errors['lemail']=$traduction['cont_missing_mail'];
                            }
                            if ((isset($_POST['lepho'])) && (trim($_POST['lepho']))!=''){ //verifier le téléphone
                                if ((GeneralFunction::ValidePhoneNum($_POST['lepho']))==TRUE){
                                    $clean_lepho=$_POST['lepho'];
                                }else{
                                    $errors['lepho']=$traduction['cont_invalid_phone'];
                                }
                            }else{
                                $errors['lepho']=$traduction['cont_missing_phone'];
                            }
                            if ((isset($_POST['lesuj'])) && (trim($_POST['lesuj']))!='') { //vérifier le sujet
                                $clean_lesuj = GeneralFunction::ValideNom($_POST['lesuj']);
                            }else{
                                $errors['lesuj']=$traduction['cont_missing_sujet'];
                            }
                            if ((isset($_POST['lemess'])) && (trim($_POST['lemess']))!=''){ //verifier le message
                                $clean_lemess=  nl2br(GeneralFunction::ValideMessage($_POST['lemess']));
								//$clean_lemess = nl2br(htmlspecialchars($_POST['lemess']));
                            }else{
                                $errors['lemess']=$traduction['cont_missing_mess'];
                            }
                            //si aucune erreurs, on peut envoyer le mail
                            if (empty($errors)){
                                //fixe un problème pour les serveurs msn
                                if (!preg_match("#^[a-z0-9._-]+@(hotmail|live|msn).[a-z]{2,4}$#", $clean_lemail)){
                                    $passage_ligne = "\r\n";
                                }else{
                                    $passage_ligne = "\n";  
                                }
                                //=====Création de la boundary
                                $boundary = "-----=".md5(rand());
                                //faire le message en ajoutant le nom et téléphone
                                $lemess = "Nom du client : ".$clean_lenom.$passage_ligne;
                                $lemess.= "Téléphone : ".$clean_lepho.$passage_ligne.$passage_ligne;
                                $lemess.=$clean_lemess.$passage_ligne;
                                $lemesshtml = "Nom du client : ".$clean_lenom."<br>";
                                $lemesshtml.= "Téléphone : ".$clean_lepho."<br><br>";
                                $lemesshtml.= $clean_lemess."<br>";
                                //creation du header
                                $header = "FROM: \"Site Pasquale Paoli\"<cgi-mailer@kundenserver.de>".$passage_ligne;
                                $header.= "MIME-Version: 1.0".$passage_ligne; 
                                $header.= "Reply-to: \"$clean_lemail\" <$clean_lemail>".$passage_ligne; 
                                $header.= "Content-Type: multipart/alternative;".$passage_ligne." boundary=\"$boundary\"".$passage_ligne;
                                //déclaration des messages
                                $messageText=$lemess;
                                //$messageHtml ="<html><head></head><body><p>" . $lemesshtml . "</p></body></html>";
								$messageHtml =$lemesshtml; 
                                //préparation du message
                                $message = $passage_ligne."--".$boundary.$passage_ligne;
                                //=====Ajout du message au format texte.
                                $message.= "Content-Type: text/plain; charset=\"utf-8\"".$passage_ligne;
                                $message.= "Content-Transfer-Encoding: 8bit".$passage_ligne;
                                $message.= $passage_ligne.$messageText.$passage_ligne;
                                //==========
                                $message.= $passage_ligne."--".$boundary.$passage_ligne;
                                //=====Ajout du message au format HTML
                                $message.= "Content-Type: text/html; charset=\"utf-8\"".$passage_ligne;
                                $message.= "Content-Transfer-Encoding: 8bit".$passage_ligne;
                                $message.= $passage_ligne.$messageHtml.$passage_ligne;
                                //==========
                                $message.= $passage_ligne."--".$boundary."--".$passage_ligne;
                                $message.= $passage_ligne."--".$boundary."--".$passage_ligne;
                                
                                //envoi du mail
                                //
                                //
                                //
                                //
								mail(EMAIL_PRINCIPALE,mb_encode_mimeheader($clean_lesuj,'UTF-8'),$message,$header);
                                //
                                //error_log($message, 3, LOG_ERRORS_FILE);
                                ?>
                        <div class="row">
                            <div class="span12">
                                <p><?php if (isset($traduction['cont_mailparti1'])) echo $traduction['cont_mailparti1']; ?></p>
                                <p><?php if (isset($traduction['cont_mailparti2'])) echo $traduction['cont_mailparti2']; ?></p>
                            </div>
                        </div>
                    </div>
                    <!-- FIN de COLONNE FORMULAIRE -->
                </div>
            </div>
            <!-- FIN de PREMIER ROW DE LA PAGE -->
        </div>
        <!-- FIN de CONTENU DE LA PAGE -->
<?php
include 'footer.php';
exit();                            
                            }
                        }
                        ?>
                        <div class="row">
                            <div class="span12">
                                <p><?php if (isset($traduction['cont_phrase1'])) echo $traduction['cont_phrase1']; ?><br>
                                <?php if (isset($traduction['cont_phrase2'])) echo $traduction['cont_phrase2']; ?></p>
                                <p><?php if (isset($traduction['cont_phrase3'])) echo $traduction['cont_phrase3']; ?></p>
                            </div>
                        </div>
                        <form action="contact.php" method="post">
                            <div class="row">
                                <?php 
                                //verifier les erreurs
                                if (isset($errors['lenom'])) {
                                    echo '<div class="form-group col-sm-12 col-md-4 has-error">';
                                }else{
                                    echo '<div class="form-group col-sm-12 col-md-4">';
                                }
                                ?>                                
                                    <label class="control-label" for="inputlenom"><?php if (isset($traduction['cont_nom'])) echo $traduction['cont_nom']; ?></label>
                                    <input type="text" class="form-control" name="lenom" id="inputlenom" value="<?php if (isset($_POST['lenom'])) echo $_POST['lenom']; ?>">
                                    <?php if (isset($errors['lenom'])) echo '<span id="alert1" class="help-block">'.$errors['lenom'].'</span>'; ?>
                                </div>  
                                <?php 
                                //verifier les erreurs
                                if (isset($errors['lemail'])) {
                                    echo '<div class="form-group col-sm-12 col-md-4 has-error">';
                                }else{
                                    echo '<div class="form-group col-sm-12 col-md-4">';
                                }
                                ?>                                    
                                    <label class="control-label" for="inputlemail"><?php if (isset($traduction['footer_email'])) echo $traduction['footer_email']; ?></label>
                                    <input type="email" class="form-control" name="lemail" id="inputlemail" value="<?php if (isset($_POST['lemail'])) echo $_POST['lemail']; ?>">
                                    <?php if (isset($errors['lemail'])) echo '<span id="alert2" class="help-block">'.$errors['lemail'].'</span>'; ?>
                                </div>  
                                <?php 
                                //verifier les erreurs
                                if (isset($errors['lepho'])) {
                                    echo '<div class="form-group col-sm-12 col-md-4 has-error">';
                                }else{
                                    echo '<div class="form-group col-sm-12 col-md-4">';
                                }
                                ?>                                           
                                    <label class="control-label" for="inputlepho"><?php if (isset($traduction['footer_telephone'])) echo $traduction['footer_telephone']; ?></label>
                                    <input type="text" class="form-control" name="lepho" id="inputlepho" value="<?php if (isset($_POST['lepho'])) echo $_POST['lepho']; ?>">
                                    <?php if (isset($errors['lepho'])) echo '<span id="alert3" class="help-block">'.$errors['lepho'].'</span>'; ?>
                                </div>                                       
                            </div>  
                            <div class="row"> 
                                <?php 
                                //verifier les erreurs
                                if (isset($errors['lesuj'])) {
                                    echo '<div class="form-group col-md-12 has-error">';
                                }else{
                                    echo '<div class="form-group col-md-12">';
                                }
                                ?>                                       
                                    <label class="control-label" for="inputlesuj"><?php if (isset($traduction['cont_sujet'])) echo $traduction['cont_sujet']; ?></label>
                                    <input type="text" class="form-control" name="lesuj" id="inputlesuj" value="<?php if (isset($_POST['lesuj'])) echo $_POST['lesuj']; ?>">
                                    <?php if (isset($errors['lesuj'])) echo '<span id="alert4" class="help-block">'.$errors['lesuj'].'</span>'; ?>
                                </div>  
                                <?php 
                                //verifier les erreurs
                                if (isset($errors['lemess'])) {
                                    echo '<div class="form-group col-md-12 has-error">';
                                }else{
                                    echo '<div class="form-group col-md-12">';
                                }
                                ?>                                           
                                    <label class="control-label" for="inputlemess"><?php if (isset($traduction['cont_mess'])) echo $traduction['cont_mess']; ?></label>
                                    <textarea class="form-control" name="lemess" id="inputlemess" rows="6"><?php if (isset($_POST['lemess'])) echo $_POST['lemess']; ?></textarea>
                                    <?php if (isset($errors['lemess'])) echo '<span id="alert5" class="help-block">'.$errors['lemess'].'</span>'; ?>
                                </div> 
                                <div class="form-group col-md-12">                                  
                                    <input type="hidden" name="saved" value="contact">
                                    <button type="submit" class="btn btn-primary"><?php if (isset($traduction['cont_envoy'])) echo $traduction['cont_envoy']; ?></button>
                                </div>
                            </div>  
                        </form>
                    </div>
                    <!-- FIN de COLONNE FORMULAIRE -->
                </div>
            </div>
            <!-- FIN de PREMIER ROW DE LA PAGE -->
        </div>
        <!-- FIN de CONTENU DE LA PAGE -->
<?php
include 'footer.php';