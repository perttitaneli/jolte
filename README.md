# Jolte
Julkaisuohjelma sukututkijoille.

## [Käyttö](https://github.com/perttitaneli/jolte/tree/master#käyttö-1)

1. [Sukutaulujen lisäys](https://github.com/perttitaneli/jolte/tree/master#sukutaulujen-lisäys)


## [Asennus](https://github.com/perttitaneli/jolte/tree/master#asennus-1)

## Käyttö

Katsele julkaistuja tietoja: [Jolte](http://perttitaneli.github.io/jolte/)

### Sukutaulujen lisäys

Sukutaulut lisätään [`suku`-hakemistoon](https://github.com/perttitaneli/jolte/tree/master/source/suku). 
Taulut tallennetaan tekstitiedostoina joita voit muokata haluamallasi ohjelmalla. 
Tiedostojen pääte on `.html.markdown.erb` ja nimi vapaasti valittavissasi.   

```markdown
---
taulu: A304
sukunimet: Viljakkala
---
```

### Henkilöiden linkitys

Kun lisäät puolisot ja lapset sukutauluun, jolte linkittää heidän tietonsa automaattisesti. 

Linkitettävät henkilöt lisätään `etunimet sukunimi taulu` muodossa. Taulua ja etunimiä ei ole pakko syöttää. 
Ohjelma ei tarkista etunimien järjestystä. Jos suvussa on tapana kierrättää etunimiä, suosittelemme taulunumeroiden käyttöä.

```markdown
---
lapset: Johanna Kulmala A399, Viljami Kulmala
---
```

Näin lisäät linkin henkilötauluun:

```erb
<%= nimilinkki 'A304' %>
```

Voit määrittää linkissä käytetyn tekstin:

```erb
<%= nimilinkki 'A304', 'Marian taulu' %>
```

Myös tässä nimitunnistus toimii ja voit jättää taulunumeron pois:

```erb
<%= nimilinkki 'Maria Johanssdr' %>
```

### Tarinoiden lisäys

Tarinat lisätään [`tarinat`-hakemistoon](https://github.com/perttitaneli/jolte/tree/master/source/tarinat). 


## Asennus

Jolte on vapaasti kopioitavissa omaan käyttöösi. Suku-, images- ja tarinat-hakemistojen 
sisältö on normaalilla tekijänoikeudella suojattu eikä kuulu vapaan ohjelmistolisenssin piiriin.
