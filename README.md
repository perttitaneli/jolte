# Jolte
Julkaisuohjelma sukututkijoille.

## [Käyttö](https://github.com/perttitaneli/jolte/tree/master#käyttö)

1. [Sukutaulujen lisäys](https://github.com/perttitaneli/jolte/tree/master#sukutaulujen-lisäys)


## [Asennus](https://github.com/perttitaneli/jolte/tree/master#asennus)

Katselu: [Jolte](http://perttitaneli.github.io/jolte/)

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

### Tarinoiden lisäys

### Henkilöiden linkitys

```erb
<%= nimilinkki 'A304' %>
```

## Asennus

Jolte on vapaasti kopioitavissa omaan käyttöösi. Suku-, images- ja tarinat-hakemistojen 
sisältö on normaalilla tekijänoikeudella suojattu eikä kuulu vapaan ohjelmistolisenssin piiriin.
