<?php
/* 
 * fichier créant l'entête
 */

//retrouve l'ensemble des traductions pour la page
$traduction = Traduction::GetTraductionPerPage($_SESSION['language'], $current_file);
//retrouve les traduction des éléments communs à chaque page
$traduction = array_merge($traduction, Traduction::GetTraductionCommon($_SESSION['language']));
//retrouve les liens vers les autres langues
if (isset($current_ext)){
    $lienLangue = Langue::GetLienLangue($_SESSION['language'], $current_file,$current_ext);    
}
else{
    $lienLangue = Langue::GetLienLangue($_SESSION['language'], $current_file);
}
//retrouve la navigation
$navigation=  Navigation::GetNavigationLien($_SESSION['language'], $current_file);
/*echo '<pre>';
print_r($traduction);
echo '</pre>';
exit();*/
?>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <!-- Les 3 meta doivent être en premier sur la page. -->

        <!-- description -->
        <meta name="description" content="<?php if (isset($traduction['meta_desc'])) echo $traduction['meta_desc']; ?>">
        <meta name="keywords" content="<?php if(isset($traduction['meta_tag'])) echo $traduction['meta_tag']; ?>">
        <meta name="author" content="Emmanuel Petit">

        <!-- Liste de Favicon -->
        <link rel="apple-touch-icon" href="apple-touch-icon-180x180.png">
        <link rel="icon" href="favicon.ico">

        <title><?php if (isset($traduction['page_title'])) echo $traduction['page_title']; ?></title>   

        <!-- Police -->
        <link href='https://fonts.googleapis.com/css?family=Great+Vibes' rel='stylesheet' type='text/css'>
        <link href="http://fonts.googleapis.com/css?family=Open+Sans" rel="stylesheet" type="text/css">
        <!-- Bootstrap core CSS customisé par LESS -->
        <link href="css/__bootstrap.css" rel="stylesheet">
        <?php
        //on ajoute les css necessaires pour certains fichier
        if ($current_file == 'media') {
            echo '<!-- Style pour prettyPhoto -->
        <link href="css/prettyPhoto.css" rel="stylesheet" type="text/css"/>',"\n";
        }
        elseif ($current_file=='blog'){
            echo '<!-- css pour le menu qui collapse -->
        <link href="css/metisFolder.css" rel="stylesheet" type="text/css"/>',"\n";
        }
        ?>
        <!-- IE10 viewport hack for Surface/desktop Windows 8 bug -->
        <link href="css/ie10-viewport-bug-workaround.css" rel="stylesheet">

        <!-- HTML5 shim and Respond.js for IE8 support of HTML5 elements and media queries -->
        <!--[if lt IE 9]>
          <script src="https://oss.maxcdn.com/html5shiv/3.7.2/html5shiv.min.js"></script>
          <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
        <![endif]-->
    </head>
    <body>
        <!-- ENTETE -->
        <div class="logo">P <img src="images/common/ppaolilogomini.png" alt="<?php if (isset($traduction['alt_logo_restaurant'])) echo $traduction['alt_logo_restaurant'] ?>"/> P</div>
        <div class="adresse">2 Place Paoli | 20220 L'Ile Rousse | <?php if (isset($traduction['numero_telephone'])) echo  $traduction['numero_telephone']; ?><br><br>
<?php if (isset($lienLangue)) echo $lienLangue; ?>
         </div>
        <!-- FIN de ENTETE -->

        <!-- NAVIGATION -->
        <div class="navbar navbar-default" role="navigation">
            <div class="container">
                <!-- Entete de navigation avec Pasquale Paoli -->
                <div class="navbar-header">
                    <button type="button" class="navbar-toggle" data-toggle="collapse" data-target="#menu-collapse">
                        <span class="sr-only"><?php if (isset($traduction['affichage_navigation'])) echo $traduction['affichage_navigation']; ?></span>
                        <span class="fa fa-bars"></span>
                    </button>
                    <a class="navbar-brand" href="index.html">Pasquale Paoli<br><span class="navtel"><?php if (isset($traduction['numero_telephone'])) echo  $traduction['numero_telephone']; ?></span></a>
                </div>
                <div class="collapse navbar-collapse" id="menu-collapse">
                    <ul class="nav navbar-nav"> 
<?php if (isset($navigation)) echo $navigation; ?>
                    </ul>
                </div>
            </div>
        </div>
        <!-- FIN de NAVIGATION -->

        <!-- Drapeaux à afficher sur version portable -->
        <div class="row visible-xs">
            <div class="col-lg-12 text-center">
                <p>
<?php if (isset($lienLangue)) echo $lienLangue; ?>
                </p> 
            </div>
        </div>
        <!-- FIN de Drapeaux à afficher sur version portable -->
