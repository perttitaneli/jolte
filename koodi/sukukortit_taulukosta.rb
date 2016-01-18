require 'roo'

class SukukortitTaulukosta
  TAULUKON_TIEDOSTONIMI = './source/sukutaulukko.ods'
  SUKUKORTTIHAKEMISTO = './source/suku/'
  VALILEHTI_SUKU = 'Suku'

  def self.luo_tiedostot
    sukukortit_taulukosta = SukukortitTaulukosta.new
    koodit = sukukortit_taulukosta.luo
    sukukortit_taulukosta.poista_tarpeettomat_kortit koodit
  end

  def poista_tarpeettomat_kortit(olemassa_olevat_koodit)
    kaikki_tiedostot = Dir.glob("#{SUKUKORTTIHAKEMISTO}*")
    kaikki_tiedostot.each do |sukukorttitiedosto|
      tiedoston_koodi = lue_sukukortin_koodi(sukukorttitiedosto)

      unless olemassa_olevat_koodit.include? tiedoston_koodi
        p "Henkilö poistettu sukutietotaulukosta, poistetaan kortti: #{sukukorttitiedosto}"
        File.delete(sukukorttitiedosto)
      end
    end
  end

  def lue_sukukortin_koodi(sukukorttitiedosto)
    if sukukorttitiedosto.include? SUKUKORTTIHAKEMISTO
      sukukorttitiedosto = sukukorttitiedosto.split('/').last
    end
    sukukorttitiedosto.split('/').last.split('-').first.split('.').first
  end


  def luo
    koodit = []
    ods = Roo::Spreadsheet.open(TAULUKON_TIEDOSTONIMI)
    valilehti = ods.sheet(VALILEHTI_SUKU)
    otsikot, rivimäärä = lue_otsikot(valilehti)

    (2..rivimäärä).each do |rivinumero|
      henkilo = lue_rivi(valilehti, rivinumero, otsikot)
      koodi = henkilo['Koodi']
      koodit << koodi
      lisää_taulu_tarvittaessa koodi, henkilo
    end
    koodit
  end

  def lue_otsikot(valilehti)
    otsikot = valilehti.row(1)
    rivimäärä = valilehti.last_row
    return otsikot, rivimäärä
  end

  def lue_rivi(valilehti, rivinumero, otsikot)
    Hash[[otsikot, valilehti.row(rivinumero)].transpose]
  end

  def lisää_taulu_tarvittaessa(koodi, henkilo)
    tiedostonimi = tiedosto_henkilölle henkilo

    tiedostopaate = '.html.markdown.erb'
    sukukortin_polku = sprintf "%s%s%s",
                               SUKUKORTTIHAKEMISTO,
                               tiedostonimi,
                               tiedostopaate
    varmista_olemassaolo koodi, sukukortin_polku

    tiedoston_sisalto = File.read(sukukortin_polku)
    vanhat_perustiedot = lue_perustiedot(tiedoston_sisalto)
    muuttui, uudet_perustiedot = päivitä_perustiedot(henkilo, vanhat_perustiedot)

    if muuttui
      uusi_tiedostosisalto = korvaa_perustiedot(tiedoston_sisalto, uudet_perustiedot)
      File.open(sukukortin_polku, "w") { |tiedosto| tiedosto.puts uusi_tiedostosisalto }
    end
  end

  def korvaa_perustiedot(vanha_tiedostosisalto, uudet_perustiedot)
    vanha_tiedostosisalto.gsub(/---(.|\n)*---/, uudet_perustiedot)
  end

  def lue_perustiedot(tiedoston_sisalto)
    # Tämän tiedoston osan nimi on Front Matter Middlemanissa
    tiedoston_sisalto.match /---(.|\n)*---/
  end

  def tiedosto_henkilölle(henkilö)
    taulu = henkilö['Koodi']
    etunimet = poista_erikoismerkit henkilö['Etunimi']
    sukunimi = poista_erikoismerkit henkilö['Sukunimi']

    if sukunimi
      tiedostonimi = sprintf "%s-%s-%s", taulu, etunimet, sukunimi
    else
      tiedostonimi = sprintf "%s-%s", taulu, etunimet, sukunimi
    end
    tiedostonimi
  end

  def varmista_olemassaolo(koodi, tiedostonimi)
    sukukorttitiedostot = Dir.glob(tiedostonimi)
    on_olemassa = false

    if sukukorttitiedostot.count > 0
      on_olemassa = true
    else
      tiedosto_alkaa_samalla_koodilla = Dir.glob("#{SUKUKORTTIHAKEMISTO}#{koodi}*")
      if tiedosto_alkaa_samalla_koodilla.count > 0
        sukukorttitiedosto = tiedosto_alkaa_samalla_koodilla.first
        tiedoston_koodi = lue_sukukortin_koodi(sukukorttitiedosto)
        if koodi.eql?(tiedoston_koodi)
          p "#{koodi} sukutaulu uudelleenimetään: #{sukukorttitiedosto} => #{tiedostonimi}"
          File.rename(sukukorttitiedosto, tiedostonimi)
          on_olemassa = true
        end
      end
    end

    unless on_olemassa
      p "#{koodi} sukutaulu puuttuu, luodaan: #{tiedostonimi}"
      tiedostosisalto = File.new(tiedostonimi, "w")
      tiedostosisalto.puts("---")
      tiedostosisalto.puts("---")
      tiedostosisalto.close
    end

    on_olemassa
  end

  def hae_vanha_arvo(perustiedon_avain, perustietolista)
    # Etsii listasta rivin joka alkaa oikealla avaimella
    perustietolista.find { |e| /"#{perustiedon_avain.downcase}/ =~ e }
  end

  def lisää_perustieto(perustietolista, tietorivi)
    viimeinen_paikka = perustietolista.count-1
    perustietolista.insert(viimeinen_paikka, tietorivi)
  end

  def korvaa_perustieto(vanha_arvo, uusi_arvo, perustietolista)
    perustietolista.map! { |rivi| rivi.include?(vanha_arvo) ? uusi_arvo : rivi }
  end

  def päivitä_perustiedot(henkilo, vanhat_perustiedot)
    muuttui = false
    perustiedot = ''
    if vanhat_perustiedot
      perustietolista = jaa_riveihin(vanhat_perustiedot)
      tietoavaimet = henkilo.keys
      tietoavaimet.each do |perustiedon_avain|
        uusi_arvo = henkilo[perustiedon_avain]

        if uusi_arvo.class == Date
          uusi_arvo = uusi_arvo.strftime("%d.%m.%Y")
        elsif uusi_arvo.class == Float
          uusi_arvo = uusi_arvo.to_i.round(0)
        end

        perustietorivi = sprintf "%s: %s", perustiedon_avain.downcase, uusi_arvo
        unless perustietolista.include?(perustietorivi)
          vanha_arvo = hae_vanha_arvo(perustiedon_avain, perustietolista)
          if vanha_arvo.nil?
            lisää_perustieto(perustietolista, perustietorivi)
          else
            replace_in_frontmatter(uusi_arvo, perustietorivi, perustietolista)
          end
          muuttui = true
        end

      end
      perustiedot = yhdista_rivinvaihdoilla(perustietolista)
    end
    return muuttui, perustiedot
  end

  def jaa_riveihin(vanhat_perustiedot)
    vanhat_perustiedot[0].split(/\n/)
  end

  def yhdista_rivinvaihdoilla(perustietolista)
    perustietolista.join("\n")
  end

  def poista_erikoismerkit(nimi)
    vastaus = nil
    if nimi
      # Poistaa skandit ja merkit joita ei voida näyttää
      vastaus = nimi.gsub(/ä/, 'a').
          gsub(/å/, 'a').gsub(/ö/, 'o').gsub(/Å/, 'A').gsub(/Ä/, 'A').gsub(/Ö/, 'O').
          gsub(/\W\-/, "").downcase.tr(" ", "-")
    end
    vastaus
  end

end