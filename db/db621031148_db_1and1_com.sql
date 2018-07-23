-- phpMyAdmin SQL Dump
-- version 4.1.14.8
-- http://www.phpmyadmin.net
--
-- Client :  db621031148.db.1and1.com
-- Généré le :  Mar 30 Janvier 2018 à 16:41
-- Version du serveur :  5.5.58-0+deb7u1-log
-- Version de PHP :  5.4.45-0+deb7u12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Base de données :  `db621031148`
--

DELIMITER $$
--
-- Procédures
--
CREATE DEFINER=`dbo621031148`@`%` PROCEDURE `sel_ArchivesBlog`(IN `langue` VARCHAR(3))
BEGIN
	/*
		permet de retrouver le détail des entrées pour créer l'archive
	*/
    DECLARE langid INT;
    SET langid = (SELECT id FROM sys_languages WHERE langue_code = langue);
    SELECT YEAR(vgd.date_publie) AS annee, MONTH(vgd.date_publie) AS mois,
	tm.traduction AS traduction, vgd.titre AS titre, 
    vgd.lien AS lien, vgd.id AS id_post
	FROM pasquale.view_getblogdetails AS vgd
	INNER JOIN trd_mois AS tm
	ON tm.id_mois = MONTH(vgd.date_publie) 
	WHERE vgd.actif = 1
	AND vgd.langue = langid
	AND tm.id_language = langid
	ORDER BY vgd.date_publie DESC;
END$$

CREATE DEFINER=`dbo621031148`@`%` PROCEDURE `sel_CategorieParLangueEtId`(IN `langue` VARCHAR(3), IN `catid` INT)
BEGIN
	/*
		Permet de retrouver le nom de la catégorie dans une langue
    */
    DEClARE langid INT;
    SET langid = (SELECT id FROM sys_languages WHERE langue_code = langue);
    SELECT traduction
    FROM trd_tag
    WHERE id_tag = catid
    AND id_language = langid;
END$$

CREATE DEFINER=`dbo621031148`@`%` PROCEDURE `sel_CategorieParPost`(IN `langue` VARCHAR(3), IN `postid` INT)
BEGIN
	/*
		Permet de retrouver les catégories d'un post
    */
    DECLARE langid INT;
    SET langid = (SELECT id FROM sys_languages WHERE langue_code = langue);
	SELECT btp.id_tag AS tagid, tt.traduction AS trad
	FROM blg_tag_post AS btp
	INNER JOIN trd_tag AS tt
	ON tt.id_tag = btp.id_tag
	WHERE btp.id_post = postid
	AND tt.id_language = langid
    ORDER BY tt.traduction;
END$$

CREATE DEFINER=`dbo621031148`@`%` PROCEDURE `sel_DerniersPost`(IN `langue` VARCHAR(3))
BEGIN
	DECLARE langid INT;
    DECLARE defi VARCHAR(45);
	SET langid = (SELECT id FROM sys_languages WHERE langue_code = langue);
    SET defi = (SELECT traduction FROM trd_general AS tg 
				INNER JOIN sys_definition AS sd
				ON sd.id = tg.id_definition
				WHERE sd.definition = 'lire_article'
				AND tg.id_langue = langid);
	SELECT bph.id AS id, bph.image_thumb AS thumb,
	tdp.titre AS titre, 
    fun_DateAlphaTraduit(bph.date_publie,langid,0) AS pubdate,
	tdp.short_desc AS short, tdp.title_link AS title,
	tdp.thumb_alt AS thumbalt, defi AS larticle
	FROM blg_postsheader AS bph
	INNER JOIN trd_post AS tdp
	ON tdp.id_postsheader = bph.id
	WHERE bph.actif = 1
	AND tdp.id_language = langid
	ORDER BY bph.date_publie DESC
	LIMIT 2;
END$$

CREATE DEFINER=`dbo621031148`@`%` PROCEDURE `sel_FermetureAnnuel`(IN `langue` VARCHAR(3))
BEGIN
	/*
		FUNCTION permettant de savoir si il y a une fermeture annuelle et de retourner
        la traduction
	*/
	DECLARE langid INT;
    DECLARE isused INT;
    DECLARE fermex VARCHAR(100);
    SET langid = (SELECT id FROM  sys_languages WHERE langue_code = langue);
    SET isused = (SELECT actif FROM sys_variables WHERE abr_nom = 'fermeture_annuelle');
    if (isused = 0) then
		SET fermex = 'rien';
	else
		SET fermex = (SELECT concat_WS(' ', tg.traduction, tm.traduction,sv.str_autre) 
						FROM sys_variables as sv
						INNER JOIN sys_definition AS sd
						ON sd.definition = sv.str_variable
						INNER JOIN trd_general AS tg
						ON tg.id_definition = sd.id
						INNER JOIN trd_mois AS tm 
						ON tm.id_mois = sv.int_variable
						WHERE sv.abr_nom = 'fermeture_annuelle'
						AND tg.id_langue = langid
						AND tm.id_language = langid);
	end if;
	SELECT fermex;
END$$

CREATE DEFINER=`dbo621031148`@`%` PROCEDURE `sel_FermetureException`()
BEGIN
	/*
		FUNCTION permettant de savoir si il y a une fermeture annuelle et de retourner
        la traduction
	*/
    DECLARE isused INT;
    DECLARE fermex VARCHAR(25);
    SET isused = (SELECT actif FROM sys_variables WHERE abr_nom = 'fermeture_exception');
    if (isused = 0) then
		SET fermex = 'rien';
	else
		SET fermex = (SELECT str_variable FROM sys_variables
						WHERE abr_nom = 'fermeture_exception');
	end if;
	SELECT fermex;
END$$

CREATE DEFINER=`dbo621031148`@`%` PROCEDURE `sel_GalerieDetails`(IN `langue` VARCHAR(3))
BEGIN
	/*
		retourne l'ensemble des détails pour formater la galerie des médias
        
        showDetails = 1, on fait tout apparaite selon sys_variables affiche_legende_galerie
	*/
    DECLARE langid INT;
    DECLARE showDetails TINYINT(1);
    SET langid = (SELECT id FROM sys_languages WHERE langue_code = langue);
    SET showDetails = (SELECT actif from sys_variables WHERE abr_nom = 'affiche_legende_galerie');
    IF (showDetails = 1) THEN
		SELECT fichier, thumb, width, height,
		fun_TraductionGalerie(langid,'title',id) AS titre,
		fun_TraductionGalerie(langid,'alt',id) AS alt,
		fun_TraductionGalerie(langid,'header',id) AS header,
		fun_TraductionGalerie(langid,'texte',id) AS texte,
		fun_DateAlphaTraduit(date, langid, 0) AS ladate
		FROM img_galerie
		WHERE actif = 1
		ORDER BY DATE DESC;
	ELSE
		SELECT fichier, thumb, width, height,
		fun_TraductionGalerie(langid,'title',id) AS titre,
		fun_TraductionGalerie(langid,'alt',id) AS alt
		FROM img_galerie
		WHERE actif = 1
		ORDER BY DATE DESC;
    END IF;
END$$

CREATE DEFINER=`dbo621031148`@`%` PROCEDURE `sel_Horaires`(IN `langue` VARCHAR(3))
BEGIN
	DECLARE langid INT;
	SET langid = (SELECT id FROM sys_languages WHERE langue_code = langue);
	SELECT tj.id_jour AS id, tj.traduction AS jour, sh.ferme_execp AS excep,
	fun_ReturnHoraire(sh.debut_am) AS debam, fun_ReturnHoraire(sh.fin_am) AS finam,
	fun_ReturnHoraire(sh.debut_pm) AS debpm, fun_ReturnHoraire(sh.fin_pm) AS finpm,
	sh.ordre AS ordre
	FROM sys_horaires AS sh
	INNER JOIN trd_jour AS tj
	ON tj.id_jour = sh.id_jour
	WHERE tj.id_language = langid
	ORDER BY sh.ordre;
END$$

CREATE DEFINER=`dbo621031148`@`%` PROCEDURE `sel_ImageSlider`(IN `langue` VARCHAR(3))
BEGIN
	/*
		Retrouve les images du slider de la page d'index
	*/
    DECLARE langid INT;
    SET langid = (SELECT id FROM sys_languages WHERE langue_code = langue);
    SELECT im.image AS image,
	tg.traduction AS traduction 
	FROM img_slide AS im
	INNER JOIN sys_definition AS sd
	ON im.nom_slide = sd.definition
	INNER JOIN trd_general as tg
	ON tg.id_definition = sd.id
	WHERE tg.id_langue = langid
	AND im.actif = 1
	ORDER BY im.ordre;
END$$

CREATE DEFINER=`dbo621031148`@`%` PROCEDURE `sel_IsPostValid`(IN `post` INT)
BEGIN
	/* 
		Vérifie qu'un article existe
	*/
    SELECT titre FROM blg_postsheader
    WHERE id = post
    AND actif = 1;
END$$

CREATE DEFINER=`dbo621031148`@`%` PROCEDURE `sel_IsTagValid`(IN `tag` INT)
BEGIN
	/* 
		Vérifie qu'une catégorie existe
	*/
    SELECT nom FROM blg_tag
    WHERE id = tag;
END$$

CREATE DEFINER=`dbo621031148`@`%` PROCEDURE `sel_LangueDetail`(IN `code_pays` VARCHAR(3))
BEGIN
	DECLARE langid INT;
	SET langid=(SELECT id FROM sys_languages WHERE langue_code = code_pays);
	SELECT sl.id AS id, sl.langue AS langue, 
	sl.drapeau AS drapeau, sl.langue_code AS abr,
    tg.traduction as traduction
	FROM sys_languages AS sl
	INNER JOIN sys_definition AS sd
	ON CONCAT('alt_drapeau_',lower(sl.langue)) = sd.definition
	INNER JOIN trd_general AS tg 
	ON sd.id = tg.id_definition
	WHERE tg.id_langue = langid 
	AND sl.actif = 1
	and sl.langue_code <> code_pays
	ORDER BY sl.id;
END$$

CREATE DEFINER=`dbo621031148`@`%` PROCEDURE `sel_LastThreePost`(IN `langue` VARCHAR(3))
BEGIN
/*
		permet de retrouver les 3 derniers messages actifs du blog
*/
	DECLARE langid INT;
    SET langid = (SELECT id FROM sys_languages WHERE langue_code = langue);
    SELECT tp.id_postsheader AS postid, tp.titre AS titre,
    substr(tp.description,1,400) AS description,
    tp.title_link AS lien,
    fun_DateAlphaTraduit(bph.date_publie,@langid,0) AS ladate
    FROM trd_post AS tp
    INNER JOIN blg_postsheader AS bph
    ON bph.id = tp.id_postsheader
    WHERE tp.id_language = langid
    AND bph.actif = 1
    ORDER BY bph.date_publie DESC LIMIT 3;
END$$

CREATE DEFINER=`dbo621031148`@`%` PROCEDURE `sel_MenusActus`(IN `langue` VARCHAR(3), IN `fichier` VARCHAR(45))
BEGIN
/*
	Permet de retrouver les éléments des menus et actus à afficher
*/
	DECLARE langid INT;
    SET langid = (SELECT id FROM sys_languages WHERE langue_code = langue);
	SELECT tma.type_traduction AS typetrad,
	tma.traduction AS traduction 
	FROM trd_menuactus AS tma
	INNER JOIN sys_menuactus AS sma
	ON sma.id = tma.id_menuactus
	INNER JOIN sys_homemenu AS shm
	ON shm.id = sma.id_homemenu
	WHERE sma.actif = 1
	AND tma.id_language = langid
	AND shm.fichier = fichier;
END$$

CREATE DEFINER=`dbo621031148`@`%` PROCEDURE `sel_NavigationItem`(IN `langue` VARCHAR(3))
BEGIN
	DECLARE langid INT;
	SET langid=(SELECT id FROM sys_languages WHERE langue_code = langue);
    SELECT tn.traduction AS traduction, tn.traduction_title AS trad_title,
	sn.icon AS icon, sn.fichier AS fichier
	FROM sys_navigation AS sn
	INNER JOIN trd_navigation AS tn
	ON tn.id_navigation = sn.id
	WHERE tn.id_language = langid
	AND sn.actif = 1
	ORDER BY sn.id;
END$$

CREATE DEFINER=`dbo621031148`@`%` PROCEDURE `sel_NombreCategoriesPost`(IN `langue` VARCHAR(3))
BEGIN
	/*
		Retrouve toutes les catégories utilisées par le blog
	*/
    DECLARE langid INT;
    SET langid= (SELECT id FROM sys_languages WHERE langue_code = langue);
    SELECT btp.id_tag AS id, COUNT(btp.id) AS nbre,
	tt.traduction AS traduction
	FROM blg_tag_post AS btp
	INNER JOIN trd_tag AS tt
	ON tt.id_tag = btp.id_tag
    INNER JOIN blg_postsheader AS bph
    ON bph.id = btp.id_post
	WHERE tt.id_language = langid
    AND bph.actif = 1
	GROUP BY btp.id_tag
    ORDER BY tt.traduction;
END$$

CREATE DEFINER=`dbo621031148`@`%` PROCEDURE `sel_PostMessage`(IN `langue` VARCHAR(3), IN `blogid` INT)
BEGIN
	/*
		Permet de retrouver le texte d'un message par son id
	*/
	DECLARE langid INT;
    DECLARE lid INT;
    SET langid = (SELECT id FROM sys_languages WHERE langue_code = langue);
    SET lid = (SELECT COALESCE(SUM(id),0) FROM trd_post WHERE id_postsheader = blogid AND id_language = langid);
    IF (lid = 0) THEN 
		SET langid = 1;
	END IF;
    SELECT tp.titre AS titre, tp.description AS description,
	fun_DateAlphaTraduit(bph.date_publie, langid , 0) AS ladate
	FROM trd_post AS tp
    INNER JOIN blg_postsheader AS bph
    ON bph.id = tp.id_postsheader
	WHERE id_language = langid
	AND id_postsheader = blogid;
END$$

CREATE DEFINER=`dbo621031148`@`%` PROCEDURE `sel_PostsParCategorie`(IN `langue` VARCHAR(3), IN `catid` INT)
BEGIN
	/*
		Permet de retrouver les posts par catégories
    */
    DECLARE langid INT;
    SET langid = (SELECT id FROM sys_languages WHERE langue_code = langue);
    SELECT btp.id_post AS postid, tp.title_link AS lien,
	tp.titre AS titre, substr(tp.description,1,400) AS description,
	fun_DateAlphaTraduit(bph.date_publie,langid,0) AS ladate
	FROM blg_tag_post AS btp
	INNER JOIN blg_postsheader AS bph
	ON bph.id = btp.id_post
	INNER JOIN trd_post AS tp
	ON tp.id_postsheader = btp.id_post
    WHERE btp.id_tag = catid
    AND tp.id_language = langid
    AND bph.actif = 1
    ORDER BY bph.date_publie DESC;
END$$

CREATE DEFINER=`dbo621031148`@`%` PROCEDURE `sel_RetrouverJour`(IN `langue` VARCHAR(3), IN `jour` INT)
BEGIN
	DECLARE langid INT;
    SET langid = (SELECT id FROM sys_languages WHERE langue_code = langue);
	SELECT traduction 
    FROM trd_jour
    WHERE id_language = langid
    AND id_jour = jour;
END$$

CREATE DEFINER=`dbo621031148`@`%` PROCEDURE `sel_SidecolMenu`(IN `langue` VARCHAR(3), IN `categ` VARCHAR(4))
BEGIN
	DECLARE langid INT;
    SET langid=(SELECT id FROM sys_languages WHERE langue_code = langue);
	SELECT th.traduction AS traduction, th.title_traduction AS title,
	sh.fichier AS fichier, sh.categorie AS categorie
	FROM sys_homemenu AS sh
	INNER JOIN trd_homemenu AS th
	ON th.id_homemenu = sh.id
	WHERE th.id_language = langid
	AND sh.actif = 1
	AND sh.categorie = categ
	ORDER BY sh.ordre;
END$$

CREATE DEFINER=`dbo621031148`@`%` PROCEDURE `sel_TraductionFermetureException`(IN `langue` VARCHAR(3))
BEGIN
	DECLARE langid INT;
    DECLARE avfer VARCHAR(6000);
    DECLARE apfer VARCHAR(6000);
    SET langid = (SELECT  id FROM sys_languages WHERE langue_code = langue);
    SET avfer = (SELECT traduction 
				FROM trd_general AS tg
				INNER JOIN sys_definition AS sd
				ON tg.id_definition = sd.id
				WHERE sd.definition = 'fermeture_except_debut'
				AND tg.id_langue = langid);
	SET apfer = (SELECT traduction 
				FROM trd_general AS tg
				INNER JOIN sys_definition AS sd
				ON tg.id_definition = sd.id
				WHERE sd.definition = 'fermeture_except_fin'
				AND tg.id_langue = langid);
	SELECT avfer, apfer;
END$$

CREATE DEFINER=`dbo621031148`@`%` PROCEDURE `sel_Traductions`(IN `langue` VARCHAR(3), IN `currentfile` VARCHAR(45))
BEGIN
	DECLARE langid INT;
	SET langid = (SELECT id FROM sys_languages WHERE langue_code = langue);
	SELECT sd.definition AS def, 
    tg.traduction AS trad
	FROM trd_general AS tg
	INNER JOIN sys_page AS sp
	ON tg.id_page = sp.id
	INNER JOIN sys_definition AS sd
	ON tg.id_definition = sd.id
	WHERE tg.id_langue = langid
	AND sp.page = currentfile
    AND sd.actif = 1;
END$$

CREATE DEFINER=`dbo621031148`@`%` PROCEDURE `sel_VerifiePays`(IN `code_pays` VARCHAR(3))
BEGIN
	SELECT COUNT(langue_code) AS result FROM sys_languages
	WHERE langue_code = code_pays;
END$$

--
-- Fonctions
--
CREATE DEFINER=`dbo621031148`@`%` FUNCTION `fun_DateAlphaTraduit`(`ladate` DATE, `langid` INT, `flagjour` TINYINT(1)) RETURNS varchar(75) CHARSET latin1 COLLATE latin1_general_ci
BEGIN
	/*
		fonction qui permet de créer la date en lettre à partir de mysql
        utilisée dans certaine procédure (blog par example)
        on passe :
			- une date
            - id de la langue
            - flag jour 1 pour faire apparaitre le jour de la semaine sinon 0
	*/
    DECLARE id_def INT; /*	utilisé pour retrouver id de publie_le */
    DECLARE lemois VARCHAR(45);
    DECLARE lejour VARCHAR(45);
    DECLARE publiele VARCHAR(45);
    DECLARE letext VARCHAR(75);
    /* mettre les variables */
    SET id_def = (SELECT id FROM sys_definition WHERE definition='publie_le');
    SET lejour = (SELECT traduction FROM trd_jour WHERE id_jour = DAYOFWEEK(ladate) AND id_language = langid);
    SET lemois = (SELECT traduction FROM trd_mois WHERE id_mois = MONTH(ladate) AND id_language = langid);
    SET publiele = (SELECT traduction FROM trd_general WHERE id_definition = id_def AND id_langue = langid);
    if flagjour = 1 then
		SET letext = CONCAT_WS(' ', publiele, lejour, DAY(ladate), lemois, YEAR(ladate));
	else
		SET letext = CONCAT_WS(' ', publiele, DAY(ladate), lemois, YEAR(ladate));
	end if;
    RETURN letext;
END$$

CREATE DEFINER=`dbo621031148`@`%` FUNCTION `fun_ReturnHoraire`(`horaireID` INT) RETURNS varchar(10) CHARSET latin1 COLLATE latin1_general_ci
BEGIN
	/*
		Fonction qui permet de retrouver le nom de l'horaire selon son code
	*/
    DECLARE lhoraire VARCHAR(10);
    SET lhoraire = (SELECT horaire FROM sys_type_horaire WHERE id = horaireID);    
RETURN lhoraire;
END$$

CREATE DEFINER=`dbo621031148`@`%` FUNCTION `fun_TraductionGalerie`(`langue` INT, `typetrad` VARCHAR(25), `image` INT) RETURNS varchar(3000) CHARSET latin1 COLLATE latin1_general_ci
BEGIN
	DECLARE reponse VARCHAR(3000);
    DECLARE typeid INT;
    SET typeid = (SELECT id FROM sys_type_trad_img_gal 
				  WHERE type_traduction = typetrad);
    SET reponse = (SELECT traduction FROM trd_galerie 
				   WHERE id_language = langue AND
                   id_type_trad = typeid AND
                   id_image = image);                    
RETURN reponse;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `blg_comment`
--

CREATE TABLE IF NOT EXISTS `blg_comment` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `id_post` int(11) NOT NULL,
  `level_id` int(11) NOT NULL DEFAULT '0' COMMENT 'ce champs permet de répondre à un autre commentaire : si 0 commentaire de premier niveau si différent de 0 nous répondons à un commentaire identifié par blg_comment.id Table récurssive',
  `auteur` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `date` date NOT NULL,
  `commentaire` text,
  `etat` enum('actif','sleep','suppr') NOT NULL DEFAULT 'sleep',
  PRIMARY KEY (`id`),
  KEY `FK_BLGCOM_POSTH_idx` (`id_post`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='table permettant d''enregistrer les commentaire Ceux ci ne seront pas traduits' AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Structure de la table `blg_postsheader`
--

CREATE TABLE IF NOT EXISTS `blg_postsheader` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `titre` varchar(255) NOT NULL,
  `date_publie` date DEFAULT NULL,
  `actif` tinyint(1) NOT NULL,
  `image_thumb` varchar(45) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COMMENT='table regroupant les headers des posts du blog' AUTO_INCREMENT=5 ;

--
-- Contenu de la table `blg_postsheader`
--

INSERT INTO `blg_postsheader` (`id`, `titre`, `date_publie`, `actif`, `image_thumb`) VALUES
(1, 'gloria maris', '2016-02-18', 0, 'th_gloriamaris01.jpg'),
(2, 'veau tigré', '2016-02-08', 0, 'th_abbatucci01.jpg'),
(3, 'françois albertini', '2015-12-08', 0, 'th_albertini01.jpg'),
(4, 'visite muna', '2016-03-08', 0, 'th_muna01.jpg');

-- --------------------------------------------------------

--
-- Structure de la table `blg_tag`
--

CREATE TABLE IF NOT EXISTS `blg_tag` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nom` varchar(45) NOT NULL,
  `nombre` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COMMENT='table pour les tags du blog' AUTO_INCREMENT=8 ;

--
-- Contenu de la table `blg_tag`
--

INSERT INTO `blg_tag` (`id`, `nom`, `nombre`) VALUES
(1, 'visite', 1),
(2, 'patrimoine', 1),
(3, 'producteur', 0),
(4, 'éleveur', 3),
(5, 'recette', 0),
(6, 'artisanat', 0),
(7, 'rencontre', 1);

-- --------------------------------------------------------

--
-- Structure de la table `blg_tag_post`
--

CREATE TABLE IF NOT EXISTS `blg_tag_post` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `id_tag` int(11) NOT NULL,
  `id_post` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_BLGTAPO_TAG_idx` (`id_tag`),
  KEY `FK_BLGTAPO_POST_idx` (`id_post`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COMMENT='table faisant le joint entre un post et ses tags' AUTO_INCREMENT=7 ;

--
-- Contenu de la table `blg_tag_post`
--

INSERT INTO `blg_tag_post` (`id`, `id_tag`, `id_post`) VALUES
(1, 4, 1),
(2, 4, 2),
(3, 4, 3),
(4, 7, 3),
(5, 1, 4),
(6, 2, 4);

-- --------------------------------------------------------

--
-- Structure de la table `img_galerie`
--

CREATE TABLE IF NOT EXISTS `img_galerie` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `fichier` varchar(45) NOT NULL,
  `thumb` varchar(45) NOT NULL,
  `actif` tinyint(1) NOT NULL,
  `width` int(11) NOT NULL,
  `height` int(11) NOT NULL,
  `date` date NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COMMENT='table contenant le détail des images de la galerie' AUTO_INCREMENT=22 ;

--
-- Contenu de la table `img_galerie`
--

INSERT INTO `img_galerie` (`id`, `fichier`, `thumb`, `actif`, `width`, `height`, `date`) VALUES
(1, 'img_01603022713.jpg', 'th_01603022713.jpg', 1, 200, 300, '2015-05-02'),
(2, 'img_01603023213.jpg', 'th_01603023213.jpg', 1, 200, 150, '2015-05-02'),
(3, 'img_01603023613.jpg', 'th_01603023613.jpg', 1, 200, 200, '2015-05-02'),
(4, 'img_01603024013.jpg', 'th_01603024013.jpg', 1, 200, 300, '2015-08-19'),
(5, 'img_01603024713.jpg', 'th_01603024713.jpg', 0, 200, 106, '2015-09-16'),
(6, 'img_01603025313.jpg', 'th_01603025313.jpg', 1, 200, 250, '2015-09-16'),
(7, 'img_01603025913.jpg', 'th_01603025913.jpg', 1, 200, 250, '2015-09-16'),
(8, 'img_01603025613.jpg', 'th_01603025613.jpg', 1, 200, 200, '2015-09-16'),
(9, 'img_01603025013.jpg', 'th_01603025013.jpg', 0, 200, 150, '2015-11-06'),
(10, 'img_01603020414.jpg', 'th_01603020414.jpg', 1, 200, 300, '2015-10-13'),
(11, 'img_01603021314.jpg', 'th_01603021314.jpg', 0, 200, 105, '2016-01-25'),
(12, 'img201604081622.jpg', 'thb201604081622.jpg', 1, 200, 150, '2016-04-08'),
(13, 'img201604081630.jpg', 'thb201604081630.jpg', 1, 200, 175, '2016-04-08'),
(14, 'img201604081635.jpg', 'thb201604081635.jpg', 1, 200, 150, '2016-04-08'),
(15, 'img201604081639.jpg', 'thb201604081639.jpg', 1, 200, 200, '2016-04-08'),
(16, 'img201604081644.jpg', 'thb201604081644.jpg', 1, 200, 180, '2016-04-08'),
(17, 'img201604081649.jpg', 'thb201604081649.jpg', 1, 200, 250, '2016-04-08'),
(18, 'img201604081701.jpg', 'thb201604081701.jpg', 1, 200, 180, '2016-04-08'),
(19, 'img201604081715.jpg', 'thb201604081715.jpg', 1, 200, 170, '2016-04-08'),
(20, 'img201604081718.jpg', 'thb201604081718.jpg', 1, 200, 250, '2016-04-08'),
(21, 'img201604081722.jpg', 'thb201604081722.jpg', 1, 200, 200, '2016-04-08');

-- --------------------------------------------------------

--
-- Structure de la table `img_slide`
--

CREATE TABLE IF NOT EXISTS `img_slide` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nom_slide` varchar(45) NOT NULL,
  `image` varchar(75) NOT NULL,
  `actif` tinyint(1) NOT NULL,
  `ordre` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COMMENT='table comprenant les images du slider d''intro' AUTO_INCREMENT=6 ;

--
-- Contenu de la table `img_slide`
--

INSERT INTO `img_slide` (`id`, `nom_slide`, `image`, `actif`, `ordre`) VALUES
(1, 'slide0', 'slide0.jpg', 1, 1),
(2, 'slide1', 'slide1.jpg', 1, 2),
(3, 'slide2', 'slide2.jpg', 1, 3),
(4, 'slide3', 'slide3.jpg', 1, 4),
(5, 'slide4', 'slide4.jpg', 1, 5);

-- --------------------------------------------------------

--
-- Structure de la table `sys_definition`
--

CREATE TABLE IF NOT EXISTS `sys_definition` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `definition` varchar(45) NOT NULL,
  `actif` tinyint(1) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COMMENT='ensemble des définitions du site pour les traductions' AUTO_INCREMENT=92 ;

--
-- Contenu de la table `sys_definition`
--

INSERT INTO `sys_definition` (`id`, `definition`, `actif`) VALUES
(1, 'page_title', 1),
(2, 'meta_desc', 1),
(3, 'meta_tag', 1),
(4, 'alt_logo_restaurant', 1),
(5, 'affichage_navigation', 1),
(6, 'alt_drapeau_français', 1),
(7, 'alt_drapeau_english', 1),
(8, 'alt_drapeau_corsu', 1),
(9, 'header_nosmenus', 1),
(10, 'header_nosactus', 0),
(11, 'header_nosblog', 0),
(12, 'publie_le', 1),
(13, 'lire_article', 1),
(14, 'bienvenue_index', 1),
(15, 'sstitre_index', 1),
(16, 'intro_index', 1),
(17, 'slide0', 1),
(18, 'slide1', 1),
(19, 'slide2', 1),
(20, 'slide3', 1),
(21, 'slide4', 1),
(22, 'header_notre_etab', 1),
(23, 'notre_etab_para1', 1),
(24, 'notre_etab_para2', 1),
(25, 'alt_image_notre_etab', 1),
(26, 'footer_notre_etab_header', 1),
(27, 'footer_notre_etab', 1),
(28, 'footer_mention_legal', 1),
(29, 'footer_site_map', 1),
(30, 'footer_abus_alcool', 1),
(31, 'footer_horaire_header', 1),
(32, 'horaire_ferme', 1),
(33, 'fer_ann_debut', 1),
(34, 'fer_ann_mid', 1),
(35, 'fer_ann_fin', 1),
(36, 'fermeture_except_debut', 1),
(37, 'fermeture_except_fin', 1),
(38, 'numero_telephone', 1),
(39, 'footer_contactez_nous', 1),
(40, 'footer_telephone', 1),
(41, 'footer_email', 1),
(42, 'footer_adresse', 1),
(43, 'info_header', 1),
(44, 'info_message1', 1),
(45, 'info_message2', 1),
(46, 'info_message3', 1),
(47, 'info_avion_header', 1),
(48, 'info_avion_mess1', 1),
(49, 'info_avion_mess2', 1),
(50, 'info_bateau_header', 1),
(51, 'info_bateau_mess1', 1),
(52, 'info_bateau_mess2', 1),
(53, 'info_bateau_mess3', 1),
(54, 'info_train_header', 1),
(55, 'info_train_mess1', 1),
(56, 'info_train_mess2', 1),
(57, 'info_auto_header', 1),
(58, 'info_auto_mess1', 1),
(59, 'info_auto_mess2', 1),
(60, 'info_venir_header', 1),
(61, 'header_media', 1),
(62, 'blog_categorie_header', 1),
(63, 'blog_dernier_art_header', 1),
(64, 'blog_dernier_comm_header', 0),
(65, 'blog_archive_header', 1),
(66, 'lire_suite_article', 1),
(67, 'derniers_article_header_blog', 1),
(68, 'cont_contacts', 1),
(69, 'cont_reseaux_soc', 1),
(70, 'cont_form_contact', 1),
(71, 'cont_phrase1', 1),
(72, 'cont_phrase2', 1),
(73, 'cont_phrase3', 1),
(74, 'cont_nom', 1),
(75, 'cont_sujet', 1),
(76, 'cont_mess', 1),
(77, 'cont_envoy', 1),
(78, 'cont_missing_nom', 1),
(79, 'cont_missing_mail', 1),
(80, 'cont_missing_phone', 1),
(81, 'cont_missing_sujet', 1),
(82, 'cont_missing_mess', 1),
(83, 'cont_invalid_mail', 1),
(84, 'cont_invalid_phone', 1),
(85, 'cont_mailparti1', 1),
(86, 'cont_mailparti2', 1),
(87, 'sitemap_header', 1),
(88, 'sitemap_intro', 1),
(89, 'mentions_legales_header', 1),
(90, 'message_page_index', 0),
(91, 'intro_horaire', 0);

-- --------------------------------------------------------

--
-- Structure de la table `sys_drapeau`
--

CREATE TABLE IF NOT EXISTS `sys_drapeau` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nom` varchar(45) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COMMENT='table pour retrouver le nom des drapeau' AUTO_INCREMENT=4 ;

--
-- Contenu de la table `sys_drapeau`
--

INSERT INTO `sys_drapeau` (`id`, `nom`) VALUES
(1, 'Français'),
(2, 'English'),
(3, 'Corsu');

-- --------------------------------------------------------

--
-- Structure de la table `sys_homemenu`
--

CREATE TABLE IF NOT EXISTS `sys_homemenu` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nom` varchar(100) NOT NULL,
  `fichier` varchar(45) NOT NULL,
  `actif` tinyint(1) NOT NULL,
  `categorie` enum('menu','actu') NOT NULL,
  `ordre` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COMMENT='table permettant d''enregistrer les liens pour les menus et actus page d''index' AUTO_INCREMENT=7 ;

--
-- Contenu de la table `sys_homemenu`
--

INSERT INTO `sys_homemenu` (`id`, `nom`, `fichier`, `actif`, `categorie`, `ordre`) VALUES
(1, 'formule_midi', 'formule', 1, 'menu', 1),
(2, 'fast_good_midi', 'fastgood', 0, 'menu', 2),
(3, 'carte_soir', 'carte', 0, 'menu', 3),
(4, 'carte_vin', 'cartevins', 0, 'menu', 4),
(5, 'semaine_vigneron', 'vigneron', 0, 'actu', 1),
(6, 'promotion_semaine', 'promo', 0, 'actu', 2);

-- --------------------------------------------------------

--
-- Structure de la table `sys_horaires`
--

CREATE TABLE IF NOT EXISTS `sys_horaires` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `id_jour` int(11) NOT NULL,
  `debut_am` int(11) NOT NULL,
  `fin_am` int(11) NOT NULL,
  `debut_pm` int(11) NOT NULL,
  `fin_pm` int(11) NOT NULL,
  `ferme_execp` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'fermetureexceptionelle ce jour',
  `ordre` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_SYSHOR_JOUR_idx` (`id_jour`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COMMENT='table proposant les horaires d''ouverture du restaurant' AUTO_INCREMENT=8 ;

--
-- Contenu de la table `sys_horaires`
--

INSERT INTO `sys_horaires` (`id`, `id_jour`, `debut_am`, `fin_am`, `debut_pm`, `fin_pm`, `ferme_execp`, `ordre`) VALUES
(1, 1, 1, 1, 35, 35, 0, 7),
(2, 2, 10, 18, 46, 56, 0, 1),
(3, 3, 10, 18, 46, 56, 0, 2),
(4, 4, 10, 18, 46, 56, 0, 3),
(5, 5, 10, 18, 46, 56, 0, 4),
(6, 6, 10, 18, 46, 56, 0, 5),
(7, 7, 10, 18, 46, 56, 0, 6);

-- --------------------------------------------------------

--
-- Structure de la table `sys_jour`
--

CREATE TABLE IF NOT EXISTS `sys_jour` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nom` varchar(45) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COMMENT='table des jours de la semaine' AUTO_INCREMENT=8 ;

--
-- Contenu de la table `sys_jour`
--

INSERT INTO `sys_jour` (`id`, `nom`) VALUES
(1, 'dimanche'),
(2, 'lundi'),
(3, 'mardi'),
(4, 'mercredi'),
(5, 'jeudi'),
(6, 'vendredi'),
(7, 'samedi');

-- --------------------------------------------------------

--
-- Structure de la table `sys_languages`
--

CREATE TABLE IF NOT EXISTS `sys_languages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `langue` varchar(45) NOT NULL,
  `actif` tinyint(1) NOT NULL,
  `drapeau` varchar(45) NOT NULL,
  `langue_code` varchar(3) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COMMENT='Tables regroupant les différents languages du site' AUTO_INCREMENT=4 ;

--
-- Contenu de la table `sys_languages`
--

INSERT INTO `sys_languages` (`id`, `langue`, `actif`, `drapeau`, `langue_code`) VALUES
(1, 'Français', 1, 'flag_fr.png', 'fra'),
(2, 'English', 1, 'flag_en.png', 'eng'),
(3, 'Corsu', 0, 'flag_co.png', 'cor');

-- --------------------------------------------------------

--
-- Structure de la table `sys_menuactus`
--

CREATE TABLE IF NOT EXISTS `sys_menuactus` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `id_homemenu` int(11) NOT NULL,
  `nom` varchar(45) NOT NULL,
  `actif` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `FK_MENUACTUS_HOME_idx` (`id_homemenu`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=5 ;

--
-- Contenu de la table `sys_menuactus`
--

INSERT INTO `sys_menuactus` (`id`, `id_homemenu`, `nom`, `actif`) VALUES
(1, 1, 'formule_midi', 1),
(2, 3, 'carte_soir', 1),
(3, 5, 'vigneron_alzipratu', 0),
(4, 2, 'fast_good_midi', 1);

-- --------------------------------------------------------

--
-- Structure de la table `sys_navigation`
--

CREATE TABLE IF NOT EXISTS `sys_navigation` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nom` varchar(45) NOT NULL,
  `fichier` varchar(45) NOT NULL,
  `icon` varchar(45) NOT NULL,
  `actif` tinyint(1) NOT NULL,
  `ordre` tinyint(1) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COMMENT='table correspondant aux détails des menus de navigation' AUTO_INCREMENT=6 ;

--
-- Contenu de la table `sys_navigation`
--

INSERT INTO `sys_navigation` (`id`, `nom`, `fichier`, `icon`, `actif`, `ordre`) VALUES
(1, 'nav_accueil', 'index', 'fa-home', 1, 1),
(2, 'nav_media', 'media', 'fa-image', 1, 2),
(3, 'nav_blog', 'blog', 'fa-commenting', 0, 3),
(4, 'nav_infos', 'infos', 'fa-info', 1, 4),
(5, 'nav_contact', 'contact', 'fa-envelope', 1, 5);

-- --------------------------------------------------------

--
-- Structure de la table `sys_page`
--

CREATE TABLE IF NOT EXISTS `sys_page` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `page` varchar(45) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COMMENT='ensemble des pages du site internet' AUTO_INCREMENT=10 ;

--
-- Contenu de la table `sys_page`
--

INSERT INTO `sys_page` (`id`, `page`) VALUES
(1, 'index'),
(2, 'media'),
(3, 'blog'),
(4, 'infos'),
(5, 'contact'),
(6, 'mentions'),
(7, 'plan'),
(8, 'commun'),
(9, 'internal_use_only');

-- --------------------------------------------------------

--
-- Structure de la table `sys_type_horaire`
--

CREATE TABLE IF NOT EXISTS `sys_type_horaire` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `horaire` varchar(10) NOT NULL,
  `am_pm` enum('matin','soir') NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COMMENT='table avec l''ensemble des horaires du système' AUTO_INCREMENT=61 ;

--
-- Contenu de la table `sys_type_horaire`
--

INSERT INTO `sys_type_horaire` (`id`, `horaire`, `am_pm`) VALUES
(1, 'fermé', 'matin'),
(2, '10h00', 'matin'),
(3, '10h15', 'matin'),
(4, '10h30', 'matin'),
(5, '10h45', 'matin'),
(6, '11h00', 'matin'),
(7, '11h15', 'matin'),
(8, '11h30', 'matin'),
(9, '11h45', 'matin'),
(10, '12h00', 'matin'),
(11, '12h15', 'matin'),
(12, '12h30', 'matin'),
(13, '12h45', 'matin'),
(14, '13h00', 'matin'),
(15, '13h15', 'matin'),
(16, '13h30', 'matin'),
(17, '13h45', 'matin'),
(18, '14h00', 'matin'),
(19, '14h15', 'matin'),
(20, '14h30', 'matin'),
(21, '14h45', 'matin'),
(22, '15h00', 'matin'),
(23, '15h15', 'matin'),
(24, '15h30', 'matin'),
(25, '15h45', 'matin'),
(26, '16h00', 'matin'),
(27, '16h15', 'matin'),
(28, '16h30', 'matin'),
(29, '16h45', 'matin'),
(30, '17h00', 'matin'),
(31, '17h15', 'matin'),
(32, '17h30', 'matin'),
(33, '17h45', 'matin'),
(34, '18h00', 'matin'),
(35, 'fermé', 'soir'),
(36, '17h00', 'soir'),
(37, '17h15', 'soir'),
(38, '17h30', 'soir'),
(39, '17h45', 'soir'),
(40, '18h00', 'soir'),
(41, '18h15', 'soir'),
(42, '18h30', 'soir'),
(43, '18h45', 'soir'),
(44, '19h00', 'soir'),
(45, '19h15', 'soir'),
(46, '19h30', 'soir'),
(47, '19h45', 'soir'),
(48, '20h00', 'soir'),
(49, '20h15', 'soir'),
(50, '20h30', 'soir'),
(51, '20h45', 'soir'),
(52, '21h00', 'soir'),
(53, '21h15', 'soir'),
(54, '21h30', 'soir'),
(55, '21h45', 'soir'),
(56, '22h00', 'soir'),
(57, '22h15', 'soir'),
(58, '22h30', 'soir'),
(59, '22h45', 'soir'),
(60, '23h00', 'soir');

-- --------------------------------------------------------

--
-- Structure de la table `sys_type_trad_img_gal`
--

CREATE TABLE IF NOT EXISTS `sys_type_trad_img_gal` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `type_traduction` varchar(25) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COMMENT='table comprenant le type de traduction pour la galerie d''image' AUTO_INCREMENT=5 ;

--
-- Contenu de la table `sys_type_trad_img_gal`
--

INSERT INTO `sys_type_trad_img_gal` (`id`, `type_traduction`) VALUES
(1, 'title'),
(2, 'alt'),
(3, 'header'),
(4, 'texte');

-- --------------------------------------------------------

--
-- Structure de la table `sys_variables`
--

CREATE TABLE IF NOT EXISTS `sys_variables` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nom` varchar(100) NOT NULL,
  `abr_nom` varchar(45) NOT NULL,
  `actif` tinyint(1) NOT NULL,
  `str_variable` varchar(300) NOT NULL DEFAULT '_',
  `int_variable` int(11) NOT NULL DEFAULT '-1',
  `str_autre` varchar(75) NOT NULL DEFAULT '_',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COMMENT='table permettant de mettre plusierus variables générales du site' AUTO_INCREMENT=9 ;

--
-- Contenu de la table `sys_variables`
--

INSERT INTO `sys_variables` (`id`, `nom`, `abr_nom`, `actif`, `str_variable`, `int_variable`, `str_autre`) VALUES
(1, 'Affichage menus page accueil', 'header_nosmenus', 1, '_', -1, '_'),
(2, 'Affichage actus page d''accueil', 'header_nosactus', 1, '_', -1, '_'),
(3, 'Affichage post récent page d''accueil', 'header_nosblog', 0, '_', -1, '_'),
(4, 'Autoriser les commentaires sur le blog', 'allow_comment_on_post', 0, '_', -1, '_'),
(5, 'Fermeture exceptionnelle', 'fermeture_exception', 0, '3', -1, '_'),
(6, 'Fermeture annuelle', 'fermeture_annuelle', 1, 'fer_ann_fin', 4, '2018'),
(7, 'Affichage légende dans la galerie', 'affiche_legende_galerie', 0, '_', -1, '_'),
(8, 'Affichage des icones du menu de navigation', 'affiche_icone_navigation', 0, '_', -1, '_');

-- --------------------------------------------------------

--
-- Structure de la table `trd_drapeau`
--

CREATE TABLE IF NOT EXISTS `trd_drapeau` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `id_langue` int(11) NOT NULL,
  `id_drapeau` int(11) NOT NULL,
  `traduction` varchar(45) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_TDRAPEAU_LANG_idx` (`id_langue`),
  KEY `FK_TDRAPEAU_DRAP_idx` (`id_drapeau`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COMMENT='table de traduction pour drapeau' AUTO_INCREMENT=10 ;

--
-- Contenu de la table `trd_drapeau`
--

INSERT INTO `trd_drapeau` (`id`, `id_langue`, `id_drapeau`, `traduction`) VALUES
(1, 1, 1, 'drapeau français'),
(2, 1, 2, 'drapeau anglais'),
(3, 1, 3, 'drapeau corse'),
(4, 2, 1, 'french flag'),
(5, 2, 2, 'english flag'),
(6, 2, 3, 'corsican flag'),
(7, 3, 1, 'bandiera francese'),
(8, 3, 2, 'bandiera inglese'),
(9, 3, 3, 'bannera Corsica');

-- --------------------------------------------------------

--
-- Structure de la table `trd_galerie`
--

CREATE TABLE IF NOT EXISTS `trd_galerie` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `id_language` int(11) NOT NULL,
  `id_type_trad` int(11) NOT NULL,
  `id_image` int(11) NOT NULL,
  `traduction` varchar(3000) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_TRDGAL_LANG_idx` (`id_language`),
  KEY `FK_TRDGAL_STYPETRA_idx` (`id_type_trad`),
  KEY `FK_TRDGAL_GALE_idx` (`id_image`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COMMENT='table contenant les traductions de la galerie d''image' AUTO_INCREMENT=258 ;

--
-- Contenu de la table `trd_galerie`
--

INSERT INTO `trd_galerie` (`id`, `id_language`, `id_type_trad`, `id_image`, `traduction`) VALUES
(1, 1, 1, 1, 'Ange Cananzi en compagnie de Pascal Cayeux'),
(2, 2, 1, 1, 'Ange Cananzi with Pascal Cayeux'),
(3, 3, 1, 1, 'Ange Cananzi cu Pascal Cayeux'),
(4, 1, 2, 1, 'Avec Pascal Cayeux'),
(5, 2, 2, 1, 'With Pascal Cayeux'),
(6, 3, 2, 1, 'Cù Pascal Cayeux'),
(7, 1, 3, 1, 'Aléria 2015'),
(8, 2, 3, 1, 'Aléria 2015'),
(9, 3, 3, 1, 'Aléria 2015'),
(10, 1, 4, 1, 'Ange Cananzi en compagnie de Pascal Cayeux, chef au restaurant Cala rossa à Porto-Vecchio.'),
(11, 2, 4, 1, 'Ange Cananzi with Pascal Cayeux, head chef at the restaurant Cala Rossa in Porto-Vecchio.'),
(12, 3, 4, 1, 'Ange Cananzi cu Pascal Cayeux, capu à u risturante Cala Rossa à Porto-Vecchio.'),
(13, 1, 1, 2, 'Ange Cananzi avec Hélène Darroze'),
(14, 2, 1, 2, 'Ange Cananzi with Hélène Darroze'),
(15, 3, 1, 2, 'Ange Cananzi cù Hélène Darroze'),
(16, 1, 2, 2, 'Avec Hélène Darroze'),
(17, 2, 2, 2, 'With Hélène Darroze'),
(18, 3, 2, 2, 'Cù Hélène Darroze'),
(19, 1, 3, 2, 'Aléria 2015'),
(20, 2, 3, 2, 'Aléria 2015'),
(21, 3, 3, 2, 'Aléria 2015'),
(22, 1, 4, 2, 'Ange Cananzi avec Hélène Darroze, chef triplement étoilée.'),
(23, 2, 4, 2, 'Ange Cananzi with Hélène Darroze, three stars in the Michelin Guide.'),
(24, 3, 4, 2, 'Ange Cananzi cu Hélène Darroze, traversée triplici stelle.'),
(25, 1, 1, 3, 'Ange Cananzi et Pierre Hermé'),
(26, 2, 1, 3, 'Ange Cananzi and Pierre Hermé'),
(27, 3, 1, 3, 'Ange Cananzi è Pierre Hermé'),
(28, 1, 2, 3, 'Avec Pierre Hermé'),
(29, 2, 2, 3, 'With Pierre Hermé'),
(30, 3, 2, 3, 'Cù Pierre Hermé'),
(31, 1, 3, 3, 'Aléria 2015'),
(32, 2, 3, 3, 'Aléria 2015'),
(33, 3, 3, 3, 'Aléria 2015'),
(34, 1, 4, 3, 'Ange Cananzi et Pierre Hermé, le patissier de renommée mondiale.'),
(35, 2, 4, 3, 'Ange Cananzi and Pierre Hermé, the world renowned patissier.'),
(36, 3, 4, 3, 'Ange Cananzi è Pierre Hermé, u famosu Patissier mondu.'),
(37, 1, 1, 4, 'Ange Cananzi avec Bernard Pacaud'),
(38, 2, 1, 4, 'Ange Cananzi with Bernard Pacaud'),
(39, 3, 1, 4, 'Ange Cananzi è Bernard Pacaud'),
(40, 1, 2, 4, 'Avec Bernard Pacaud'),
(41, 2, 2, 4, 'With Bernard Pacaud'),
(42, 3, 2, 4, 'Cù Bernard Pacaud'),
(43, 1, 3, 4, 'L''Ile Rousse 2015'),
(44, 2, 3, 4, 'L''Ile Rousse 2015'),
(45, 3, 3, 4, 'Isula Rossa 2015'),
(46, 1, 4, 4, 'Lors d''une de ses visites dans notre établissement, Bernard Pacaud s''est livré au jeu des photos.'),
(47, 2, 4, 4, 'During one of his visists in our establishment, Bernard Pacaud took the time to pose for photographies.'),
(48, 3, 4, 4, 'CO_Lors d''une de ses visites dans notre établissement, Bernard Pacaud s''est livré au jeu des photos.'),
(49, 1, 1, 5, 'Notre terrasse dressée pour un groupe'),
(50, 2, 1, 5, 'Our terrace prepared for a group'),
(51, 3, 1, 5, 'CO_Notre terrasse dressée pour un groupe'),
(52, 1, 2, 5, 'Notre terrasse'),
(53, 2, 2, 5, 'Our terrace'),
(54, 3, 2, 5, 'CO_Notre terrasse'),
(55, 1, 3, 5, 'Notre restaurant'),
(56, 2, 3, 5, 'Our restaurant'),
(57, 3, 3, 5, 'CO_Notre restaurant'),
(58, 1, 4, 5, 'Notre terrasse dressée pour un repas de groupe.'),
(59, 2, 4, 5, 'Notre terrace prepared for a meal for a group.'),
(60, 3, 4, 5, 'CO_Notre terrasse dressée pour un repas de groupe.'),
(61, 1, 1, 6, 'La petite terrasse juste devant l''entrée'),
(62, 2, 1, 6, 'The small terrace near the restaurant entrance'),
(63, 3, 1, 6, 'CO_La petite terrasse juste devant l''entrée'),
(64, 1, 2, 6, 'Entrée du restaurant'),
(65, 2, 2, 6, 'Restaurant''s entrance'),
(66, 3, 2, 6, 'CO_Entrée du restaurant'),
(67, 1, 3, 6, 'Notre restaurant'),
(68, 2, 3, 6, 'Our restaurant'),
(69, 3, 3, 6, 'CO_Notre restaurant'),
(70, 1, 4, 6, 'Dès les premiers beaux jours, nous vous proposons de vous restaurer sur notre petite terrasse.'),
(71, 2, 4, 6, 'As soon as the weather permits, you may eat on our small terrace.'),
(72, 3, 4, 6, 'CO_des premiers beaux jours, nous vous proposons de vous restaurer sur notre petite terrasse.'),
(73, 1, 1, 7, 'A l''intérieur de notre restaurant, le buste de Paoli veille...'),
(74, 2, 1, 7, 'Inside the restaurant, the bust of Paoli watches over...'),
(75, 3, 1, 7, 'CO_Indrentu à a carta, u bustu di Paoli vigilia...'),
(76, 1, 2, 7, 'La salle du restaurant'),
(77, 2, 2, 7, 'Our restaurant''s room'),
(78, 3, 2, 7, 'CO_La salle du restaurant'),
(79, 1, 3, 7, 'Notre restaurant'),
(80, 2, 3, 7, 'Our restaurant'),
(81, 3, 3, 7, 'CO_Notre restaurant'),
(82, 1, 4, 7, 'Notre salle intérieure, avec le buste de Pasquale Paoli, "U Babbu di a Patria".'),
(83, 2, 4, 7, 'Our main room with the bust of Pasquale Paoli, "U Babbu di a Patria".'),
(84, 3, 4, 7, 'CO_Notre salle intérieure, avec le buste de Pasquale Paoli, "U Babbu di a Patria".'),
(85, 1, 1, 8, 'Quelques bouteilles de notre cave'),
(86, 2, 1, 8, 'Some bottles in our cellar'),
(87, 3, 1, 8, 'Arcuni di buttigli di a nostra cantina'),
(88, 1, 2, 8, 'Notre cave'),
(89, 2, 2, 8, 'Our cellar'),
(90, 3, 2, 8, 'A nostra cantina'),
(91, 1, 3, 8, 'Notre restaurant'),
(92, 2, 3, 8, 'Our restaurant'),
(93, 3, 3, 8, 'CO_Notre restaurant'),
(94, 1, 4, 8, 'Notre cave possède une sélection de quelques uns des meilleurs crus de Corse et du continent.'),
(95, 2, 4, 8, 'Our cellar has a selection of some of the best wines from Corsica and from the mainland.'),
(96, 3, 4, 8, 'A nostra cantina, hà una selezzione di certi di i più boni vini di a Corsica è u cuntinente.'),
(97, 1, 1, 9, 'Une proposition de notre nouvelle formule du midi'),
(98, 2, 1, 9, 'A proposal from our new lunchtime menu'),
(99, 3, 1, 9, 'Una pruposta per u nostru novu lunching'),
(100, 1, 2, 9, 'Burger au Veau'),
(101, 2, 2, 9, 'Veal burger'),
(102, 3, 2, 9, 'CO_Burger au Veau'),
(103, 1, 3, 9, 'Plats'),
(104, 2, 3, 9, 'Dishes'),
(105, 3, 3, 9, 'CO_Plats'),
(106, 1, 4, 9, 'Un hamburger fait maison avec du jarret de veau fermier de Nessa confit en cocotte lutée.'),
(107, 2, 4, 9, 'A burger with homemade farmeed veal shank from Nessa, slowly cooked in luted casserole.'),
(108, 3, 4, 9, 'CO_Un hamburger fait maison avec du jarret de veau fermier de Nessa confit en cocotte lutée.'),
(109, 1, 1, 10, 'Souvenir de Muna'),
(110, 2, 1, 10, 'Memories from Muna'),
(111, 3, 1, 10, 'CO_Souvenir de Muna'),
(112, 1, 2, 10, 'Cabri rôti'),
(113, 2, 2, 10, 'Roasted srping goat'),
(114, 3, 2, 10, 'CO_Cabri rôti'),
(115, 1, 3, 10, 'Muna'),
(116, 2, 3, 10, 'Muna'),
(117, 3, 3, 10, 'Muna'),
(118, 1, 4, 10, 'Un morceau de cabri rôti à la braise'),
(119, 2, 4, 10, 'A piece of roasted spring goat'),
(120, 3, 4, 10, 'CO_Un morceau de cabri rôti à la braise'),
(121, 1, 1, 11, 'Souvenir de Muna'),
(122, 2, 1, 11, 'Memories from Muna'),
(123, 3, 1, 11, 'CO_Souvenir de Muna'),
(124, 1, 2, 11, 'Cochons Corses'),
(125, 2, 2, 11, 'Corsican Pigs'),
(126, 3, 2, 11, 'CO_Cochons Corses'),
(127, 1, 3, 11, 'Muna'),
(128, 2, 3, 11, 'Muna'),
(129, 3, 3, 11, 'Muna'),
(130, 1, 4, 11, 'Quelques cochons Corses, en pleine nature.'),
(131, 2, 4, 11, 'Some Corsican Pigs, in the wild.'),
(132, 3, 4, 11, 'CO_Quelques cochons Corses, en pleine nature'),
(133, 1, 1, 12, 'Ancienne tour en bord de mer'),
(134, 2, 1, 12, 'Old tower by the seaside'),
(135, 3, 1, 12, 'CO_Ancienne tour en bord de mer'),
(136, 1, 2, 12, 'Patrimoine Corse'),
(137, 2, 2, 12, 'Corsican heritage'),
(138, 3, 2, 12, 'CO_Patrimoine Corse'),
(139, 1, 3, 12, 'Bord de mer'),
(140, 2, 3, 12, 'Seaside'),
(141, 3, 3, 12, 'Bord de mer'),
(142, 1, 4, 12, 'Une ancienne tour en bord de mer, richesse de notre patrimoine.'),
(143, 2, 4, 12, 'An old tower by the seaside, from our rich heritage.'),
(144, 3, 4, 12, 'CO_Une ancienne tour en bord de mer, richesse de notre patrimoine.'),
(145, 1, 1, 13, 'Vacances en mer'),
(146, 2, 1, 13, 'Holidays on sea'),
(147, 3, 1, 13, 'CO_Vacances en mer'),
(148, 1, 2, 13, 'En mer'),
(149, 2, 2, 13, 'At sea'),
(150, 3, 2, 13, 'CO_En mer'),
(151, 1, 3, 13, 'Voilier'),
(152, 2, 3, 13, 'Sailing boat'),
(153, 3, 3, 13, 'CO_Voilier'),
(154, 1, 4, 13, 'La mer, les vacances, la Corse...'),
(155, 2, 4, 13, 'Sea, holidays, Corsica...'),
(156, 3, 4, 13, 'CO_La mer, les vacances, la Corse...'),
(157, 1, 1, 14, 'Le port de Centuri'),
(158, 2, 1, 14, 'Centuri''s harbour'),
(159, 3, 1, 14, 'CO_Le port de Centuri'),
(160, 1, 2, 14, 'Centuri'),
(161, 2, 2, 14, 'Centuri'),
(162, 3, 2, 14, 'Centuri'),
(163, 1, 3, 14, 'Centuri'),
(164, 2, 3, 14, 'Centuri'),
(165, 3, 3, 14, 'Centuri'),
(166, 1, 4, 14, 'Le petit port de pêche de centuri, dans le Cap Corse.'),
(167, 2, 4, 14, 'The little fishing harbour of Centuri, in the Cape Corse.'),
(168, 3, 4, 14, 'Le petit port de pêche de centuri, dans le Cap Corse.'),
(169, 1, 1, 15, 'Promenade dans le Cap Corse'),
(170, 2, 1, 15, 'Walking in the Cape Corse'),
(171, 3, 1, 15, 'CO_Promenade dans le Cap Corse'),
(172, 1, 2, 15, 'L''église de Patrimonio'),
(173, 2, 2, 15, 'Patrimonio''s church'),
(174, 3, 2, 15, 'CO_L''église de Patrimonio'),
(175, 1, 3, 15, 'Patrimonio'),
(176, 2, 3, 15, 'Patrimonio'),
(177, 3, 3, 15, 'Patrimonio'),
(178, 1, 4, 15, 'L''église de Patrimonio, village ayant donné son nom à une appellation de vin.'),
(179, 2, 4, 15, 'The church of Patrimonio, the village has given its name to a wine appellation.'),
(180, 3, 4, 15, 'CO_L''église de Patrimonio, village ayant donné son nom à une appellation de vin.'),
(181, 1, 1, 16, 'Promenade en Méditerranée'),
(182, 2, 1, 16, 'Boating in the Méditerranée'),
(183, 3, 1, 16, 'CO_Promenade en Méditerranée'),
(184, 1, 2, 16, 'En mer'),
(185, 2, 2, 16, 'At sea'),
(186, 3, 2, 16, 'CO_En mer'),
(187, 1, 3, 16, 'Vacances'),
(188, 2, 3, 16, 'holidays'),
(189, 3, 3, 16, 'CO_Vacances'),
(190, 1, 4, 16, 'Ballade en mer pour ses quelques bateaux.'),
(191, 2, 4, 16, 'A little trip on the sea for these fews boats.'),
(192, 3, 4, 16, 'CO_Ballade en mer pour ses quelques bateaux.'),
(193, 1, 1, 17, 'Ruelle d''un vieux village Corse'),
(194, 2, 1, 17, 'Street from an old Corsican village'),
(195, 3, 1, 17, 'CO_Ruelle d''un vieux village Corse'),
(196, 1, 2, 17, 'Village de Pigna'),
(197, 2, 2, 17, 'Village of Pigna'),
(198, 3, 2, 17, 'CO_Village de Pigna'),
(199, 1, 3, 17, 'Pigna'),
(200, 2, 3, 17, 'Pigna'),
(201, 3, 3, 17, 'Pigna'),
(202, 1, 4, 17, 'Une ruelle de Pigna, telle qu''elles étaient au siècle dernier...'),
(203, 2, 4, 17, 'A street from Pigna, like streets were during the last century...'),
(204, 3, 4, 17, 'CO_Village of Pigna'),
(210, 1, 1, 18, 'Vue sur Rondinara'),
(211, 2, 1, 18, 'View of Rondinara'),
(212, 3, 1, 18, 'CO_Vue sur Rondinara'),
(213, 1, 2, 18, 'Rondinara'),
(214, 2, 2, 18, 'Rondinara'),
(215, 3, 2, 18, 'Rondinara'),
(216, 1, 3, 18, 'Rondinara'),
(217, 2, 3, 18, 'Rondinara'),
(218, 3, 3, 18, 'Rondinara'),
(219, 1, 4, 18, 'Quelques voiliers à Rondinara.'),
(220, 2, 4, 18, 'A few sailing boats in Rondinara.'),
(221, 3, 4, 18, 'CO_Quelques voiliers à Rondinara.'),
(222, 1, 1, 19, 'Vue sur Bonifacio'),
(223, 2, 1, 19, 'View of Bonifacio'),
(224, 3, 1, 19, 'CO_Vue de Bonifacio'),
(225, 1, 2, 19, 'Bonifacio'),
(226, 2, 2, 19, 'Bonifacio'),
(227, 3, 2, 19, 'Bonifacio'),
(228, 1, 3, 19, 'Bonifacio'),
(229, 2, 3, 19, 'Bonifacio'),
(230, 3, 3, 19, 'Bonifacio'),
(231, 1, 4, 19, 'Bonifacio, magnifique cité surplombant la mer...'),
(232, 2, 4, 19, 'Bonifacio, beautiful city overlooking the sea...'),
(233, 3, 4, 19, 'CO_Bonifacio, magnifique cité surplombant la mer...'),
(234, 1, 1, 20, 'Vue sur Saint-Florent'),
(235, 2, 1, 20, 'View of Saint-Florent'),
(236, 3, 1, 20, 'CO_Vue de Saint-Florent'),
(237, 1, 2, 20, 'Saint-Florent'),
(238, 2, 2, 20, 'Saint-Florent'),
(239, 3, 2, 20, 'Saint-Florent'),
(240, 1, 3, 20, 'Saint-Florent'),
(241, 2, 3, 20, 'Saint-Florent'),
(242, 3, 3, 20, 'Saint-Florent'),
(243, 1, 4, 20, 'Le très joli port de plaisance de Saint-Florent et la citadelle'),
(244, 2, 4, 20, 'The lovely harbour of Saint-Florent, and the old town.'),
(245, 3, 4, 20, 'CO_Le très joli port de plaisance de Saint-Florent et la citadelle'),
(246, 1, 1, 21, 'La tête trouée : le Capu Tafunatu'),
(247, 2, 1, 21, 'The hole in the head : the Capu Tafunatu'),
(248, 3, 1, 21, 'CO_La tête trouée : le Capu Tafunatu'),
(249, 1, 2, 21, 'Capu Tafunatu'),
(250, 2, 2, 21, 'Capu Tafunatu'),
(251, 3, 2, 21, 'Capu Tafunatu'),
(252, 1, 3, 21, 'Niolu'),
(253, 2, 3, 21, 'Niolu'),
(254, 3, 3, 21, 'Niolu'),
(255, 1, 4, 21, 'Le Capu Tafunatu est une montagne de Corse culminant à 2 335 mètres d''altitude et située dans la pieve du Niolu, au nord-ouest de l''île.'),
(256, 2, 4, 21, 'Capu Tafunatu Corsica is a mountain peak at 2335 meters altitude and located in Pieve Niolu , northwest of the island'),
(257, 3, 4, 21, 'CO_Le Capu Tafunatu est une montagne de Corse culminant à 2 335 mètres d''altitude et située dans la pieve du Niolu, au nord-ouest de l''île.');

-- --------------------------------------------------------

--
-- Structure de la table `trd_general`
--

CREATE TABLE IF NOT EXISTS `trd_general` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `id_langue` int(11) NOT NULL,
  `id_definition` int(11) NOT NULL,
  `id_page` int(11) NOT NULL,
  `traduction` varchar(6000) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_TRDGEN_LANG_idx` (`id_langue`),
  KEY `FK_TRDGEN_PAGE_idx` (`id_page`),
  KEY `FK_TRDGEN_DEF_idx` (`id_definition`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COMMENT='table de traduction générale' AUTO_INCREMENT=325 ;

--
-- Contenu de la table `trd_general`
--

INSERT INTO `trd_general` (`id`, `id_langue`, `id_definition`, `id_page`, `traduction`) VALUES
(1, 1, 1, 1, 'Bienvenue au restaurant Pasquale Paoli'),
(2, 2, 1, 1, 'Welcome to the Pasquale Paoli''s restaurant'),
(3, 3, 1, 1, 'CO_Bienvenue au restaurant Pasquale Paoli'),
(4, 1, 1, 2, 'La galerie des émotions du Pasquale Paoli'),
(5, 2, 1, 2, 'The gallery from the Pasquale Paoli'),
(6, 3, 1, 2, 'CO_La galerie des émotions du Pasquale Paoli'),
(7, 1, 1, 3, 'Le blog du Pasquale Paoli'),
(8, 2, 1, 3, 'The blog from the Pasquale Paoli'),
(9, 3, 1, 3, 'CO_Le blog du Pasquale Paoli'),
(10, 1, 1, 4, 'Infos pratiques - Pasquale Paoli'),
(11, 2, 1, 4, 'Practical infos - Pasquale Paoli'),
(12, 3, 1, 4, 'CO_Infos pratiques - Pasquale Paoli'),
(13, 1, 1, 5, 'Contactez le Pasquale Paoli'),
(14, 2, 1, 5, 'Contact us - Pasquale Paoli'),
(15, 3, 1, 5, 'CO_Contactez le Pasquale Paoli'),
(16, 1, 1, 6, 'Mentions légales - Pasquale Paoli'),
(17, 2, 1, 6, 'Legal stuff - Pasquale Paoli'),
(18, 3, 1, 6, 'CO_Mentions légales - Pasquale Paoli'),
(19, 1, 1, 7, 'Plan du site - Pasquale Paoli'),
(20, 2, 1, 7, 'Sitemap - Pasquale Paoli'),
(21, 3, 1, 7, 'CO_Plan du site - Pasquale Paoli'),
(22, 1, 2, 1, 'Bienvenue sur le site du restaurant gastronomique, U Pasquale Paoli à l''Ile Rousse en Corse'),
(23, 2, 2, 1, 'Welcome to the website of the gastronomical restaurant, U Pasquale Paoli in l''Ile Rousse, Corsica'),
(24, 3, 2, 1, 'CO_Bienvenue sur le site du restaurant gastronomique, U Pasquale Paoli à l''Ile Rousse en Corse'),
(25, 1, 2, 2, 'Découvrez les photos, articles et autres médias du Pasquale Paoli'),
(26, 2, 2, 2, 'Discover the media gallery from the Pasquale Paoli'),
(27, 3, 2, 2, 'CO_Découvrez les photos, articles et autres médias du Pasquale Paoli'),
(28, 1, 2, 3, 'Le blog du Pasquale Paoli. Retrouvez des recettes, des visites et faites la connaissance des producteurs de l''ile'),
(29, 2, 2, 3, 'The blog from the Pasquale Paoli. Find some recipes, discover some sites and some producers from our island'),
(30, 3, 2, 3, 'CO_Le blog du Pasquale Paoli. Retrouvez des recettes, des visites et faites la connaissance des producteurs de l''ile'),
(31, 1, 2, 4, 'Toutes les infos pratiques sur le restaurant Pasquale Paoli : Horaires, accès, carte'),
(32, 2, 2, 4, 'Practical informations about the Pasquale Paoli: Opening hours, accès, map'),
(33, 3, 2, 4, 'CO_Toutes les infos pratiques sur le restaurant Pasquale Paoli : Horaires, accès, carte'),
(34, 1, 2, 5, 'Contactez le restaurant Pasquale Paoli'),
(35, 2, 2, 5, 'Contact the restaurant Pasquale Paoli'),
(36, 3, 2, 5, 'CO_Contactez le restaurant Pasquale Paoli'),
(37, 1, 2, 6, 'Mentions légales du site Pasquale Paoli'),
(38, 2, 2, 6, 'Website legal stuff for the Pasquale Paoli'),
(39, 3, 2, 6, 'CO_Mentions légales du site Pasquale Paoli'),
(40, 1, 2, 7, 'Plan du site internet du Pasquale Paoli'),
(41, 2, 2, 7, 'sitemap for the Pasquale Paoli'),
(42, 2, 2, 7, 'CO_Plan du site internet du Pasquale Paoli'),
(43, 1, 3, 1, 'pasquale, paoli, restaurant, corse, gastronomie, cananzi, terroir, ile, rousse'),
(44, 2, 3, 1, 'pasquale, paoli, restaurant, corsica, gastronomy, cananzi, terroir, ile, rousse'),
(45, 3, 3, 1, 'CO_pasquale, paoli, restaurant, corse, gastronomie, cananzi, terroir, ile, rousse'),
(46, 1, 3, 2, 'pasquale, paoli, restaurant, corse, gastronomie, cananzi, photo, ile, rousse, articles, vidéos'),
(47, 2, 3, 2, 'pasquale, paoli, restaurant, corsica, gastronomy, cananzi, photo, ile, rousse, news, movies'),
(48, 3, 3, 2, 'CO_pasquale, paoli, restaurant, corse, gastronomie, cananzi, photo, ile, rousse, articles, vidéos'),
(49, 1, 3, 3, 'pasquale, paoli, restaurant, corse, gastronomie, cananzi, blog, recettes, producteurs'),
(50, 2, 3, 3, 'pasquale, paoli, restaurant, corsica, gastronomy, cananzi, blog, recipes, producers'),
(51, 3, 3, 3, 'CO_pasquale, paoli, restaurant, corse, gastronomie, cananzi, blog, recettes, producteurs'),
(52, 1, 3, 4, 'pasquale, paoli, restaurant, corse, gastronomie, cananzi, infos, horaires, accès, carte'),
(53, 2, 3, 4, 'pasquale, paoli, restaurant, corsica, gastronomy, cananzi, infos, opening, hours, access, map'),
(54, 3, 3, 4, 'CO_pasquale, paoli, restaurant, corse, gastronomie, cananzi, infos, horaires, accès, carte'),
(55, 1, 3, 5, 'pasquale, paoli, restaurant, corse, gastronomie, cananzi, contact, téléphone, email, adresse'),
(56, 2, 3, 5, 'pasquale, paoli, restaurant, corsica, gastronomy, cananzi, contact, phone, email, address'),
(57, 3, 3, 5, 'CO_pasquale, paoli, restaurant, corse, gastronomie, cananzi, contact, téléphone, email, adresse'),
(58, 1, 3, 6, 'pasquale, paoli, restaurant, corse, gastronomie, cananzi, mentions, légales'),
(59, 2, 3, 6, 'pasquale, paoli, restaurant, corsica, gastronomy, cananzi, legal, stuff'),
(60, 3, 3, 6, 'CO_pasquale, paoli, restaurant, corse, gastronomie, cananzi, mentions, légales'),
(61, 1, 3, 7, 'pasquale, paoli, restaurant, corse, gastronomie, cananzi, plan'),
(62, 2, 3, 7, 'pasquale, paoli, restaurant, corse, gastronomie, cananzi, sitemap'),
(63, 3, 3, 7, 'CO_pasquale, paoli, restaurant, corse, gastronomie, cananzi, plan'),
(64, 1, 4, 8, 'logo du restaurant'),
(65, 1, 5, 8, 'affichage de la navigation'),
(66, 2, 4, 8, 'restaurant''s logo'),
(67, 2, 5, 8, 'Toggle navigation'),
(68, 3, 4, 8, 'CO_logo du restaurant'),
(69, 3, 5, 8, 'CO_Affichage de la navigation'),
(70, 1, 6, 9, 'drapeau français'),
(71, 2, 6, 9, 'french flag'),
(72, 3, 6, 9, 'bannera francese'),
(73, 1, 7, 9, 'drapeau anglais'),
(74, 2, 7, 9, 'english flag'),
(75, 3, 7, 9, 'bannera inglese'),
(76, 1, 8, 9, 'drapeau corse'),
(77, 2, 8, 9, 'corsican flag'),
(78, 3, 8, 9, 'bannera Corsica'),
(79, 1, 9, 1, 'nos menus'),
(80, 2, 9, 1, 'our menus'),
(81, 3, 9, 1, 'a nostra a carta'),
(82, 1, 10, 1, 'actualités'),
(83, 2, 10, 1, 'news'),
(84, 3, 10, 1, 'nutizzi'),
(85, 1, 11, 1, 'sur le blog'),
(86, 2, 11, 1, 'on the blog'),
(87, 3, 11, 1, 'u bloggu'),
(88, 1, 12, 9, 'Publié le'),
(89, 2, 12, 9, 'Published on'),
(90, 3, 12, 9, 'Publicatu'),
(91, 1, 13, 9, 'Lire l''article'),
(92, 2, 13, 9, 'Read the article'),
(93, 3, 13, 9, 'Liggiti ''articulu'),
(94, 1, 14, 1, 'Bienvenue au restaurant'),
(95, 2, 14, 1, 'Welcome to the restaurant'),
(96, 3, 14, 1, 'Benvinuti à u risturante'),
(97, 1, 15, 1, 'TERROIR ET GASTRONOMIE CORSE'),
(98, 2, 15, 1, 'CORSICAN GASTRONOMY'),
(99, 3, 15, 1, 'CO_TERROIR ET GASTRONOMIE CORSE'),
(100, 1, 16, 1, 'Ange Cananzi et son équipe vous souhaitent la bienvenue sur l''île. Nous espérons que vous passerez en notre compagnie, un agréable moment à la découverte de notre terroir.'),
(101, 2, 16, 1, 'Ange Cananzi and his team welcome you on the island. We hope you will spend with us a pleasant moment discovering our local products.'),
(102, 3, 16, 1, 'Ange Cananzi è a so squadra voi vidiri a nostra isula. Spirammu ca passi cun noi un picculu mumentu à scopre a nostra regione.'),
(103, 1, 17, 9, 'image de l''Ile Rousse'),
(104, 2, 17, 9, 'view from Ile Rousse'),
(105, 3, 17, 9, 'image di Isula Rossa'),
(106, 1, 18, 9, 'sélection de charcuterie'),
(107, 2, 18, 9, 'selection of cold cured meat'),
(108, 3, 18, 9, 'silizzioni di li tagghia lu friddu'),
(109, 1, 19, 9, 'soupières'),
(110, 2, 19, 9, 'tureens'),
(111, 3, 19, 9, 'CO_soupières'),
(112, 1, 20, 9, 'supions au poireau sauvage'),
(113, 2, 20, 9, 'cuttlefish with wild leek'),
(114, 3, 20, 9, 'CO_supions au poireau sauvage'),
(115, 1, 21, 9, 'la terrasse du restaurant'),
(116, 2, 21, 9, 'the restaurant terrace'),
(117, 3, 21, 9, 'a terrazza di ristorante'),
(118, 1, 22, 1, 'Notre Etablissement'),
(119, 2, 22, 1, 'Our Establishment'),
(120, 3, 22, 1, 'CO_Notre Etablissement'),
(121, 1, 23, 1, 'Natif de Balagne, c''est ici qu''Ange Cananzi a découvert sa passion pour la cuisine. Après des études au Lycée Hôtelier de l''Ile Rousse, il décide de rester sur son île, et de travailler dans différents établissements de la région. C''est en 2007 qu''il ouvre son restaurant U Pasquale Paoli dans la cité fondée par "U Babbu di a patria". Très rapidement, son établissement se classe parmi les tables incontournables de la Corse.'),
(122, 2, 23, 1, 'Born in Balagne, this is where Ange Cananzi discovered his passion for cooking. After studying at the Catering School of Ile Rousse, he decided to stay on his island and work in different establishments in the region. In 2007 he opened his restaurant U Pasquale Paoli in the city founded by "U Babbu di a patria." Very quickly, his restaurant became one of the best tables of Corsica.'),
(123, 3, 23, 1, 'CO_Natif de Balagne, c''est ici qu''Ange Cananzi a découvert sa passion pour la cuisine. Après des études au Lycée Hôtelier de l''Ile Rousse, il décide de rester sur son île, et de travailler dans différents établissements de la région. C''est en 2007 qu''il ouvre son restaurant U Pasquale Paoli dans la cité fondée par "U Babbu di a patria". Très rapidement, son établissement se classe parmi les tables incontournables de la Corse.'),
(124, 1, 24, 1, 'Ici, la Corse est à l''honneur, dans la décoration, mais aussi et surtout dans l''assiette. Utilisant les meilleurs produits de l''île, Ange Cananzi revisite la tradition Corse, tout en finesse, au gré des saisons. Sa cuisine épurée sait mettre en valeur le produit, pour votre plus grand plaisir...'),
(125, 2, 24, 1, 'Here, Corsica is in the spotlight, in the decoration, but above all, in the plate. Using the best products of the island, Ange Cananzi revisits Corsican tradition, with finesse, according to the seasons. Its uncluttered cuisine emphasizes the product, for your enjoyment ...'),
(126, 3, 24, 1, 'CO_Ici, la Corse est à l''honneur, dans la décoration, mais aussi et surtout dans l''assiette. Utilisant les meilleurs produits de l''île, Ange Cananzi revisite la tradition Corse, tout en finesse, au gré des saisons. Sa cuisine épurée sait mettre en valeur le produit, pour votre plus grand plaisir...'),
(127, 1, 25, 1, 'vue de la salle de restaurant'),
(128, 2, 25, 1, 'view of the restaurant'),
(129, 3, 25, 1, 'vista di u risturante'),
(130, 1, 26, 8, 'Notre établissement'),
(131, 2, 26, 8, 'Our establishment'),
(132, 3, 26, 8, 'CO_Notre établissement'),
(133, 1, 27, 8, 'Nous vous accueillons pour le déjeuner et le diner.<br>Si vous souhaitez faire un repas pour un groupe, ou pour une occasion particulière, n''hésitez pas à nous contacter.'),
(134, 2, 27, 8, 'We welcome you for lunch and dinner.<br>If you wish to organise a meal for a group, or for a special occasion, please contact us.'),
(135, 3, 27, 8, 'Si tu chjami per a merenda è cena. <br> Si vuliti fari ''na manciata di gruppu, o di un ''occasioni spiciali, andate Cuntattu.'),
(136, 1, 28, 8, 'Mentions légales'),
(137, 2, 28, 8, 'Legal notice'),
(138, 3, 28, 8, 'Co_Mentions légales'),
(139, 1, 29, 8, 'Plan du site'),
(140, 2, 29, 8, 'Sitemap'),
(141, 3, 29, 8, 'Mappa di u situ'),
(142, 1, 30, 8, 'L’abus d’alcool est dangereux pour la santé, à consommer avec modération.'),
(143, 2, 30, 8, 'Alcohol abuse is dangerous for health, consume in moderation.'),
(144, 3, 30, 8, 'Abusu alcolu hè periculosu per a salute, cunsuma in modération.'),
(145, 1, 31, 8, 'Horaires'),
(146, 2, 31, 8, 'Opening time'),
(147, 3, 31, 8, 'CO_Horaires'),
(148, 1, 32, 8, 'fermé'),
(149, 2, 32, 8, 'closed'),
(150, 3, 32, 8, 'CO_fermé'),
(151, 1, 33, 9, 'Fermeture annuelle jusqu''au début '),
(152, 2, 33, 9, 'Closed until early '),
(153, 3, 33, 9, 'Chjusu finu à principiu di'),
(154, 1, 34, 9, 'Fermeture annuelle jusqu''à la mi '),
(155, 2, 34, 9, 'Closed until mid '),
(156, 3, 34, 9, 'Chjusu, finu a mità di '),
(157, 1, 35, 9, 'Fermeture annuelle jusqu''à la fin '),
(158, 2, 35, 9, 'Closed until the end of '),
(159, 3, 35, 9, 'Chjusu finu à a fine '),
(160, 1, 36, 9, 'Fermeture exceptionnelle cette semaine :'),
(161, 2, 36, 9, 'Exceptionally closed this week:'),
(162, 3, 36, 9, 'Eccezziunale s''ava fattu sta settimana :'),
(163, 1, 37, 9, 'en plus de nos jours de fermeture hebdomadaire.'),
(164, 2, 37, 9, 'in addition to our weekly days of closure.'),
(165, 3, 37, 9, 'Ortri a li nostri jorna Ghjenuva di e nostra campagne.'),
(166, 1, 38, 8, '04 95 47 67 70'),
(167, 2, 38, 8, '+33 (0)4 95 47 67 70'),
(168, 3, 38, 8, '04 95 47 67 70'),
(169, 1, 39, 8, 'Contactez nous'),
(170, 1, 40, 8, 'Téléphone'),
(171, 1, 41, 8, 'E-mail'),
(172, 1, 42, 8, 'Adresse'),
(173, 2, 39, 8, 'Contact us'),
(174, 2, 40, 8, 'Phone'),
(175, 2, 41, 8, 'Email'),
(176, 2, 42, 8, 'Address'),
(177, 3, 39, 8, 'CO_Contactez nous'),
(178, 3, 40, 8, 'Telefono'),
(179, 3, 41, 8, 'CO_E-mail'),
(180, 3, 42, 8, 'Adrizzu'),
(181, 1, 43, 4, 'INFOS PRATIQUES'),
(182, 2, 43, 4, 'PRACTICAL INFOS'),
(183, 3, 43, 4, 'CO_INFOS PRATIQUES'),
(184, 1, 44, 4, 'Nous sommes également à votre disposition pour toute fonction, repas de groupe ou autre événement, que vous souhaiteriez voir se réaliser dans notre établissement.'),
(185, 2, 44, 4, 'We are also available for any function, group meals or any other event, you may wish to organise in our establishment.'),
(186, 3, 44, 4, 'Ci sunnu dispunìbbili di ogni funzione, Serviziu gruppu o altri ballò, ancu, si avissi vulutu vidiri nenti in spenserati.'),
(187, 1, 45, 4, 'N''hésitez donc pas à nous contacter.'),
(188, 2, 45, 4, 'Don''t hesitate to contact us.'),
(189, 3, 45, 4, 'Ùn abbia accessu Cuntattu.'),
(190, 1, 47, 4, 'Avion'),
(191, 2, 47, 4, 'Plane'),
(192, 3, 47, 4, 'CO_Avion'),
(193, 1, 48, 4, 'L''Ile rousse se situe à 25 minutes de l''aéroport Sainte Catherine de Calvi qui est déservie par plusieurs villes Françaises, dont Paris, Marseille ou Lyon.'),
(194, 2, 48, 4, 'L''Ile Rousse is 25 minutes away from the Sainte Catherine''s airport near Calvi, with destination such as Paris, Marseille or Lyon.'),
(195, 3, 48, 4, 'L''Isula Rossa è 25 minuti di u campu d ''aviazione Sainte Catherine Calvi hè déservie da parechje cità francese, cumpresi Parigi, Marseglia è Liò.'),
(196, 1, 49, 4, 'Parmi les compagnies qui viennent à Calvi : <a href="http://www.aircorsica.com/" title="Air Corisca">Air Corsica</a>, <a href="http://www.airfrance.fr/" title="Air France">Air France</a>.'),
(197, 2, 49, 4, 'Among the companies that fly into Calvi :<a href="http://www.aircorsica.com/" title="Air Corisca">Air Corsica</a>, <a href="http://www.airfrance.fr/" title="Air France">Air France</a>.'),
(198, 3, 49, 4, 'CO_Parmi les compagnies qui viennent à Calvi : <a href="http://www.aircorsica.com/" title="Air Corisca">Air Corsica</a>, <a href="http://www.airfrance.fr/" title="Air France">Air France</a>.'),
(199, 1, 50, 4, 'Bateau'),
(200, 2, 50, 4, 'Boat'),
(201, 3, 50, 4, 'CO8Bateau'),
(202, 1, 51, 4, 'Le port de l''Ile Rousse acceuille des ferries en provenance de Marseille, Nice ou Toulon.'),
(203, 2, 51, 4, 'The port of Ile Rousse welcomes ferries from Marseille, Nice and Toulon.'),
(204, 3, 51, 4, 'U portu d ''Isula Rossa accoglie i battelli da Marseglia, Nizza è Tulò.'),
(205, 1, 52, 4, 'Parmi les compagnies qui viennent dans notre port : <a href="http://www.corsicalinea.com/" title="Corsica Linea Ferries">Corsica Linea Ferries</a>, <a href="https://www.corsica-ferries.fr/" title="Corsica ferries">Corsica ferries</a>.'),
(206, 2, 52, 4, 'Among the companies that come to our port : <a href="http://www.corsicalinea.com/" title="Corsica Linea Ferries">Corsica Linea Ferries</a>, <a href="https://www.corsica-ferries.fr/" title="Corsica ferries">Corsica ferries</a>.'),
(207, 3, 52, 4, 'Ntra li so impresi chì vene à u nostru portu : <a href="http://www.corsicalinea.com/" title="Corsica Linea Ferries">Corsica Linea Ferries</a>, <a href="https://www.corsica-ferries.fr/" title="Corsica ferries">Corsica ferries</a>.'),
(208, 1, 53, 4, 'Notez tout de même que les rotations hors des périodes estivales, sont moins nombreuses, et que vous serez peut être de choisir un autre port tel que Bastia.'),
(209, 2, 53, 4, 'Please note that outside the summer months, boat rotations are fewer, and that you may have to choose from another port such as Bastia.'),
(210, 3, 53, 4, 'Ramintate vi però ca lu rutazioni fora di u mese istatina, sò pocu, è chì vo pudia esse à sceglie un altru portu comu Bastia.'),
(211, 1, 54, 4, 'Train'),
(212, 2, 54, 4, 'Train'),
(213, 3, 54, 4, 'Treno'),
(214, 1, 55, 4, 'La gare de l''Ile Rousse est sur la ligne ferrovière Ponte-Leccia Calvi. On peut également aller jusqu''à Bastia ou Ajaccio avec le train.'),
(215, 2, 55, 4, 'The Ile Rousse station is on the railway line Ponte-Leccia Calvi. One can also go to Bastia or Ajaccio by train.'),
(216, 3, 55, 4, 'A stazione Isula Rossa hè nantu à a ligna trenu di Ponte-Leccia Calvi. Si ponu dinù andà à Bastia o Aiacciu cù u trenu.'),
(217, 1, 56, 4, 'Pour plus de renseignement, rendez-vous sur le site du <a href="http://www.cf-corse.fr/" title="Chemin de fer de la Corse">Chemin de Fer de la Corse</a>. Vous y trouverez tous les horaires et tarifs en vigueur.'),
(218, 2, 56, 4, 'For more information, visit the <a href="http://www.cf-corse.fr/" title="Chemin de fer de la Corse">Chemin de Fer de la Corse</a> website. You will find all the current schedules and fares.'),
(219, 3, 56, 4, 'Pè sapenne di più, visita di u situ <a href="http://www.cf-corse.fr/" title="Chemin de fer de la Corse">Camini di Ferru di a Corsica</a>. Truvareti tutti i quando è i tariffi in forza.'),
(220, 1, 57, 4, 'Auto'),
(221, 2, 57, 4, 'Car'),
(222, 3, 57, 4, 'Vittura'),
(223, 1, 58, 4, 'La Nationale 197 traverse l''Ile Rousse. Elle va de Calvi à Ponte-Leccia.'),
(224, 2, 58, 4, 'National 197 goes through l''Ile Rousse. It runs from Calvi to Ponte-Leccia.'),
(225, 3, 58, 4, 'Naziunale 197 à traversu Isula Rossa. Farà Calvi à Ponte-Leccia.'),
(226, 1, 59, 4, 'En provenance de Bastia, vous pourrez choisir de passer par Ponte-Leccia, ou bien de prendre la magnifique route qui passe par Patrimonio et Saint-Florent.'),
(227, 2, 59, 4, 'From Bastia, you can choose to go through Ponte-Leccia, or take the beautiful route through Patrimonio and Saint Florent.'),
(228, 3, 59, 4, 'Da Bastia, pudete sceglie à andà à traversu Ponte-Leccia, o piglià u bella strada à traversu Patrimoniu è San Fiurenzu.'),
(229, 1, 60, 4, 'VENIR A L''ILE ROUSSE'),
(230, 2, 60, 4, 'HOW TO COME TO L''ILE ROUSSE'),
(231, 3, 60, 4, 'SURGHJENTI A TO ISULA ROSSA'),
(232, 1, 61, 2, 'ÉMOTIONS'),
(233, 2, 61, 2, 'GALLERY'),
(234, 3, 61, 2, 'CO_LA GALERIE DE MÉDIAS'),
(235, 1, 63, 3, 'DERNIERS ARTICLES'),
(236, 2, 63, 3, 'LATEST POSTS'),
(237, 3, 63, 3, 'CO_DERNIERS MESSAGES'),
(238, 1, 62, 3, 'Catégories'),
(239, 2, 62, 3, 'Tags'),
(240, 3, 62, 3, 'CO_Catégories'),
(241, 1, 64, 3, 'Derniers commentaires'),
(242, 2, 64, 3, 'Latest messages'),
(243, 3, 64, 3, 'CO_Derniers commentaires'),
(244, 1, 65, 3, 'Archives'),
(245, 2, 65, 3, 'Archives'),
(246, 3, 65, 3, 'CO_Archives'),
(247, 1, 66, 3, 'Lire la suite de l''article...'),
(248, 2, 66, 3, 'Continue reading the article...'),
(249, 3, 66, 3, 'Veda u artìculu'),
(250, 1, 67, 3, 'Derniers articles du blog'),
(251, 2, 67, 3, 'Latest blog posts'),
(252, 3, 67, 3, 'CO_Derniers articles du blog'),
(253, 1, 68, 5, 'Contacts'),
(254, 2, 68, 5, 'Contacts'),
(255, 3, 68, 5, 'CO_Contacts'),
(256, 1, 69, 5, 'Réseaux sociaux'),
(257, 2, 69, 5, 'Social networks'),
(258, 3, 69, 5, 'CO_Réseaux sociaux'),
(259, 1, 70, 5, 'FORMULAIRE DE CONTACT'),
(260, 2, 70, 5, 'CONTACT FORM'),
(261, 3, 70, 5, 'CO_FORMUNLAIRE DE CONTACT'),
(262, 1, 71, 5, 'Pour toute demande d''information, nous vous invitons à remplir le formulaire suivant en complétant tous les champs.'),
(263, 2, 71, 5, 'For any further information, please complete the form by filling out all fields.'),
(264, 3, 71, 5, 'Qualessu sia u più infurmazioni, per piacè di cumpritari la forma di inchiri fora tutti i campi.'),
(265, 1, 72, 5, 'Nous vous contacterons le plus rapidemment possible.'),
(266, 2, 72, 5, 'We will contact you as soon as possible.'),
(267, 3, 72, 5, 'Ci sarà à addunisce vi u più prestu pussibule.'),
(268, 1, 73, 5, 'Merci.'),
(269, 2, 73, 5, 'Thank you.'),
(270, 3, 73, 5, 'Grazie.'),
(271, 1, 74, 5, 'Nom'),
(272, 2, 74, 5, 'Name'),
(273, 3, 74, 5, 'CO_Nom'),
(274, 1, 75, 5, 'Sujet'),
(275, 2, 75, 5, 'Subject'),
(276, 3, 75, 5, 'Sughjettu'),
(277, 1, 76, 5, 'Message'),
(278, 2, 76, 5, 'Message'),
(279, 3, 76, 5, 'CO_Message'),
(280, 1, 77, 5, 'Envoyer'),
(281, 2, 77, 5, 'Submit'),
(282, 3, 77, 5, 'CO_Submit'),
(283, 1, 78, 5, 'Veuillez entrer votre nom.'),
(284, 2, 78, 5, 'Please enter your name.'),
(285, 3, 78, 5, 'CO_Veuillez entrer votre nom.'),
(286, 1, 79, 5, 'Veuillez entrer votre email.'),
(287, 2, 79, 5, 'Please enter your email.'),
(288, 3, 79, 5, 'CO_Veuillez entrer votre.'),
(289, 1, 80, 5, 'Veuillez entrer votre numéro de téléphone.'),
(290, 2, 80, 5, 'Please enter your phone number.'),
(291, 3, 80, 5, 'CO_Veuillez entrer votre numéro de téléphone.'),
(292, 1, 81, 5, 'Veuillez entrer le sujet de votre message.'),
(293, 2, 81, 5, 'Please enter the subject of your message.'),
(294, 3, 81, 5, 'CO_Veuillez entrer le sujet de votre message.'),
(295, 1, 82, 5, 'Veuillez entrer votre message.'),
(296, 2, 82, 5, 'Please enter your message.'),
(297, 3, 82, 5, 'CO_Veuillez entrer votre message.'),
(298, 1, 83, 5, 'Email invalide.'),
(299, 2, 83, 5, 'Invalid email.'),
(300, 3, 83, 5, 'CO_Email invalide.'),
(301, 1, 84, 5, 'Numéro de téléphone invalide.'),
(302, 2, 84, 5, 'Invalid phone number.'),
(303, 3, 84, 5, 'CO_Numéro de téléphone invalide.'),
(304, 1, 85, 5, 'Votre message a bien été envoyé et nous vous en remercions.'),
(305, 1, 86, 5, 'Nous vous contacterons dès que possible.'),
(306, 2, 85, 5, 'Your message has been sent and we thank you for it.'),
(307, 2, 86, 5, 'We will contact you as soon as possible.'),
(308, 3, 85, 5, 'Votre message a bien été envoyé et nous vous en remercions.'),
(309, 3, 86, 5, 'Nous vous contacterons dès que possible.'),
(310, 1, 87, 7, 'PLAN DU SITE'),
(311, 2, 87, 7, 'SITEMAP'),
(312, 3, 87, 7, 'CO_PLAN DU SITE'),
(313, 1, 88, 7, 'Vous trouverez ci-dessous, l''ensemble des pages qui composent notre site internet.'),
(314, 2, 88, 7, 'You will find below, all the pages that make up our website.'),
(315, 3, 88, 7, 'Truverete quì sottu tutte e pagine chì custituiscini u nostru situ.'),
(316, 1, 89, 6, 'NOS MENTIONS LEGALES'),
(317, 2, 89, 6, 'LEGAL INFORMATIONS'),
(318, 3, 89, 6, 'CO_NOS MENTIONS LEGALES'),
(319, 1, 90, 1, 'Tous les midis en terrasse, venez vous régaler avec des produits locaux cuisinés à la plancha par notre chef....\n\n'),
(320, 2, 90, 1, 'Every lunchtime on the terrace, taste some local produces cooked on the plancha by our chef...\n'),
(321, 3, 90, 1, 'CO_Tous les midis, découvrez notre assiette du jour à partir de 12€'),
(322, 1, 91, 1, 'Fermé le mercredi jusqu''à fin mai.<br>Ouvert tous les jours du 1er juin au 30 septembre.'),
(323, 2, 91, 1, 'Closed on wednesday until the end of May.<br>Opened every days from 1st June to 30th spetember.'),
(324, 3, 91, 1, 'CO_Fermé le mercredi jusqu''à fin mai.<br>Ouvert tous les jours du 1er juin au 31 septembre.');

-- --------------------------------------------------------

--
-- Structure de la table `trd_homemenu`
--

CREATE TABLE IF NOT EXISTS `trd_homemenu` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `id_language` int(11) NOT NULL,
  `id_homemenu` int(11) NOT NULL,
  `traduction` varchar(120) NOT NULL,
  `title_traduction` varchar(300) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_TRDHOME_LANG_idx` (`id_language`),
  KEY `FK_TRDHOME_HOME_idx` (`id_homemenu`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COMMENT='table comprenant les traductions pour le menu dans la colonne gauche du fichier index' AUTO_INCREMENT=19 ;

--
-- Contenu de la table `trd_homemenu`
--

INSERT INTO `trd_homemenu` (`id`, `id_language`, `id_homemenu`, `traduction`, `title_traduction`) VALUES
(1, 1, 1, 'Menu Bistrot', 'Menu Bistrot'),
(2, 2, 1, 'Menu Bistrot', 'Menu Bistrot'),
(3, 3, 1, 'CO_Formule du midi', 'CO_notre formule du midi'),
(4, 1, 2, 'Coin Apéro', 'Coin Apéro et autres propositions'),
(5, 2, 2, 'Apero Corner', 'Apero Corner and other offers'),
(6, 3, 2, 'CO_Fast-good', 'CO_notre sélection fast-good'),
(7, 1, 3, 'Carte du soir', 'notre carte du soir'),
(8, 2, 3, 'Evening Menu', 'our evening A La Carte menu'),
(9, 3, 3, 'CO_Carte du soir', 'CO_notre carte du soir'),
(10, 1, 4, 'Carte des vins', 'quelques extraits de notre carte des vins'),
(11, 2, 4, 'Wine list', 'a few wines from our wine list'),
(12, 3, 4, 'CO_Carte des vins', 'CO_quelques extraits de notre carte des vins'),
(13, 1, 5, 'Une semaine... un vigneron...', 'le vigneron de la semaine'),
(14, 2, 5, 'This week winemaker...', 'the weekly winemaker'),
(15, 3, 5, 'CO_Une semaine... un vigneron...', 'CO_le vigneron de la semaine'),
(16, 1, 6, 'Promotion de la semaine', 'la promotion de la semaine'),
(17, 2, 6, 'Weekly offer', 'this week offer'),
(18, 3, 6, 'CO_Promotion de la semaine', 'CO_la promotion de la semaine');

-- --------------------------------------------------------

--
-- Structure de la table `trd_jour`
--

CREATE TABLE IF NOT EXISTS `trd_jour` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `id_language` int(11) NOT NULL,
  `id_jour` int(11) NOT NULL,
  `traduction` varchar(45) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_TRDJOUR_LANG_idx` (`id_language`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COMMENT='traduction des jours de la semaine (1 dimanche - 7 samedi)' AUTO_INCREMENT=22 ;

--
-- Contenu de la table `trd_jour`
--

INSERT INTO `trd_jour` (`id`, `id_language`, `id_jour`, `traduction`) VALUES
(1, 1, 2, 'lundi'),
(2, 2, 2, 'monday'),
(3, 3, 2, 'luni'),
(4, 1, 3, 'mardi'),
(5, 2, 3, 'tuesday'),
(6, 3, 3, 'marti'),
(7, 1, 4, 'mercredi'),
(8, 2, 4, 'wednesday'),
(9, 3, 4, 'marcuri'),
(10, 1, 5, 'jeudi'),
(11, 2, 5, 'thursday'),
(12, 3, 5, 'ghjovi'),
(13, 1, 6, 'vendredi'),
(14, 2, 6, 'friday'),
(15, 3, 6, 'vennari'),
(16, 1, 7, 'samedi'),
(17, 2, 7, 'saturday'),
(18, 3, 7, 'sabbatu'),
(19, 1, 1, 'dimanche'),
(20, 2, 1, 'sunday'),
(21, 3, 1, 'duminica');

-- --------------------------------------------------------

--
-- Structure de la table `trd_menuactus`
--

CREATE TABLE IF NOT EXISTS `trd_menuactus` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `id_language` int(11) NOT NULL,
  `id_menuactus` int(11) NOT NULL,
  `type_traduction` enum('head','body','foot') NOT NULL,
  `traduction` text NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_TRADMENU_LANG_idx` (`id_language`),
  KEY `FK_TRADMENU_MENU_idx` (`id_menuactus`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COMMENT='table donnant les traductions utilisées pour les menus et actus' AUTO_INCREMENT=53 ;

--
-- Contenu de la table `trd_menuactus`
--

INSERT INTO `trd_menuactus` (`id`, `id_language`, `id_menuactus`, `type_traduction`, `traduction`) VALUES
(17, 1, 1, 'head', '<div class="modal-header"><button type="button" class="close" data-dismiss="modal">&times;</button><h2>Formule Bistrot</h2></div>\n'),
(18, 2, 1, 'head', '<div class="modal-header"><button type="button" class="close" data-dismiss="modal">&times;</button><h2>Formule Bistrot</h2></div>'),
(19, 3, 1, 'head', '<div class="modal-header"><button type="button" class="close" data-dismiss="modal">&times;</button><h2>Formule Bistrot</h2></div>'),
(20, 1, 1, 'body', '<div class="modal-body text-center"><h4>Primi piatti</h4><p><strong>Salade de pois chiches, servie froide</strong><br> anchois de Collioure marinés à la menthe fraîche</p><p><strong>Brioche au fromage de brebis fermier de F. Fondacci, panzetta rôtie</strong></p><p><strong>Beignets de courgettes corses à la nepita, coulis de tomates</strong></p><p><strong>Tourte aux herbes et herbettes fraîches</strong></p><p><strong>Salade de moules de Diana, purée de Soissons à l’huile d’olive,</strong><br>poivron rouge au four</p><h4>Secondi piatti</h4><p><strong>U Ventru de porc Corse poêlé au genièvre, Nicciu à la farine de châtaigne</strong><br>de Pioggola, fabrication comme un boudin</p><p><strong>Poisson frais selon saison et arrivage</strong><br>que nous vous proposerons</p><p><strong>Pintade fermière de Marc Mugnier, polenta de maïs aux olives</strong></p><p><strong>Raviole ouvert, au veau Corse de Nessa cuit en cocotte</strong></p><h4>I Dolci</h4><p><strong>Dessert du jour</strong></p><p><strong>Pastizzu au pain perdu infusé à la vanille de Madagascar, caramel d’agrumes</strong></p><p><strong>Panzarotti de Josée Fondacci, sauce au chocolat noir de la maison Valrhona</strong></p><p><strong>Salade d’agrumes corses, jus au miel corse de Jean-Claude Gras</strong></p><p><strong>Assiette de fromages fermiers de chèvre et brebis</strong><br>de toute la corse</p><p><strong>Coupe de glace artisanale de Pierre Géronimi (2 boules)</strong></p><p>&nbsp;</p></div>'),
(21, 2, 1, 'body', '<div class="modal-body text-center"><h4>Primi piatti</h4><p><strong>Chickpeas salad, served cold,</strong><br>anchovies from Collioure marinated in fresh mint</p><p><strong>Homemade brioche with locally farmed ewe cheese from F. Fondacci, roasted panzetta</strong></p><p><strong>Corsican courgette cake with nepita, tomato coulis</strong></p><p><strong>Homemade pie with fresh herbs</strong></p><p><strong>Diana lake mussels in a salad, white beans purée with olive oil</strong><br>oven baked red pepper</p><h4>Secondi piatti</h4><p><strong>U Ventru of Corsican pork with juniper, nicci with chestnut flour</strong><br>from Pioggola, prepared like black pudding</p><p><strong>Fresh fish according to the season and the caught</strong><br>that we will propose</p><p><strong>Farmed guineafowl from Marc Mugnier, corn polenta with olives</strong></p><p><strong>Open raviole, with Corsican veal from Nessa, cooked slowly in a cocotte</strong></p><h4>I Dolci</h4><p><strong>Homemade dessert of the day</strong></p><p><strong>Bread pudding infused with Madagascar vanilla, citrus fruits caramel</strong></p><p><strong>Panzarotti from Josée Fondacci''s recipe, dark chocolate sauce</strong></p><p><strong>Corsican citrus fruit salad, honey sirup from Jean-Claude Gras</strong></p><p><strong>Platter of corsican ewe and goat cheeses from all over the island</p><p><strong>Ice cream from Pierre Géronimi (2 scoops)</strong></p><p>&nbsp;</p></div>'),
(22, 3, 1, 'body', '<div class="modal-body text-center"><h4>Primi piatti</h4><p><strong>CO_Beignets de courgettes vertes, coulis de tomates au basilic</strong></p><p><strong>CO_Rillette de pêche locale au piment d''Espelette,</strong><br>CO_tranche de pain frottée à l''ail rose, fenouil cru</p><h4>Secondi piatti</h4><p><strong>CO_U Ventru de porc Corse poêlé, Nicciu à la farine de châtaigne</strong><br>CO_de Pioggola, fabrication comme un boudin</p><p><strong>CO_Poisson frais selon saison et arrivage</strong><br>CO_que nous vous proposerons</p><h4>I Dolci</h4><p><strong>CO_Pastizzu au pain perdu, agrumes Corses</strong></p><p><strong>CO_Salade de pomelos Corses, sorbet citron-basilic</strong></p><p><strong>CO_Assiette de fromages fermiers de chèvre et brebis</strong><br>CO_de toute la corse</p><p>&nbsp;</p></div>'),
(23, 1, 1, 'foot', '<div class="modal-footer"><h3 class="moncentre">Une entrée et un dessert 24€</h3><h3 class="moncentre">Un plat et un dessert 26€</h3><h3 class="moncentre">Une entrée, un plat et un dessert 28\n€</h3></div>'),
(24, 2, 1, 'foot', '<div class="modal-footer"><h3 class="moncentre">Starter and dessert 24€</h3><h3 class="moncentre">Main course and dessert 26€</h3><h3 class="moncentre">Starter, main course and dessert 28€</h3></div>'),
(25, 3, 1, 'foot', '<div class="modal-footer"><h3 class="moncentre">CO_Une entrée et un plat 29€</h3><h3 class="moncentre">CO_Un plat et un dessert 29€</h3><h3 class="moncentre">CO_Une entrée, un plat et un dessert 39€</h3></div>'),
(26, 1, 2, 'head', '<div class="modal-header"><button type="button" class="close" data-dismiss="modal">&times;</button>\n<h2>Menu carte du dîner</h2><p><strong>Tradition et Imagination</strong></p></div>'),
(27, 2, 2, 'head', '<div class="modal-header"><button type="button" class="close" data-dismiss="modal">&times;</button>\n<h2>Menu carte for the dinner</h2><p><strong>Tradition and Imagination</strong></p></div>'),
(28, 3, 2, 'head', '<div class="modal-header"><button type="button" class="close" data-dismiss="modal">&times;</button><h2>CO_Notre carte du soir</h2><p><strong>CO_Tradition et Imagination</strong></p></div>'),
(29, 1, 2, 'body', '<div class="modal-body text-center"><h4>Primi piatti</h4><p>Asperges verte du domaine de Roques Hautes,<br>tome Corse de Manasselian,\noeuf fermier poché 20 €</p><p>Poulpe d''ici marinée au vinaigre de miel de Lozari,<br>purée de gros haricots blancs 26 €</p><p>Mulatte de fromage frais de François Fondacci, panzetta rôtie 21 €</p><h4>Secondi piatti</h4><p>Jarret de veau fermier de Nessa confit en cocotte lutée pendant 5 heures 33 €</p><p>Au retour de nos pêcheurs, si le temps le permet, quelques-uns<br>de nos plats vous seront présentés de 36 € à 42 €</p><p>Poitrine de pintade fermière du Maquis, jus miellé, risotto d''avoine 30 €</p><h4>&nbsp;</h4><p>Plateau de fromages fermiers de chèvre et de brebis de toute la Corse<br>affinés par nos bergers 14 €</p><h4>I Dolci</h4><p>Mitiède à la farine de châtaigne de Pioggola, sabayon d''agrume 15 €</p><p>Tarte sablée, chocolat noir Kalingo 65 % de la maison Valrhona,<br>fraises de saison 15 €</p><p>Mille feuille crème légère de citron Corse, caramel de chocolat noir 15 €</p></div>'),
(30, 2, 2, 'body', '<div class="modal-body text-center"><h4>Primi piatti</h4><p>Green asparagus from the Roques Hautes estate,<br>Corsian cheese from\nManasselian, farmed poached egg 20 €</p><p>Local octopus marinated in honey vinegar from Lozari, purée of white beans 26 €</p><p>Mulatte of fresh cheese from François Fondacci, roasted panzetta 21 €</p><h4>Secondi piatti</h4><p>Farmed shank of veal from Nessa, cooked in a cocotte for 5 hours 33 €</p><p>At the return from our fishermen, if the weather permits, we will<br>suggest you some fish dishes from 36 € à 42 €</p><p>Breast of farmed guinea fowl from the Maquis, honey juice, oats risotto 30 €</p><h4>&nbsp;</h4><p>A selection of ewe and goat cheeses from all over Corsica,<br>matured by our shepherds 14 €</p><h4>I Dolci</h4><p>A Biscuit with chestnut flour from Poggiole served straight from the oven,<br>citrus fruit sabayon 15 €</p><p>Shortbread tarte, Kalingo dark chocolate 65 % cocoa from Valrhona,<br>seasonal strawberries 15 €</p><p>Mille feuille with a light Corsican lemon cream, dark chocolate caramel 15 €</p></div>'),
(31, 3, 2, 'body', '<div class="modal-body text-center"><h4>Primi piatti</h4><p>CO_Mulatte de fromage frais de brebis de Muru, panzetta rôtie 21 €</p><p>CO_Oeuf fermier poché sauce "in trippa", croustillant de panzetta<br>CO_di Francescu Albertini 18 €</p><p>CO_Brioche au beurre frais parfumée au fenouil sauvage,<br>CO_moules de Diane au Cap Corse « Mattei » 3 ans d''age 25 €</p><p>CO_Poisson de pêche locale fumé au bois de châtaignier Corse 29 €</p><p>CO_Charcuterie Corse fermière d''Antoine Poggiole (prisuttu, lonzu, coppa, salciccia) 35 €</p><p>CO_Quelques premiers plats vous seront proposés selon le marché</p><h4>Secondi piatti</h4><p>CO_Au retour de nos pêcheurs, si le temps le permet, quelques-uns<br>ECO_de nos plats vous seront présentés de 36 € à 42 €</p><p>CO_Quasi de veau fermier de Nessa au vinaigre de miel di Lozari,<br>CO_purée de pomme de terre 30 €</p><p>vPorc Nustrale confit, trippa piena en feuilleté 35 €</p><p>CO_Conchiglioni Ripieni de vieux fromages Corses,<br>CO_coulis de tomates cuisinées 23 €</p><p>CO_Jarret de veau fermier de Nessa cuit en cocotte lutée pendant 5 heures<br>CO_pommes de terre au jus 33 €</p><p>CO_Risotto aux foies de veau fermier poêlés, petits artichauds violets 30 €</p><h4>&nbsp;</h4><p>CO_Plateau de fromages fermiers de chèvre et de brebis de toute la Corse<br>CO_affinés par nos bergers 14 €</p><h4>I Dolci</h4><p>CO_Mille-feuille à la crème légère de citrons Corses</p><p>CO_Velouté de pommes Corses à l''anis étoilé et poivre sauvage de Madagascar,<br>CO_gaufre au miel Corse de Jean-Claude Gras</p><p>CO_Mi tiède à la farine de châtaigne de Pioggiola, sabayon au Whisky Corse</p><p>CO_Soufflé glacé à la crème de nougat de Soveria, meringue traditionnelle au Salinu</p><p>CO_Suggestion de dessert du moment</p><p>Tous nos desserts sont à 15 €</p><p>&nbsp;</p></div>'),
(32, 1, 2, 'foot', '<div class="modal-footer"><h3 class="moncentre">Menu 55 € (une entrée, un plat et un dessert)</h3><p class="moncentre">Carte et menu soumis aux arrivages du marché et de nos producteurs.<br>Quelques produits peuvent momentanément manquer.<br>Merci de votre compréhension.</p></div>'),
(33, 2, 2, 'foot', '<div class="modal-footer"><h3 class="moncentre">Menu 55 € (a starter, a main course and a dessert)</h3><p class="moncentre">Our carte and menu depends from the market. Some produces may be missing.<br>We apologise for this and thank you for your understanding.<br>Prix nets – Service compris</p></div>'),
(34, 3, 2, 'foot', '<div class="modal-footer"><p class="moncentre">CO_Carte et menu soumis aux arrivages du marché et de nos producteurs.<br>CO_Quelques produits peuvent momentanément manquer.<br>CO_Merci de votre compréhension.</p></div>'),
(35, 1, 3, 'head', '<div class="modal-header"><button type="button" class="close" data-dismiss="modal">&times;</button>\n<h2>Une semaine... Un vigneron...</h2><p><strong>du 18 au 24 avril 2016</strong></p></div>'),
(36, 2, 3, 'head', '<div class="modal-header"><button type="button" class="close" data-dismiss="modal">&times;</button>\r\n<h2>A week... A winemaker...</h2><p><strong>from 18 to 24 april 2016</strong></p></div>'),
(37, 3, 3, 'head', '<div class="modal-header"><button type="button" class="close" data-dismiss="modal">&times;</button>\r\n<h2>CO_Une semaine... Un vigneron...</h2><p><strong>CO_du 18 au 24 avril 2016</strong></p></div>'),
(38, 1, 3, 'body', '<div class="modal-body"><img src="../images/semaine/piurgeb.png" class="image-gauche" alt="bouteille de Pumonte rouge du domaine Alzipratu"/><h3>Domaine Alzipratu</h3><p>Situé en Balagne à 8km de Calvi, dans le Nord-Ouest de l’Île, le domaine fût créé dans les années 60 par le Baron Henry Louis de La Grange alors propriétaire du couvent d’Alzipratu. Le domaine a été conduit par Maurice Acquaviva avant d’être repris par son fils Pierre et son épouse Cécilia.</p><p>Le vignoble de 40 hectares est composé de plusieurs parcelles orientées au sud et se divise en deux parties.        La première se trouve au nord du couvent, à proximité de Zilia, la seconde est située à 10 km à l’ouest du village de Calenzana dans la haute-vallée de la Figarella.</p><p>Les cépages sont très majoritairement des variétés traditionnelles Corse.</p><p>Implantées au pied du Monte Grossu (point culminant 1950 mètres) et à quelques minutes du rivage, nos vignes bénéficient d’une influence climatique contrastée mer-montagne.</p></div>'),
(39, 2, 3, 'body', '<div class="modal-body"><img src="../images/semaine/piurgeb.png" class="image-gauche" alt="bottle of Pumonte red from domaine Alzipratu"/><h3>Domaine Alzipratu</h3><p>Located in Balagna 8 km from Calvi, in the northwest of the island, the vineyard was created in the 60s by Baron Henry Louis de La Grange, owner of the  Alzipratu covent. The vineyard was led by Maurice Acquaviva before being taken over by his son Pierre and his wife Cecilia.</p><p>The vineyard of 40 hectares consists of several plots facing south and is divided into two parts. The first is north of the monastery, near Zilia, the second is located 10 km west of the village of Calenzana in Figarella the high-valley. </p><p> The grape varieties are mostly traditional Corsican varities.</p><p>Located at the foot of monte grossu (highest point 1950 meters) and just minutes from shore, the vines benefit from contrasting climatic influence from the sea and the mountain.</p></div>'),
(40, 3, 3, 'body', '<div class="modal-body"><img src="../images/semaine/piurgeb.png" class="image-gauche" alt="CO_bouteille de Pumonte rouge du domaine Alzipratu"/><h3>Domaine Alzipratu</h3><p>CO_Situé en Balagne à 8km de Calvi, dans le Nord-Ouest de l’Île, le domaine fût créé dans les années 60 par le Baron Henry Louis de La Grange alors propriétaire du couvent d’Alzipratu. Le domaine a été conduit par Maurice Acquaviva avant d’être repris par son fils Pierre et son épouse Cécilia.</p><p>CO_Le vignoble de 40 hectares est composé de plusieurs parcelles orientées au sud et se divise en deux parties La première se trouve au nord du couvent, à proximité de Zilia, la seconde est située à 10 km à l’ouest du village de Calenzana dans la haute-vallée de la Figarella.</p><p>CO_Les cépages sont très majoritairement des variétés traditionnelles Corse.</p><p>CO_Implantées au pied du Monte Grossu (point culminant 1950 mètres) et à quelques minutes du rivage, nos vignes bénéficient d’une influence climatique contrastée mer-montagne.</p></div>'),
(41, 1, 3, 'foot', '<div class="modal-footer"><h4>Cette semaine nous vous proposerons</h4><p><strong>Fiumeseccu Rosé</strong> : 5 € le verre</p><p><strong>Pumonte Rouge</strong> : 8 € le verre</p></div>'),
(42, 2, 3, 'foot', '<div class="modal-footer"><h4>This week, try the following</h4><p><strong>Fiumeseccu Rosé</strong> : 5 € a glass</p><p><strong>Pumonte Rouge</strong> : 8 € a glass</p></div>'),
(43, 3, 3, 'foot', '<div class="modal-footer"><h4>CO_Cette semaine nous vous proposerons</h4><p><strong>CO_Fiumeseccu Rosé</strong> : 5 € le verre</p><p><strong>CO_Pumonte Rouge</strong> : 8 € le verre</p></div>'),
(44, 1, 4, 'head', '<div class="modal-header"><button type="button" class="close" data-dismiss="modal">&times;</button><h2>Nous vous proposons aussi...</h2></div>'),
(45, 2, 4, 'head', '<div class="modal-header"><button type="button" class="close" data-dismiss="modal">&times;</button><h2>Our other offers...</h2></div>'),
(46, 3, 4, 'head', '<div class="modal-header"><button type="button" class="close" data-dismiss="modal">&times;</button>\\r\\n<h2>CO_Nous vous proposons aussi...</h2></div>'),
(47, 1, 4, 'body', '<div class="modal-body"><h3>Coin Apéro</h3><p>Chaque jour, nous sélectionnerons un vin corse ou d’ailleurs, que nous vous proposerons au verre ou à la bouteille.</p><h3>A  partager</h3><ul><li>Planche de charcuterie fermière corse</li><li>Planche de fromages fermiers corses</li><li>Tartinade sur un pain au levain</li><li>Plancha version tapas</li><li>Pics de légumes crus et fruits frais (sauce d’accompagnement)</li></ul><h3>Coté artisan glacier Pierre Géronimi</h3><ul><li>Coupe sorbets (3 boules)</li><li>Coupe crèmes glacées (3 boules)</li><li>Coupe à composer vous même</li></ul></div>'),
(48, 2, 4, 'body', '<div class="modal-body"><h3>Apéro corner</h3><p>Every day, we will select a wine from Corsica or from elsewhere, that we will propose to you by the glass or by the bottle.</p><h3>To share</h3><ul><li>Plancha of farmed corsican cured meat selection</li><li>Plancha of farmed corsican cheeses</li><li>Slice of traditional bread with its garnish</li><li>Plancha with tapas</li><li>Mix of raw vegetables and fresh fruits (served with a sauce)</li></ul><h3>Ice cream from Pierre Géronimi</h3><ul><li>Coupe sorbets (3 scoops)</li><li>Coupe ice cream (3 scoops)</li><li>Make your own ice cream</li></ul></div>'),
(49, 3, 4, 'body', '<div class="modal-body"><h3>Apéro corner</h3><p>CO_Every day, we will select a wine from Corsica or from elsewhere, that we will propose to you by the glass or by the bottle.</p><h3>To share</h3><ul><li>Plancha of farmed corsican cured meat selection</li><li>Plancha of farmed corsican cheeses</li><li>Slice of traditional bread with its garnish</li><li>Plancha with tapas</li><li>Mix of raw vegetables and fresh fruits (served with a sauce)</li></ul><h3>Ice cream from Pierre Géronimi</h3><ul><li>Coupe sorbets (3 scoops)</li><li>Coupe ice cream (3 scoops)</li><li>Make your own ice cream</li></ul></div>'),
(50, 1, 4, 'foot', '<div class="modal-footer"><p>Et bien sûr <strong>notre ardoise</strong>...</p></div>'),
(51, 2, 4, 'foot', '<div class="modal-footer"><p>And also  <strong>our blackboard</strong>...</p></div>'),
(52, 3, 4, 'foot', '<div class="modal-footer"><p>CO_Et bien sûr <strong>notre ardoise</strong>...</p></div>');

-- --------------------------------------------------------

--
-- Structure de la table `trd_mois`
--

CREATE TABLE IF NOT EXISTS `trd_mois` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `id_language` int(11) NOT NULL,
  `id_mois` int(11) NOT NULL,
  `traduction` varchar(45) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_TRDMOIS_LANG_idx` (`id_language`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COMMENT='table de traduction des mois (1= janiver 12 = décembre)' AUTO_INCREMENT=37 ;

--
-- Contenu de la table `trd_mois`
--

INSERT INTO `trd_mois` (`id`, `id_language`, `id_mois`, `traduction`) VALUES
(1, 1, 1, 'janvier'),
(2, 2, 1, 'january'),
(3, 3, 1, 'ghjinnaghju'),
(4, 1, 2, 'février'),
(5, 2, 2, 'february'),
(6, 3, 2, 'frivaghju'),
(7, 1, 3, 'mars'),
(8, 2, 3, 'march'),
(9, 3, 3, 'marzu'),
(10, 1, 4, 'avril'),
(11, 2, 4, 'april'),
(12, 3, 4, 'aprili'),
(13, 1, 5, 'mai'),
(14, 2, 5, 'may'),
(15, 3, 5, 'maghju'),
(16, 1, 6, 'juin'),
(17, 2, 6, 'june'),
(18, 3, 6, 'ghjungnu'),
(19, 1, 7, 'juillet'),
(20, 2, 7, 'july'),
(21, 3, 7, 'luddu'),
(22, 1, 8, 'août'),
(23, 2, 8, 'august'),
(24, 3, 8, 'austu'),
(25, 1, 9, 'septembre'),
(26, 2, 9, 'september'),
(27, 3, 9, 'sittembri'),
(28, 1, 10, 'octobre'),
(29, 2, 10, 'october'),
(30, 3, 10, 'uttrovi'),
(31, 1, 11, 'novembre'),
(32, 2, 11, 'november'),
(33, 3, 11, 'nuvembri'),
(34, 1, 12, 'décembre'),
(35, 2, 12, 'december'),
(36, 3, 12, 'dicembri');

-- --------------------------------------------------------

--
-- Structure de la table `trd_navigation`
--

CREATE TABLE IF NOT EXISTS `trd_navigation` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `id_language` int(11) NOT NULL,
  `id_navigation` int(11) NOT NULL,
  `traduction` varchar(45) NOT NULL,
  `traduction_title` varchar(75) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_TRDNAV_LANG_idx` (`id_language`),
  KEY `FK_TRDNAV_NAVI_idx` (`id_navigation`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COMMENT='table contenant les traductions du menu de navigation' AUTO_INCREMENT=16 ;

--
-- Contenu de la table `trd_navigation`
--

INSERT INTO `trd_navigation` (`id`, `id_language`, `id_navigation`, `traduction`, `traduction_title`) VALUES
(1, 1, 1, 'Accueil', 'Accueil'),
(2, 2, 1, 'Home', 'Home'),
(3, 3, 1, 'Abbrazzu', 'Abbrazzu'),
(4, 1, 2, 'Émotions', 'Moments partagés et lieux magiques, en photographie'),
(5, 2, 2, 'Emotions', 'Shared moments, magical places, in photos.'),
(6, 3, 2, 'Emozioni', 'emozioni'),
(7, 1, 3, 'Blog', 'Blog'),
(8, 2, 3, 'Blog', 'Blog'),
(9, 3, 3, 'Bloggu', 'Bloggu'),
(10, 1, 4, 'Infos', 'Infos pratiques'),
(11, 2, 4, 'Infos', 'Practical informations'),
(12, 3, 4, 'CO_Infos', 'CO_Infos pratiques'),
(13, 1, 5, 'Contact', 'Contact'),
(14, 2, 5, 'Contact', 'Contact'),
(15, 3, 5, 'Cuntattu', 'Cuntattu');

-- --------------------------------------------------------

--
-- Structure de la table `trd_post`
--

CREATE TABLE IF NOT EXISTS `trd_post` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `id_language` int(11) NOT NULL,
  `id_postsheader` int(11) NOT NULL,
  `titre` varchar(255) NOT NULL,
  `short_desc` varchar(600) NOT NULL,
  `description` text NOT NULL,
  `title_link` varchar(255) NOT NULL,
  `thumb_alt` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_TRDPOST_LANG_idx` (`id_language`),
  KEY `FK_TRDPOST_POST_idx` (`id_postsheader`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COMMENT='table avec les traductions des post du blog' AUTO_INCREMENT=13 ;

--
-- Contenu de la table `trd_post`
--

INSERT INTO `trd_post` (`id`, `id_language`, `id_postsheader`, `titre`, `short_desc`, `description`, `title_link`, `thumb_alt`) VALUES
(1, 1, 1, 'Visite à Gloria Maris', 'Philippe Riera est un entrepreneur avant tout passionné de la mer, diplômé en Finance et en Marketing de Dauphine, Paris. Il crée Gloria Maris, en 1992, parce qu’il est convaincu', '<img src="images/blog/gloriamaris01.jpg" alt="Vue des enclos marins sur coucher de soleil" class="img-responsive"/><p class="montext"><br>Le secteur de l’aquaculture est un secteur de grand avenir. Bien que chahuté par une concurrence internationale particulièrement agressive, la France a réellement les arguments pour retrouver sa position de leader à condition évidemment de faire valoir les atouts qui sont les siens : une recherche pour le développement des nouvelles espèces, une orientation vers une production haut de gamme, le respect de l’environnement...</p><p class="montext">Gloria Maris Groupe privilégie dans sa stratégie les savoir-faire et les hommes capables d’apporter la plus forte valeur ajoutée aux activités des entreprises du Groupe.</p><img src="images/blog/gloriamaris02.jpg" alt="Vue des enclos marins sur coucher de soleil" class="img-responsive image-droite"/><p class="montext">Le marché, les consommateurs sont en demande de produits de qualité. L’intégration d’entreprises qui performent et proposent du bar, de la daurade, du maigre, du turbot, \r\nélevés en bassin à terre ou en pleine mer, des espèces nobles, permettent au Groupe de conforter son positionnement d’excellence.</p><p class="montext">En France, les entreprises aquacoles ont été jusqu’ici confrontées à un problème de taille critique pour ferrailler avec les grands groupes internationaux. En mutualisant les ressources pertinentes, en maintenant le cap sur la qualité, la recherche et l’innovation, Gloria Maris Groupe est capable d’envisager d’autres belles perspectives: le développement à l’export et un positionnement international.</p>', 'Lire l''article sur la visite de Gloria Maris', 'coucher de soleil sur la mer'),
(2, 2, 1, 'Visiting Gloria Maris', 'Philippe Riera is an entrepreneur above all passionate about the sea, graduated in Finance and Marketing from Dauphine, Paris. It creates Gloria Maris in 1992, because he is convinced', '<img src="images/blog/gloriamaris01.jpg" alt="view sea pens on sunset" class="img-responsive"/><p class="montext"><br>The aquaculture sector is a sector with a great future. Although heckled by a particularly aggressive international competition, France actually has the arguments to regain its leading position provided of course to enforce the assets that are his: a research for development of new species, a shift towards high output quality, respect for the environment ...</p><p class="montext">Gloria Maris Group focuses its strategy know-how and men capable of bringing the highest value to the activities of Group companies.</p><img src="images/blog/gloriamaris02.jpg" alt="Vue des enclos marins sur coucher de soleil" class="img-responsive image-droite"/><p class="montext">The market, consumers demand quality products. The integration of companies that perform and offer the bar, bream, lean, turbot, high basin on land or at sea, noble species, enable the Group to consolidate its position of excellence.</p><p class="montext">In France, aquaculture businesses have so far been confronted with a critical mass problem to scrap with major international groups. By pooling relevant resources, maintaining our focus on quality, research and innovation, Gloria Maris Group is able to consider other good prospects: the export development and international positioning.</p>', 'Read about the visit of Gloria Maris', 'sunset over the sea'),
(3, 3, 1, 'Visita di a Gloria Maris', '\r\nPhilippe Riera hè un entrepreneur, sopra tutti i passiunati di u mare, laureatu in Finance e Gheorghe da Dauphine, Paris. Hè crèa Gloria Maris in u 1992, per via ch''ellu hè cunvinciu', '<img src="images/blog/gloriamaris01.jpg" alt="Pens vue mer in u tramontu" class="img-responsive"/><p class="montext"><br>U settore Acquacoltura hè un settore cù un gran futuru. Puru heckled par un cuncorsu internaziunale, ''n particulari di n''aggrissivu, Francia hà primurosu di l'' argumenti à ritruvà a so pusizioni, mener, furnì di sicuru a custrìnciri l ''bè chì sò i so: una ricerca di u sviluppu di novu e razze,'' na passata di pettu altu pruduzzioni litteraria di qualità, u rispettu di l''embiu ...</p><p class="montext">Gloria Maris Group incalca nantu a so strategia di u sapè-fà è l ''omi capace di purta lu valuri cchiù àutu di l'' attivitati di l ''impresi Group.</p><img src="images/blog/gloriamaris02.jpg" alt="Pens vue mer in u tramontu" class="img-responsive image-droite"/><p class="montext">À u mercatu, i cunsumatori riclamà prudutti di qualità. U integrazione di impresi chì guarisce e prupostu u caffè, Peuple, magre, francese turbot, altu bacinu di u paese o di a mari, spezia di àutri nòbbili, per attivà i Group à puntiddà a so pusizioni di cumpitenzi.</p><p class="montext">In Francia, imprese Acquacoltura sò tantu luntanu statu misi in jocu ccu un prublema di massa critica à Occhi cu àutri gruppi internaziunale. Par pooling risorsi Bandera di, fà valè i nostri messa nantu à a qualità, a ricerca è a nuvità, Gloria Maris Group hè capaci à guardà altre bona des verbes: u sviluppu di una pusizziunamentu è internaziunale.</p>', 'Veda u artìculu supra lu visita di Gloria Maris', '\r\nMiniera nantu à u mare'),
(4, 1, 2, 'Le veau tigré', 'La « Vache Tigre » est issue d’une authentique souche bovine corse, repérable par sa robe bringée , appelée Saïnata en langue Corse.Cette marque déposée en 2006 est le fruit', '<img src="images/blog/abbatucci01.jpg" alt="Vache et veau tigrés dans un champ" class="img-responsive"/><p class="montext"><br>La « Vache Tigre » est issue de l’authentique souche bovine corse, repérable par sa robe bringée, appelée Saïnata en langue corse. </p><p class="montext">L’exploitation agricole de Jacques Abbatucci se situant dans la basse vallée du Taravo (Corse du Sud)  est constituée de 160 vaches se nourrissant à leur rythme des essences végétales du maquis ce qui donne ce goût si particulier et authentique à la viande. </p><p class="montext">Jacques Abbatucci, le digne héritier d''une dynastie nobiliaire qui a engendré un général de la Révolution et un garde des Sceaux, décide, en 2000, de convertir en agriculture biologique les terres familiales de la vallée du Taravo, en Corse-du-Sud. Un paradis de maquis en pente douce bordé d''une mer cristalline qu''il aurait pu vendre à prix d''or à quelques promoteurs affamés.</p>', 'Lire l''article sur le veau tigré', 'vache tigrée'),
(5, 2, 2, 'The Tabby Veal', 'The "Cow Tiger" comes from an authentic Corsican bovine strain, identifiable by its brindled coat, called Saïnata in Corse.Cette language trademark in 2006 is the result', '<img src="images/blog/abbatucci01.jpg" alt="tabby cow and veal in a field" class="img-responsive"/><p class="montext"><br>The "Cow Tiger" comes from the authentic Corsican bovine strain, identifiable by its brindled coat, called Saïnata in Corsican language.</p><p class="montext">The farm of Jacques Abbatucci lying in the lower valley of Taravo (South Corsica) consists of 160 cows feeding at the pace of plant species of the maquis which gives this special taste and authentic meat.</p><p class="montext">Jacques Abbatucci, the worthy heir of an aristocratic dynasty that has led to a general of the Revolution and Minister of Justice, decided in 2000 to convert to organic farming family lands of the Taravo Valley, Corse-du-Sud . A gently sloping bush paradise surrounded by a crystal clear sea that could have sold for high prices to some hungry developers.</p>', 'Read the article on the tabby calf ', 'Tabby cow'),
(6, 3, 2, 'U vitellu macchina', '\r\nU "mucca Tiger" veni da un autenticu stirpi buina, frontman di u so stemma brindled, chiamatu Saïnata in Corse.Cette lingua brivetti in u 2006, hè u risultatu', '<img src="images/blog/abbatucci01.jpg" alt="Mucca e grassu, in un campu siameza" class="img-responsive"/><p class="montext"><br>U "mucca Tiger" vene da u sputicu stirpi buina, frontman di u so stemma brindled, chiamatu Saïnata in lingua corsa.</p><p class="montext">A tinuta di Jacques Abbatucci chjinatu in la valle bassa di Taravu (South Corsica) cunsisti di 160 vacchi culà, à u rìtimu di e razze, pianta di la machja, chi donat issu muscu spiciali è carne autentica. </p><p class="montext">Jacques Abbatucci, u degnu aredi dû Mpiraturi di na dinastia di la famigghia ca ha purtatu lu populu a na ginirali di la rivuluzzioni francisi e ministru di a ghjustizia, dicisi in u 2000 à a cunversione di a AB i terreni famigliali addevu di Valley u Taravu, Corse-du-Sud . A candelle di S.Maria di paradisu machja avvintu da un mare chjaru cristallo, ca avissi da venda di prezzi altu à certi sviluppori di a fame.</p>', 'Veda u artìculu supra lu siameza vitellu', 'tigre vacca'),
(7, 1, 3, 'François Albertini', 'Dans la famille Albertini, on est éleveur porcin de génération en génération (précisément quatre du côté maternel et trois du versant', '<img src="images/blog/albertini01.jpg" alt="La charcuterie de François" class="img-responsive image-gauche"/><p class="montext">Dans la famille Albertini, on est éleveur porcin de génération en génération (précisément quatre du côté maternel et trois du versant paternel). Il n’est dès lors pas surprenant que le jeune François ait entendu retentir en lui, dès l’adolescence, l’appel de la vocation.</p><p class="montext">À peine âgé de quinze ans, il demande à son père de lui confier quelques bêtes pour apprendre les premières bases du métier. Avec le secret espoir que ce fils au caractère déjà bien trempé perpétuera la tradition familiale, il accède à sa requête. Après une formation complémentaire au lycée agricole, en 1985, François se lance seul dans l’aventure cinq ans plus tard. D’année en année, il forme patiemment son troupeau qui compte aujourd’hui 400 têtes. La discipline stricte que François s’impose lui permet de faire face au rythme soutenu de l’exploitation sans ne rien perdre de son enthousiasme.</p><img src="images/blog/albertini02.jpg" alt="François avec ses cochons" class="img-responsive"/><p class="montext">« En élevant des cochons, on est déjà à l’air libre. Si on ajoute à cela la passion, alors on ne s''aperçoit jamais des contraintes».</p><p class="montext">Avec le temps, François a pu mesurer les changements de sa profession. « Le métier a évolué : aujourd’hui, on élève, on engraisse, on charcute et on vend. Cela tombe plutôt bien pour moi : j’aime l’élevage, j’aime aussi transformer la matière première. Et, en plus, ajoute-t-il dans un large sourire, j’apprécie faire découvrir mes produits aux visiteurs ! » Un tiercé gagnant !</p>', 'Lire l''article sur François Albertini', 'un cochon'),
(8, 2, 3, 'François Albertini', 'In the Albertini family, there is generation to generation pig farmer (specifically four and three on the maternal side of the slope', '<img src="images/blog/albertini01.jpg" alt="cured meat from François" class="img-responsive image-gauche"/><p class="montext">In the Albertini family, there is generation to generation pig farmer (specifically four mother''s side and three on the paternal side). It is therefore not surprising that the young Francis had heard resound in him, as a teenager, the call of vocation.</p><p class="montext">\r\nBarely fifteen, he asked his father to give him a few animals to learn the foundations of the trade. With the secret hope that this son to the character already well soaked perpetuate the family tradition, he accedes to his request. After further training in the agricultural high school in 1985, François embarks on the adventure only five years later. Year after year, he patiently as his herd now has 400 head. Strict discipline is needed François enables it to cope with the pace of the operation without losing nothing of his enthusiasm.</p><img src="images/blog/albertini02.jpg" alt="François with its pigs" class="img-responsive"/><p class="montext">"By raising pigs, one is already in the air. If we add to this passion, so we never see constraints. "</p><p class="montext">In time, Francis was able to measure the changes of his profession. "The business has changed: today, one student, it fattens we hacks and sold. This is pretty good for me: I love farming, I also like to transform the raw material. And besides, he adds with a grin, I like to introduce my products to visitors! "A winner !</p>', 'Read the article on François Albertini', 'a pig'),
(9, 3, 3, 'François Albertini', 'In a famiglia Albertini, ùn ci hè generazioni à purcinu generazione (spicificamenti quattru è trè nantu à u cantu maternu di lu virsanti', '<img src="images/blog/albertini01.jpg" alt="François, salsiccia" class="img-responsive image-gauche"/><p class="montext">In a famiglia Albertini, ùn ci hè generazioni à purcinu generazione (lato, spicificamenti quattru di mamma è trè da u cantu paternu). Ùn hè dunque stupente chì i giovani Francesco avia intesu resound in ellu, cum''è un zitellone, a chjama di vucazioni.</p><p class="montext">Stentu quindici, cci dumannò lu so ''patri pi daricci un pocu animali pà amparà i fundamenti di u cumerciu. Cù a spiranza sicreta chì stu figliolu à u caratteru digià bè ciuttata ch''edda campessi a tradizione di famiglia, ch''ellu accedes à a so dumanda. Dopu à più di furmazione in u liceu agriculu, in 1985, François embarks nantu à a storia sulu cincu anni più tardi. Annu dopu annu, ci aspetta comu a so banda ora avi 400 la testa. Discipline, strètte hè bisognu di François parmetti à risista à u rìtimu di u funziunamentu senza perda nunda di u so entusiasmu.</p><img src="images/blog/albertini02.jpg" alt="Francesco cù i so porchi" class="img-responsive"/><p class="montext">«Par i porchi, unu hè digià in l''aria. S''è no aghjunghje à sta passioni, accussì nun si vidi custrizzione.».</p><p class="montext">In tempu, Francis, rinisciu a misurari lu canciamentu di a so prufissioni. "A los hà cambiatu: oghje, unu studiente, lu fattens noi Hacks è vinnutu. Quissa hè bedda bona per mè: l''addevu mi piaci, mi piaci dinò à scambià a materia prima. È in più, ùn si sentenu cù un paese, mi piace à fà scopra i me prudutti à u visitatori! "A trifecta!</p>', 'Leggi la articulu nantu à François Albertini', '\r\nun porcu'),
(10, 1, 4, 'Le village de Muna', 'En Corse du Sud se cache un petit village qui fut progressivement abandonné suite à la première guerre mondiale. Situé à quelques km de Murzu', '<img src="images/blog/muna01.jpg" alt="Le village de Muna" class="img-responsive image-droite"/>\r\n<p class="montext">En Corse du Sud se cache un petit village qui fut progressivement abandonné suite à la première guerre mondiale. Situé à quelques km de Murzu et de Rosazia, il se reconnait à ses maisons de pierre construites en escalier sur la montagne de la Spusata. Déserté hors saison, il reprend vie en été, au passage des touristes venus retracer le passé. Empruntons ensemble la route menant au hameau de Muna.</p>\r\n<p class="montext">C’est à 50m d’altitude que repose le village de Muna dans la région de la Cinarca. Outre une vue panoramique unique, il offre un retour vers le passé et la possibilité de rendre hommage aux habitants disparus via une plaque commémorative installée sur le mur de l’Eglise. Car il faut savoir que Muna n’a pas toujours été inhabité : avant sa complète désertion, le hameau vivait en totale autonomie grâce à ses nombreuses ressources (oliviers, troupeaux d’ovins, châtaigniers, arbres à pains…) et l’exploitation forestière. Le bois, exporté ensuite via le fleuve du Liamone, servait, entre autres, à la fabrication de mâts de bateaux.</p>\r\n<img src="images/blog/muna02.jpg" alt="Maisons abandonnées" class="img-responsive"/><p class="montext">Mais c’était sans compter sur la guerre de 14-18 qui allait causer la mort de milliers de soldats insulaires, laissant seuls de nombreuses femmes et enfants. De plus en plus silencieux, Muna commença à s’éteindre petit à petit jusqu’en 1974 où le dernier habitant décida finalement de quitter les lieux, dès lors, sans vie.</p>\r\n<p class="montext">Aujourd’hui, Muna reste un village désert durant l’hiver mais se voit renaître à l’arrivée des beaux jours. Des travaux ont effectivement été réalisés afin de transformer de vieilles maisons en gîtes ruraux pouvant accueillir les touristes mais aussi les descendants de ceux qui ont, un jour, vécu ici. Pour favoriser la seconde vie de Muna, la commune a fait en sorte que certaines habitations disposent de l’eau courante.</p>\r\n  ', 'Lire l''article sur Muna', 'maison dans les bois'),
(11, 2, 4, 'The village of Muna', 'In South Corsica hides a small village that was phased out after the First World War. Located a few km from Murzu', '<img src="images/blog/muna01.jpg" alt="the village Muna" class="img-responsive image-droite"/>\r\n<p class="montext">In South Corsica hides a small village that was phased out after the First World War. Located a few km from Murzu and Rosazia, it can be recognized from its stone houses built stairs on the mountain of Spusata. Deserted out of season, it comes alive in summer, passing tourists from tracing the past. Borrow all the way to the hamlet of Muna.</p><p class="montext">It is 50 meters above sea level lies the village of Muna in the region of Cinarca. Besides a unique panoramic view, it offers a return to the past and the opportunity to pay tribute to the missing people via a plaque mounted on the wall of the church. For you must know that Muna has not always been uninhabited: before its complete desertion, the hamlet lived in total autonomy thanks to its many resources (trees, flocks of sheep, chestnuts, bread trees ...) and logging . Wood then exported via the river Liamone, served, among others, in the manufacture of boat masts.</p><img src="images/blog/muna02.jpg" alt="abandoned houses" class="img-responsive"/><p class="montext">But it was not counting on the war of 14-18 which would cause the death of thousands of soldiers island, leaving only many women and children. Increasingly silent, Muna began to die out gradually until 1974 when the last inhabitants finally decided to leave, therefore lifeless.</p><p class="montext">Today, Muna remains a deserted village in the winter but is seen reborn in the summertime. Work has indeed been made to convert old houses into flats can accommodate tourists but also the descendants of those who, one day, lived here. To promote the second life of Muna, the town has meant that some homes have running water.</p>\r\n  ', 'Read the article on Muna', 'House in the woods'),
(12, 3, 4, 'U paesi di Muna', 'In South Corsica cartoons hè un paisolu chì fù sapienza fora, dopu a prima guerra mundiali. Situé à uni pochi km da Murzu', '<img src="images/blog/muna01.jpg" alt="U paesi di Muna" class="img-responsive image-droite"/>\r\n<p class="montext">\r\nIn South Corsica cartoons hè un paisolu chì fù sapienza fora, dopu a prima guerra mundiali. Situé à uni pochi km da Murzu è Rosazia, si pò esse ricunnisciuti da a so casa di petra custruitu Spezia, nantu à a muntagna di Spusata. Abbannunaru fora di stagione, ùn vene vivu, a estate, passavanu i turisti da tracing in u passatu. Geronimi tuttu lu modu à u paisolu di Muna.</p><p class="montext">Hè di 50 metri supra liveddu di u mari si trova u paesi di Muna in lu territòriu di a Cinarca. Sparti di un panoramico unicu, ci prupone un ritornu à u passatu è l''occasione di fà pacà u tributu à u pòpulu manca grazi''à una portée muntati supra lu muru di la cresia. Picchì s''avi a sapiri chi Muna ùn hà sempri sunnu disabbitati: prima di a so compie diserzioni, u paisolu vissutu in totale autonumia à ringrazià à a so assai risorsi (arburi, e pècure di pecuri, e castagne, arburi pane ...) è Logging . Wood poi tutta nant''à u fiume, u Liamone, sirvutu, è tutti l''altri, in li cunfizzioni di arbuli barca.</p><img src="images/blog/muna02.jpg" alt="Maisons abandonnées" class="img-responsive"/><p class="montext">Ma ùn hè micca cuntava nantu à a guerra di u 14-18 chi facissi la morti di millai di suldati isula, lassandu sulu tanti e donne è zitelli. Sempri mutu, Muna si messe à more fora à pocu à pocu finu à lu 1974, quannu l ''ùrtimu abbitanti infini decisu di lascià, dunque senza vita.</p><p class="montext">Oghji, Muna ferma un paesi senza arma viva in l ''inguernu, ma hè vista rinvivisce in lu vagnatu. Travagliu hè statu veramente fattu a cunversione di i vechji casi in appartamenti, pò riceve i turisti ma dinù i discendenti di quelli chì, un ghjornu, stava quì. Par prumova u sicondu a vita di Muna, a cità hè vulia dì chì certi casi hanu acqua curriri.</p>\r\n ', 'Leggi la articulu nantu à Muna', 'casa in i boschi');

-- --------------------------------------------------------

--
-- Structure de la table `trd_tag`
--

CREATE TABLE IF NOT EXISTS `trd_tag` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `id_language` int(11) NOT NULL,
  `id_tag` int(11) NOT NULL,
  `traduction` varchar(75) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_TRDTAG_LANG_idx` (`id_language`),
  KEY `FK_TRDTAG_TAG_idx` (`id_tag`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COMMENT='table de traduction des etiquettes des messages' AUTO_INCREMENT=22 ;

--
-- Contenu de la table `trd_tag`
--

INSERT INTO `trd_tag` (`id`, `id_language`, `id_tag`, `traduction`) VALUES
(1, 1, 1, 'Visites'),
(2, 2, 1, 'Visits'),
(3, 3, 1, 'CO_Vìsite'),
(4, 1, 2, 'Patrimoine'),
(5, 2, 2, 'Heritage'),
(6, 3, 2, 'Patrimuniale'),
(7, 1, 3, 'Producteurs'),
(8, 2, 3, 'Producers'),
(9, 3, 3, 'Pruduttori'),
(10, 1, 4, 'Eleveurs'),
(11, 2, 4, 'Breeders'),
(12, 3, 4, 'Agricultori'),
(13, 1, 5, 'Recettes'),
(14, 2, 5, 'Recipes'),
(15, 3, 5, 'Ricetta'),
(16, 1, 6, 'Artisanat'),
(17, 2, 6, 'Craft'),
(18, 3, 6, 'Rilighjosi'),
(19, 1, 7, 'Rencontres'),
(20, 2, 7, 'Meetings'),
(21, 3, 7, 'CO_Rencontres');

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
