# Tekee henkilölinkit ja sukupuut
require_relative 'luo_sukupuu'
require_relative 'etsi'

module Temput

  def sukupuu(koodi)
    luo_puu.esivanhemmat koodi, self
  end

  def luo_puu
    LuoSukupuu.new(sivukartta)
  end

  def tämä_artikkeli
    current_page
  end

  def sivukartta
    sitemap
  end

  def puolisot(artikkeli)
    etsi = Etsi.aseta sivukartta, Etsi::HENKILÖT
    etsi.puolisot artikkeli
  end

  def lapset(isän_artikkeli, äidin_artikkeli)
    etsi = Etsi.aseta sivukartta, Etsi::HENKILÖT
    etsi.lapset isän_artikkeli, äidin_artikkeli
  end

  def isän_koodi(artikkeli)
    etsi = Etsi.aseta sivukartta, Etsi::HENKILÖT
    etsi.isän_koodi artikkeli
  end

  def äidin_koodi(artikkeli)
    etsi = Etsi.aseta sivukartta, Etsi::HENKILÖT
    etsi.äidin_koodi artikkeli
  end

  def sukupuukoodilinkki(koodi, artikkeli)
    luo_linkki koodi, artikkeli
  end

  def artikkelilinkki(artikkeli)
    if artikkeli.data.linkki
      linkin_teksti = artikkeli.data.linkki
      luo_linkki linkin_teksti, artikkeli
    else
      linkin_teksti = sprintf("%s %s",
                              artikkeli.data.etunimi,
                              artikkeli.data.sukunimi)
      linkki = luo_linkki linkin_teksti, artikkeli
      sprintf("%s %s s. %s", artikkeli.data.koodi, linkki, artikkeli.data.syntymäaika)
    end
  end

  def tarinan_henkilöt(artikkeli)
    vastaus = []
    henkilöt = artikkeli.data.henkilöt
    if henkilöt
      vastaus = henkilöt.split(',')
    end
    vastaus
  end

  def tarinat_henkilölle(artikkeli)
    vastaus = []

    etsi = Etsi.aseta sivukartta, Etsi::HENKILÖT

    tarinat.each do |tarina_artikkeli|
      nimet = tarinan_henkilöt tarina_artikkeli
      nimet.each do |nimi|
        if etsi.artikkeli_nimellä(nimi) == artikkeli
          vastaus << tarina_artikkeli
        end
      end
    end
    vastaus
  end

  def tarinat
    etsi = Etsi.aseta sivukartta, Etsi::TARINAT
    etsi.artikkelit
  end

  def hae_koodilla(koodi)
    etsi = Etsi.aseta sivukartta, Etsi::HENKILÖT
    etsi.artikkeli_koodilla koodi
  end

  def sukutaulut
    etsi = Etsi.aseta sivukartta, Etsi::SUKUTAULUT
    etsi.artikkelit
  end

  def henkilöartikkelit
    etsi = Etsi.aseta sivukartta, Etsi::HENKILÖT
    etsi.artikkelit
  end

  def nimilinkki(nimi_tai_koodi, teksti=nil)
    vastaus = teksti || nimi_tai_koodi
    etsi = Etsi.aseta sivukartta, Etsi::HENKILÖT
    artikkeli = etsi.artikkeli_nimellä_tai_koodilla(nimi_tai_koodi)

    if artikkeli

      linkin_teksti = teksti || "#{artikkeli.data.etunimi} #{artikkeli.data.sukunimi}"

      vastaus = luo_linkki linkin_teksti, artikkeli
    end

    vastaus
  end

  def henkilötiedot(artikkeli)
    etsi = Etsi.aseta sivukartta, Etsi::HENKILÖT
    sprintf "%s %s %s s.%s %s",
            etsi.koodi(artikkeli),
            artikkeli.data.etunimi,
            artikkeli.data.sukunimi,
            artikkeli.data.syntymäaika,
            artikkeli.data.paikka
  end

  def luo_linkki(linkin_teksti, artikkeli)
    link_to linkin_teksti, artikkeli
  end


  def git_linkki(artikkeli)
    koodi = artikkeli.data.koodi
    etunimi = poista_erikoismerkit(artikkeli.data.etunimi)
    sukunimi = poista_erikoismerkit(artikkeli.data.sukunimi)
    repo = 'http://github.com/perttitaneli/jolte/blob/master/source/suku/'
    tiedostopaate = '.html.markdown.erb'
    if sukunimi
      vastaus = sprintf "%s%s-%s-%s%s", repo, koodi, sukunimi, etunimi, tiedostopaate
    else
      vastaus = sprintf "%s%s-%s%s", repo, koodi, sukunimi, etunimi, tiedostopaate
    end

    vastaus
  end

  def poista_erikoismerkit(teksti)
    vastaus = nil
    if teksti
      # Poistaa skandit ja muut erikoismerkit
      vastaus = teksti.gsub(/ä/, 'a').
          gsub(/å/, 'a').gsub(/ö/, 'o').gsub(/Å/, 'A').gsub(/Ä/, 'A').gsub(/Ö/, 'O').
          gsub(/\W\-/, "").downcase.tr(" ", "-")
    end
    vastaus
  end

end

