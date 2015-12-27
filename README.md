# Jolte
Julkaisuohjelma sukututkijoille.

[Käyttö](.#Käyttö)

[Asennus](.#Asennus)

## Käyttö

[Jolte](http://perttitaneli.github.io/jolte/)

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
