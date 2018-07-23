<?php

/* 
 * permet de créer la page d'un article du blog
 */

//on récupère le data
$post=  Blogger::GetPostParId($_SESSION['language'], $blogid);
echo "<hr>\n\t\t\t\t\t\t\t<h2>\n\t\t\t\t\t\t\t\t<small><strong>";
echo mb_strtoupper($post['titre'],'UTF-8');
echo "</strong></small>\n\t\t\t\t\t\t\t</h2>\n\t\t\t\t\t\t\t<hr>\n\t\t\t\t\t\t</div>\n\t\t\t\t\t\t";
echo '<div class="row">';
echo "\n\t\t\t\t\t\t\t";
echo '<div>';
echo "\n\t\t\t\t\t\t\t\t";
echo '<div class="panel panel-paoli">';
echo "\n\t\t\t\t\t\t\t\t\t";
echo '<div class="panel-body">';
echo $post['description'];
echo "\n\t\t\t\t\t\t\t\t\t</div>\n\t\t\t\t\t\t\t\t\t";
echo '<div class="panel-footer">';
echo "\n\t\t\t\t\t\t\t\t\t\t";
echo '<i class="publie">'.$post['ladate'].'</i>';
echo "\n\t\t\t\t\t\t\t\t\t\t";
//on retrouve les catégories
echo '<p>'.$traduction['blog_categorie_header']. ' : ';
$categories = Blogger::GetTagForPost($_SESSION['language'], $blogid);
foreach ($categories as $v){
    echo '<a href="blog.php?catid='.$v['tagid'].'" title="'.$v['trad'].'"><span class="badge">'.$v['trad'].'</span></a>&nbsp;';
}
echo "\n\t\t\t\t\t\t\t\t\t\t</p>";
echo "\n\t\t\t\t\t\t\t\t\t</div>";
echo "\n\t\t\t\t\t\t\t\t</div>";
echo "\n\t\t\t\t\t\t\t</div>";
echo "\n\t\t\t\t\t\t</div>";