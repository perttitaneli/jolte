class Etsi
  HENKILÖT = 1
  SUKUTAULUT = 2
  TARINAT = 3

  attr_accessor :artikkelit

  def initialize(artikkelit)
    self.artikkelit = artikkelit
  end

  def self.aseta(sivukartta, hakutyyppi)
    case hakutyyppi
      when HENKILÖT
        henkilöt = artikkelit_polussa 'suku/', sivukartta
        hakukone = Etsi.new(henkilöt)
      when SUKUTAULUT
        sukutaulut = artikkelit_polussa 'sukupuut/', sivukartta
        hakukone = Etsi.new(sukutaulut)
      when TARINAT
        tarinat = artikkelit_polussa 'tarinat/', sivukartta
        hakukone = Etsi.new(tarinat)
      else
        hakukone = Etsi.new(sivukartta.resources)
    end
    hakukone
  end

  def self.artikkelit_polussa(polku, sivukartta)
    vastaus = []

    if onko_kartta? sivukartta
      sivukartta.resources.each do |artikkeli|
        if artikkeli.path.include?(polku)
          vastaus << artikkeli
        end
      end
    end
    vastaus
  end

  def self.onko_kartta?(sivukartta)
    sivukartta.class.name.eql? 'Middleman::Sitemap::Store'
  end

  def artikkeli_koodilla(koodi)
    vastaus = nil
    if koodi
      artikkelit.each do |artikkeli|
        id = hae_koodi artikkeli
        if id == koodi
          vastaus = artikkeli
          break
        end
      end
    end
    vastaus
  end

  def artikkeli_nimellä_tai_koodilla(nimi_tai_koodi)
    if sisältää_numeroita?(nimi_tai_koodi)
      koodi = poista_nimi_koodista nimi_tai_koodi
      artikkeli = artikkeli_koodilla(koodi)
    else
      artikkeli = artikkeli_nimellä nimi_tai_koodi
    end
    artikkeli
  end

  def artikkeli_nimellä(nimi)
    vastaus = nil
    if nimi
      artikkelit.each do |artikkeli|

        if omistaako_artikkelin?(nimi, artikkeli)
          vastaus = artikkeli
          break
        end
      end
    end
    vastaus
  end

  def lapset(isän_artikkeli, äidin_artikkeli)
    lapset = []
    isan_koodi = koodi isän_artikkeli
    aidin_koodi = koodi äidin_artikkeli
    artikkelit.each do |artikkeli|
      if isan_koodi && (isan_koodi.eql? isän_koodi(artikkeli)) &&
          aidin_koodi && (aidin_koodi.eql? äidin_koodi(artikkeli))
        lapset << artikkeli
      end
    end

    lapset
  end

  def puolisot(artikkeli)
    mammat = []

    isän_koodi = koodi(artikkeli)
    artikkelit.each do |artikkeli|
      if isän_koodi.eql? isän_koodi(artikkeli)
        äidin_koodi = äidin_koodi artikkeli
        if äidin_koodi.present?
          aidin_artikkeli = artikkeli_koodilla äidin_koodi
          mammat << (aidin_artikkeli || äidin_koodi)
        end
      end
    end

    mammat
  end

  def poista_nimi_koodista(nimi_ja_koodi)
    vastaus = nil

    nimen_osat = jaa_osiin(nimi_ja_koodi)
    nimen_osat.each do |osa|
      if sisältää_numeroita?(osa)
        vastaus = osa
        break
      end
    end
    vastaus
  end

  def poista_koodi_nimestä(nimi)
    vastaus = nil
    if nimi
      nimen_osat = jaa_osiin(nimi)
      sukunimi = nimen_osat.last
      if sisältää_numeroita?(sukunimi)
        nimen_osat = nimen_osat.reverse.drop(1).reverse
      end
      vastaus = nimen_osat.join(' ')
    end
    vastaus
  end

  def jaa_osiin(nimi)
    nimi.split(' ')
  end

  def omistaako_artikkelin?(nimi, artikkeli)
    vastaus = false

    if sisältää_numeroita?(nimi)
      nimi = poista_koodi_nimestä nimi
    end

    etunimet, sukunimi = hae_etunimet_ja_sukunimi(nimi)
    artikkelin_omistajan_sukunimi = artikkeli.data.sukunimi

    if artikkelin_omistajan_sukunimi && artikkelin_omistajan_sukunimi.eql?(sukunimi)
      artikkelin_omistajan_etunimi = artikkeli.data.etunimi

      etunimet_oikein = true

      etunimet.each do |etunimi|
        unless artikkelin_omistajan_etunimi.include?(etunimi)
          etunimet_oikein = false
          break
        end
      end
      if etunimet_oikein
        vastaus = true
      end
    end

    vastaus
  end

  def hae_etunimet_ja_sukunimi(nimi)
    nimen_osat = jaa_osiin nimi
    sukunimi = nimen_osat.last
    etunimet = nimen_osat.reverse.drop(1).reverse
    return etunimet, sukunimi
  end

  def sisältää_numeroita?(nimi_tai_koodi)
    nimi_tai_koodi =~ /\d/
  end

  def isän_koodi(artikkeli)
    vastaus = nil
    if artikkeli
      vastaus = artikkeli.data.try("isän koodi")
    end
    vastaus
  end

  def äidin_koodi(artikkeli)
    vastaus = nil
    if artikkeli
      vastaus = artikkeli.data.try("Äidin koodi")
    end
    vastaus
  end

  def koodi(artikkeli)
    if artikkeli
      artikkeli.data.koodi
    end
  end

  alias_method :hae_koodi, :koodi

end