require 'faker'

# testausta varten, oikeassa ympäristössä artikkelit tulevat middlemanilta.
class Artikkeli
  attr_accessor :tiedot

  def initialize(tiedot)
    self.tiedot = tiedot
  end

  def self.isä(lapsen_artikkeli, isän_koodi)
    isän_artikkeli= Artikkeli.luo koodi: isän_koodi
    lapsen_artikkeli.tiedot['isän koodi'] = isän_artikkeli.koodi
    isän_artikkeli
  end

  def self.äiti(lapsen_artikkeli, äidin_koodi)
    aidin_artikkeli= Artikkeli.luo koodi: äidin_koodi
    lapsen_artikkeli.tiedot["Äidin koodi"] = aidin_artikkeli.koodi
    aidin_artikkeli
  end

  def self.luo(parametrit)
    tiedot = {}
    koodi = parametrit[:koodi]
    if koodi
      tiedot['koodi'] = koodi
    end

    isä = parametrit[:isä]
    if isä
      tiedot['isän koodi'] = isä
    end

    äiti = parametrit[:äiti]
    if äiti
      tiedot["Äidin koodi"] = äiti
    end

    etunimi = parametrit[:etunimi]
    if etunimi
      tiedot['etunimi'] = etunimi
    else
      tiedot['etunimi'] = Faker::Name.first_name
    end

    sukunimi = parametrit[:sukunimi]
    if sukunimi
      tiedot['sukunimi'] = sukunimi
    else
      tiedot['sukunimi'] = Faker::Name.first_name
    end

    Artikkeli.new tiedot
  end

  def sukunimi
    tiedot['sukunimi']
  end

  def syntymäaika
    'syntymäaika'
  end

  def paikka
    'Tampere'
  end

  def etunimi
    tiedot['etunimi']
  end

  def koodi
    tiedot['koodi']
  end

  def try(parametri)
    tiedot[parametri]
  end

  def data
    self
  end

end