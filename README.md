# Jolte
Jolte on julkaisuohjelma sukututkijoille. Katsele Joltella julkaistuja tietoja: [Kalkbacken](http://perttitaneli.github.io/jolte/)


## Lisenssi

Jolten lähdekoodi on vapaasti kopioitavissa ja muokattavissa omaan käyttöön. Jolten lähdekoodi käyttää [GPL lisenssiä](https://fi.wikipedia.org/wiki/GNU_General_Public_License).

Kaikkien omaan sukututkimukseeni liittyvien hakemistojen (suku, images, tarinat, ...) sisältö on normaalilla tekijänoikeudella suojattu eikä kuulu avoimen lähdekoodin lisenssin piiriin. Mikäli otat Jolten omaan käyttöösi, poista näiden hakemistojen sisällöt ennen julkaisua.

## 1. Yleistä Jolten käytöstä
## 2. Jolten peruskäyttö
### 2.1 Muiden tekemien muutokset hakeminen - `hae.bat`
### 2.2 Muuttuneiden tiedostojen tarkistaminen - `muutokset.bat`
### 2.3 Tietojen julkaiseminen - `julkaise.bat "OMA KOMMENTTI"`
## 3. Jolten tiedostojen hallinta
### 3.1 [Henkilöiden lisäys](https://github.com/perttitaneli/jolte/tree/master#henkilöiden-lisäys)
### 3.2 Henkilöiden linkitys
### 3.3 Tarinoiden lisäys
## 4. Käsitteitä
## 5. [Asennus](https://github.com/perttitaneli/jolte/tree/master#asennus)

-----------------------------------------

## Yleistä Jolten käytöstä

Nettisivulle julkaistavat tiedot syötetään teksti- ja kuvatiedostoina, jotka säilötään versionhallintaan. Sieltä ne julkaistaan nettiin automaattisesti.

Tekstitiedostoille on käytettävä Jolten oma formaattia ja niiden tiedostopääte on `.html.markdown.erb`.

`source/suku` sisältää kaikkien henkilöiden taulut perustietoineen.
`source/tarinat` sisältää yleisiä tarinoita henkilöiden elämästä

Tiedostojen rakenteesta lisää alempana.

Kuvatiedostot talletetaan [`images`-hakemistoon](https://github.com/perttitaneli/jolte/tree/master/source/images). Jolte tukee yleisimpiä  kuvaformaatteja kuten .jpg tai .png. Kuvien koko kannattaa olla normaalia pienempi, että nettisivut latautuvat nopeasti hitaammallakin yhteydellä.


## Jolten peruskäyttö

Jolten mukana tulee 3 komentojonotiedostoa käytön helpottamiseksi Windows-ympäristössä. Voit luoda niille kuvakkeet Työpöydälle tai ajaa Komentoriviltä Jolten hakemistosta.

### Muiden tekemien muutokset hakeminen - `hae.bat`

Ennen kuin alat muokkaamaan tiedostoja omalla tietokoneellasi, on aina hyvä hakea viimeisimmät versiot versionhallinnasta.

Erityisen tärkeää tämä on jos  useampi henkilö tekee lisäyksiä ja päivityksiä projektiin.

Muutokset haetaan suorittamalla komento `hae.bat`


### Muuttuneiden tiedostojen tarkistaminen - `muutokset.bat`

Mikäli haluat ennen julkaisua tarkistaa mitä tiedostoja olet muuttanut, voit ajaa komennon `muutokset.bat`.

Komento listaa lisätyt, muokatut ja poistetut tiedostot suhteessa versionhallinnan tilanteeseen.


### Tietojen julkaiseminen - `julkaise.bat`

Kun lisäät uusia henkilöitä, luo uusi taulut-muotoinen tiedosto hakemistoon [`suku`-hakemistoon](https://github.com/perttitaneli/jolte/tree/master/source/suku). Voit käyttää pohjana mallitiedostoa `xxx.html.markdown.erb`

Nimi on vapaasti valittavissa, mutta siinä on hyödyllistä käyttää tiettyä systemaattista käytäntöä, esimerkiksi `taulun_tunnistenumero-etunimi-sukunimi.html.markdown.erb`

Olemassa olevia tiedostoja muokataan suoraan avaamalla tiedosto tekstieditorissa ja tallettamalla muutokset.

Kun kaikki muutokset on tehty, suorita julkaisu ajamalla `julkaise.bat`.


## Jolten tiedostojen hallinta

### Henkilöiden lisäys

Taulu-tyyppisen tiedoston esimerkkirakenne

```markdown
---
taulu: A304
etunimet: Johan
sukunimi: Viljakkala
syntyi: 1.1.1801
puoliso: Anna Matsdotr
lapset: Johanna Kulmala A399, Viljami Kulmala
---
```

Kun lisäät puolisot ja lapset sukutauluun, Jolte tekee linkit heidän tauluihinsa automaattisesti.

Linkitettävät henkilöt (kohtiin puoliso ja lapset) lisätään `etunimet sukunimi taulu` muodossa. Taulunumeroa ja etunimiä ei ole pakko syöttää. Ohjelma ei tarkista etunimien järjestystä. Jos suvussa on tapana kierrättää etunimiä, suosittelemme taulunumeroiden käyttöä.


### Henkilöiden linkitys käsin

Linkkejä henkilöihin voi lisätä tarinoihin tai henkilötaulun perustekstiin.

Alla kolme tapaa lisätä linkki.

1. Linkkaus pelkällä taulunumerolla

```erb
<%= nimilinkki 'A304' %>
```

2. Voit määrittää linkissä käytetyn tekstin:

```erb
<%= nimilinkki 'A304', 'Marian taulu' %>
```

3. Linkkaus pelkällä nimellä ilman taulunumeroa:

```erb
<%= nimilinkki 'Maria Johanssdr' %>
```

### Tarinoiden lisäys

Tarinat lisätään [`tarinat`-hakemistoon](https://github.com/perttitaneli/jolte/tree/master/source/tarinat).


## Käsitteitä

versionhallinta GitHub


## Asennus

Windows-ympäristössä

1. Asenna [Git Windows client](https://git-scm.com/download/win)
2. Avaa Command Prompt (suomenkielisessä versiossa Komentokehote)
3. Siirry hakemistoon, mihin haluat ladata Jolten, esim. `c:\users\nn`
4. Kloonaa Jolte versionhallinnasta omalle koneelle `git clone https://github.com/perttitaneli/jolte.git`
5. Aseta Git tunnukset ympäristömuuttujiin %JOLTE_USERNAME% ja %JOLTE_PASSWORD%
