<?php

/* 
 * permet de voir les derniers articles dans une catégorie
 *
 */

//retrouver la catégorie
$categorie=  Blogger::GetCategorieByID($_SESSION['language'], $catid);
//retrouver les éléments
$postparcat=  Blogger::GetsPostParCategorie($_SESSION['language'], $catid);
echo "<hr>\n\t\t\t\t\t\t\t<h2>\n\t\t\t\t\t\t\t\t<small><strong>";
echo mb_strtoupper($categorie,'UTF-8');
echo "</strong></small>\n\t\t\t\t\t\t\t</h2>\n\t\t\t\t\t\t\t<hr>\n\t\t\t\t\t\t</div>\n\t\t\t\t\t\t";
echo '<div class="row">';
echo "\n\t\t\t\t\t\t\t";
echo '<div>';
echo "\n";
foreach ($postparcat as $v){
    //on process le data pour faire voir les message
    echo "\t\t\t\t\t\t\t\t";
    echo '<div class="panel panel-paoli">';
    echo "\n\t\t\t\t\t\t\t\t\t";
    echo '<div class="panel-heading">';
    echo "\n\t\t\t\t\t\t\t\t\t\t";
    echo '<h3 class="panel-title">'.$v['titre'].'</h3>';
    echo "\n\t\t\t\t\t\t\t\t\t\t";
    echo '<i class="publie">'.$v['ladate'].'</i>';
    echo "\n\t\t\t\t\t\t\t\t\t</div>";
    echo "\n\t\t\t\t\t\t\t\t\t";
    echo '<div class="panel-body">';
    echo "\n\t\t\t\t\t\t\t\t\t\t";
    //on calcule la dernière occurrence d'un mot pour avoir une cassure nette ou le premier </p>
    $pposition = 0;
    $pposition = strpos($v['description'],'</p>');
    if ((isset($pposition)) && ($pposition != 0)){
        $position = $pposition;
    }
    else {
        $position = strrpos($v['description'],' ');
    }
    $text = substr_replace($v['description'], '... ', $position);
    echo $text."<br>\n\t\t\t\t\t\t\t\t\t\t";
    echo '<a href="blog.php?bloid='.$v['postid'].'" title="'.$v['lien'].'">'.$traduction['lire_suite_article'].'</a>';
    echo "\n\t\t\t\t\t\t\t\t\t\t</p>";
    echo "\n\t\t\t\t\t\t\t\t\t</div>";
    echo "\n\t\t\t\t\t\t\t\t</div>";                                
}
echo "\n\t\t\t\t\t\t\t</div>";
echo "\n\t\t\t\t\t\t</div>";