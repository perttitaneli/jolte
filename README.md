# Jolte
Julkaisuohjelma sukututkijoille.

## [Käyttö](https://github.com/perttitaneli/jolte/tree/master#käyttö-1)

1. [Sukutaulujen lisäys](https://github.com/perttitaneli/jolte/tree/master#sukutaulujen-lisäys)


## [Asennus](https://github.com/perttitaneli/jolte/tree/master#Asennus Windows-ympäristöön-1)

## [Lisenssi](https://github.com/perttitaneli/jolte/tree/master#lisenssi-1)

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


## Lisenssi

Jolten lähdekoodi on vapaasti kopioitavissa ja muokattavissa omaan käyttöön. Jolten lähdekoodi käyttää [GPL lisenssiä](https://fi.wikipedia.org/wiki/GNU_General_Public_License).

Kaikkien omaan sukututkimukseeni liittyvien hakemistojen (suku, images, tarinat, ...) sisältö on normaalilla tekijänoikeudella suojattu eikä kuulu avoimen lähdekoodin lisenssin piiriin. Mikäli otat Jolten omaan käyttöösi, poista näiden hakemistojen sisällöt ennen julkaisua.


## Asennus Windows-ympäristöön

1. Asenna [Git Windows client](https://git-scm.com/download/win)
2. Avaa Command Prompt (suomenkielisessä versiossa Komentorivi)
3. Siirry hakemistoon, mihin haluat ladata Jolten, esim. `c:\users\nn`
4. Kloonaa Jolte versionhallinnasta omalle koneelle
```
git clone https://github.com/perttitaneli/jolte.git
```
