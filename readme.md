# Migrants morts et disparus en Méditerranée (2014-2016)

<a href="http://cartotheque.sciences-po.fr/media/Migrants_morts_et_disparus_en_Mediterranee_2014-2016/2268"><img src="https://raw.githubusercontent.com/TomBor/missing-migrants/master/01-missing-migrants-Med-2014-2016.jpg" align="left"></a>

## Étapes de création de la carte
Outils nécessaire :
+   R
+   terminal shell
    +   [npm](https://www.npmjs.com/)
    +   [shp2json](https://github.com/mbostock/shapefile) : npm install -g shapefile
    
    +   [d3-geo-projection](https://github.com/d3/d3-geo-projection) : npm install -g d3-geo-projection
    
    +   [gdal](http://www.gdal.org/) : npm install -g gdal
+   QGIS
+   Illustrator ou un autre logiciel de dessin vectoriel

Sources :
+   Organisations internationale pour les migrations (OIM), [*Missing Migrants Project*](https://missingmigrants.iom.int/)
+   Fonds [Natural Earth](http://www.naturalearthdata.com/) à l'échelle 1:10m

### 1. Traitements des données sous R
Filtrer les données relative à la Méditarranée.   
Créer une grille pour regrouper et simplifier la localisation précise des évenements.   
Créer un graphique de l'évolution par mois.   
> script.r

### 2. Reprojection des fonds et de la grille
Utilisation de la projection 'Satellite' comprise dans d3.js ou dans Proj4 sous 'Titled perspective' (+proj=tpers).   
/!\ Le fichier raster original et les dérivés crées ne sont pas dans le répertoire. Mais l'original peut être récupéré : [Cross Blended Hypso with Relief, Water, Drains, and Ocean Bottom](http://www.naturalearthdata.com/downloads/10m-cross-blend-hypso/cross-blended-hypso-with-relief-water-drains-and-ocean-bottom/)
> script-d3.sh

### 3. Traitement cartographique de la grille sous QGIS
Représentation sous forme de points proportionnels

### 4. Rassembler et mettre en forme les éléments sous Illustrator
pdf editable avec la version CC

    
    
