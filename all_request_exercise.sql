-- 1
-- Nom des lieux qui finissent par 'um'
SELECT nom_lieu
FROM lieu
WHERE nom_lieu LIKE '%um';

-- 2
-- Nombre de personnages par lieu (trié par nombre de personnages décroissant).
-- Sélectionne les colonnes "id_lieu" et "COUNT(*)" de la table "personnage"
SELECT id_lieu, COUNT(*) as num_characters
FROM personnage
-- Groupement des données par "id_lieu"
GROUP BY id_lieu
-- Tri des données par "num_characters" en ordre décroissant
ORDER BY num_characters DESC;

-- 2+
-- Nom des lieux et nombres de personnages par lieu
-- Sélectionne les colonnes "l.nom_lieu" et "COUNT(*)" de la table "personnage"
SELECT lieu.nom_lieu, COUNT(*) as num_characters
FROM personnage 
-- Jointure de la table "lieu" avec la table "personnage" en utilisant la condition "p.id_lieu = l.id_lieu"
JOIN lieu  ON personnage.id_lieu = lieu.id_lieu
-- Groupement des données par "l.nom_lieu"
GROUP BY nom_lieu
-- Tri des données par "num_characters" en ordre décroissant
ORDER BY num_characters DESC;

-- 3
-- Sélectionne les colonnes nom_personnages, adresse_personnage, id_spécialité, id_lieu.
SELECT nom_personnage, adresse_personnage, id_specialite, id_lieu
-- Dans la table personnage 
FROM personnage
-- Trié par id_lieu puis par nom_personnage, dans un ordre ascendant.
ORDER BY id_lieu, nom_personnage ASC;

-- 4
-- Nom des spécialités avec nombre de personnages par spécialité, trié par nombre personnages décroissant
SELECT specialite.nom_specialite, COUNT(personnage.id_specialite) as nb_personnages
FROM personnage
JOIN specialite ON personnage.id_specialite = specialite.id_specialite
GROUP BY specialite.nom_specialite
ORDER BY nb_personnages DESC;

-- 5
-- Nom, date et lieu des batailles, classées de la plus récente à la plus ancienne (dates affichées
-- au format jj/mm/aaaa).

SELECT nom_bataille, DATE_FORMAT(date_bataille, '%d-%m-%Y'), lieu.nom_lieu, bataille.id_lieu
FROM bataille
JOIN lieu ON bataille.id_lieu = lieu.id_lieu
ORDER BY date_bataille DESC

-- 6
-- Nom des potions + coût de réalisation de la potion, classé par cout desc.

-- Sélectionne les noms des potions et le coût total de production de chaque potion
SELECT p.nom_potion, 
       -- Calcule le coût total en somme les coûts de chaque ingrédient multiplié par leur quantité utilisée
       SUM(i.cout_ingredient * r.qte) AS cout_total
-- Depuis la table des potions
FROM potion p
-- Rejoins la table des compositions pour trouver les ingrédients associés à chaque potion
JOIN composer r ON p.id_potion = r.id_potion
-- Rejoins la table des ingrédients pour trouver le coût de chaque ingrédient
JOIN ingredient i ON r.id_ingredient = i.id_ingredient
-- Groupes les lignes par nom de potion
GROUP BY p.nom_potion
-- Trie les lignes par coût total décroissant
ORDER BY cout_total DESC;

-- 7
-- Nom des ingrédients + coût + quantité de chaque ingrédient qui composent la potion 'Santé'.

-- Selectionne et fais le total de prix de chaque ingredient avec sa quantité (cout_qtt_ingredient)
SELECT i.nom_ingredient, i.cout_ingredient, r.qte, i.cout_ingredient * r.qte AS cout_qtt_ingredient
-- Dans la table
FROM ingredient i
-- Joint les tables
JOIN composer r ON i.id_ingredient = r.id_ingredient
JOIN potion p ON r.id_potion = p.id_potion
-- Précise quelle potion
WHERE p.nom_potion = 'Santé';

-- 7+
-- Selectionne et fais le total de prix de chaque ingredient avec sa quantité
SELECT i.nom_ingredient, i.cout_ingredient, r.qte, i.cout_ingredient * r.qte AS cout_,
       (SELECT SUM(i2.cout_ingredient * r2.qte)
        FROM ingredient i2
        JOIN composer r2 ON i2.id_ingredient = r2.id_ingredient
        JOIN potion p2 ON r2.id_potion = p2.id_potion
        WHERE p2.nom_potion = 'Santé') AS cout_total_potion
FROM ingredient i
JOIN composer r ON i.id_ingredient = r.id_ingredient
JOIN potion p ON r.id_potion = p.id_potion
WHERE p.nom_potion = 'Santé';

-- 8
-- Nom du ou des personanges qui ont pris le plus de casques dans la bataille 'Bataille du village gaulois'.

SELECT a.nom_personnage, MAX(b.qte)
FROM personnage a
INNER JOIN  prendre_casque b ON a.id_personnage = b.id_personnage
INNER JOIN bataille c ON c.id_bataille = b.id_bataille
WHERE qte = (SELECT MAX(qte) FROM prendre_casque)
AND nom_bataille = 'Bataille du village gaulois'
GROUP BY nom_personnage

-- 9
-- Nom des personnages et leurs quantité de potion bue (en les classant du plus grand buveur au plus petit)

SELECT pers.nom_personnage, dose_boire
FROM personnage pers
INNER JOIN boire bo ON pers.id_personnage = bo.id_personnage
ORDER BY dose_boire DESC

-- 10
-- Nom de la bataille où le nombre de casques pris a été le plus important.

SELECT nom_bataille
FROM bataille
INNER JOIN prendre_casque ON prendre_casque.id_bataille = bataille.id_bataille
WHERE qte = (SELECT MAX(qte) FROM prendre_casque)
GROUP BY nom_bataille

-- vérifier requête 9 en affichant la somme des casque pris par batailles
SELECT nom_bataille, sum(qte)
FROM bataille
INNER JOIN prendre_casque ON prendre_casque.id_bataille = bataille.id_bataille
WHERE bataille.id_bataille=prendre_casque.id_bataille
GROUP BY nom_bataille
ORDER BY sum(qte) DESC

-- 11
-- Nombre de casque de chaque type et leur cout total (classé par nombre décroissant)
SELECT count(nom_casque), SUM(cout_casque), id_type_casque
FROM casque 
GROUP BY id_type_casque
ORDER BY COUNT(nom_casque) DESC

-- 12
-- Nom des potions dont un des ingrédients est le poisson frais.
SELECT nom_potion    
FROM potion 
INNER JOIN composer ON composer.id_potion = potion.id_potion
INNER JOIN ingredient ON ingredient.id_ingredient = composer.id_ingredient
WHERE nom_ingredient = 'Poisson frais'

-- 13
-- Nom du/des lieu(x) possédant le plus d'habitants, en dehors du village gaulois.

SELECT nom_lieu AS 'nlieu',COUNT(id_personnage) AS population
FROM lieu
INNER JOIN personnage ON personnage.id_lieu = lieu.id_lieu
WHERE nom_lieu != 'Village gaulois'
GROUP BY nlieu
HAVING population >= ALL (
    SELECT COUNT(p.id_personnage)
    FROM lieu l
    INNER JOIN personnage p ON p.id_lieu = l.id_lieu
    WHERE nom_lieu != 'Village gaulois'
    GROUP BY l.nom_lieu
    )

-- 14
-- Nom des personnages qui n'ont jamais bu aucune potion

SELECT p.nom_personnage
FROM personnage p
LEFT JOIN boire b ON p.id_personnage = b.id_personnage
WHERE b.id_personnage IS NULL

-- 15
-- Nom du/des personnages qui n'ont pas le droit de boire de la potion 'Magique'

SELECT nom_personnage
FROM personnage p
LEFT JOIN autoriser_boire a ON  a.id_personnage = p.id_personnage
WHERE p.id_personnage  NOT IN 
	(
	SELECT id_personnage 
	FROM autoriser_boire 
	WHERE id_potion='1'
	)
GROUP BY nom_personnage
ORDER BY nom_personnage 


---------------------- EN ECRIVANT TOUJOURS DES REQUETES SQL, MODIFIEZ LA BASE DE DONNEES COMME SUIT : ---------------

-- A
-- Ajoutez le personnage suivant : Champdeblix, agriculteur résidant à la ferme Hantassion de Rotomagus
INSERT INTO personnage (nom_personnage, id_specialite, id_lieu, adresse_personnage)
VALUES ('Champdeblix', 12, 6, 'Ferme Hantassion');

-- A+
-- Supprimer les doublons sur le nom_personnage dans la table personnage 
-- On sélectionne les lignes à supprimer dans la table personnage
DELETE p1
FROM personnage p1
/* On crée une jointure avec la table personnage pour trouver les doublons 
et on selectionne les lignes qui ont même nom_personnage et un id_personnage supérieur*/
INNER JOIN personnage p2
ON p1.nom_personnage = p2.nom_personnage AND p1.id_personnage > p2.id_personnage;


-- B
-- Autorisez Bonemine à boire de la potion magique, elle est jalouse d'Iélosubmarine

--Ajouter une ligne dans table "autoriser_boire" avec ses colonnes tels que (id_personnage, id_potion)
INSERT INTO autoriser_boire (id_personnage, id_potion)
--Ligne possédant les valeurs ("12", "1") affecté aux colonnes tels que précisé précedemment
VALUES ("12", "1")

-- C
-- Supprimez les casques grecs qui n'ont jamais été pris lors d'une bataille

-- Supprimer dans la table casque
DELETE FROM casque
-- les casque avec id_type_casque = 2
WHERE id_type_casque = 2 
-- et dont l'id_casque n'est pas présent dans la table "prendre_casque", ce qui veut dire qu'ils n'ont pas été pris.
AND id_casque NOT IN (SELECT id_casque FROM prendre_casque);

-- D
-- Modifiez l'adresse de Zérozérosix: il a été mis en prison à Condate.

-- Modifier l'adresse pour "en prison"
UPDATE personnage 
SET adresse_personnage = 'En prison' 
WHERE id_personnage = '23';
-- Modifier le lieu pour "Condate"
UPDATE personnage 
SET id_lieu ='9' 
WHERE id_personnage = '23';

-- E
-- La potion 'soupe' ne doit plus contenir de persil

-- Supprimer dans la table composer
DELETE FROM composer 
-- les lignes avec id_potion = 9 (soupe)
WHERE id_potion = 9 
-- qui ont comme id_ingredient = 19 (persil)
AND id_ingredient = 19

-- F
-- Obelix s'est trompé: ce sont 42 casque Weisenau, et non Ostrogoths, qu'il a pris lors de la bataille 'Attaque de la banque postale'. Corrigez son erreur.

-- Modifier dans prendre_casque
UPDATE prendre_casque 
-- Définir la valeur de id_casque à '10'
SET id_casque='10'
-- Pour la bataille avec id_bataille = 9 (attaque de la banque postale)
WHERE id_bataille='9' 
