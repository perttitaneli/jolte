require_relative 'etsi'
require_relative 'temput'

# Temput.module_eval do
#   module_function(:artikkeli_linkki)
#   public :artikkeli_linkki
# end

class LuoSukupuu
  attr_accessor :sivukartta
  attr_accessor :etsi
  attr_accessor :temput

  def initialize(sivukartta)
    self.sivukartta = sivukartta
  end

  def esivanhemmat(koodi, temput)
    self.temput = temput
    self.etsi = Etsi.aseta sivukartta, Etsi::HENKILÖT

    puun_html = nil
    if koodi
      artikkeli = etsi.artikkeli_koodilla koodi
      taulukon_solut = laske_taulukon_solut(artikkeli)
      puun_html = muodosta_taulukon_html taulukon_solut
    end
    puun_html
  end

  def muodosta_taulukon_html(taulukon_solut)
    html = ['<table>']
    rivimäärä = suurin_avain taulukon_solut
    sarakemäärä = suurin_sarake taulukon_solut

    for rivi in 0..rivimäärä
      rivin_solut = taulukon_solut[rivi]
      if rivin_solut
        html << '<tr>'
        suurin_sarake_rivillä = suurin_avain rivin_solut
        for sarake in 0..sarakemäärä
          koodi, rivien_kulutus = rivin_solut[sarake]
          teksti = sukupuun_taulun_tiedot koodi
          if teksti || sarake > suurin_sarake_rivillä
            if rivien_kulutus == 1
              html << sprintf("<td class='td-align-top'>%s</td>",
                              teksti)
            else
              if rivi == 0 && sarake == 0
                html << sprintf("<td rowspan='%s' class='td-align-top bold'>%s</td>",
                                rivien_kulutus, teksti)
              else
                html << sprintf("<td rowspan='%s' class='td-align-top'>%s</td>",
                                rivien_kulutus, teksti)
              end
            end
          end
        end
        html << '</tr>'
      end
    end
    html << '</table>'

    html.join('')
  end

  def suurin_sarake(taulukon_solut)
    avaimet = taulukon_solut.keys
    suurin = 0
    avaimet.each do |avain|
      rivin_solut = taulukon_solut[avain]
      rivin_suurin = suurin_avain rivin_solut
      if rivin_suurin > suurin
        suurin = rivin_suurin
      end
    end
    suurin
  end

  def suurin_avain(taulukon_solut)
    taulukon_solut.keys.max
  end

  def sukupuun_taulun_tiedot(koodi)
    vastaus = nil
    artikkeli = etsi.artikkeli_koodilla koodi
    if artikkeli
      linkki = temput.sukupuukoodilinkki koodi, artikkeli

      alku ="<div class='td-align-top'>"
      loppu = "</div>"
      vastaus = sprintf("%s<span class='bold'>%s</span> %s<br>s.%s %s<br><div class='pull-right'>%s</div>%s",
                        alku, artikkeli.data.etunimi,
                        artikkeli.data.sukunimi,
                        artikkeli.data.syntymäaika,
                        artikkeli.data.paikka,
                        linkki,
                        loppu)
    end
    vastaus
  end

  def laske_taulukon_solut(artikkeli)
    taulukon_solut = {}
    rivi = 0
    sarake = 0

    rivien_kulutus = etsi_vanhempien_solun_sijainti(taulukon_solut,
                                                    artikkeli,
                                                    rivi, sarake)

    rivin_solut = hae_rivi_hajautustaulusta(taulukon_solut, rivi)
    rivin_solut[sarake] = [artikkeli.data.koodi, rivien_kulutus]

    taulukon_solut
  end

  def etsi_vanhempien_solun_sijainti(taulukon_solut, artikkeli, rivi, sarake)
    sarake_nyt = sarake+1

    isän_rivien_kulutus = etsi_isän_solun_sijainti(artikkeli, taulukon_solut, rivi, sarake_nyt)
    aidin_rivi = rivi + isän_rivien_kulutus
    aidin_rivien_kulutus = etsi_aidin_solun_sijainti(artikkeli, taulukon_solut, aidin_rivi, sarake_nyt)

    isän_rivien_kulutus + aidin_rivien_kulutus
  end

  def etsi_aidin_solun_sijainti(artikkeli, taulukon_solut, rivi, sarake)
    äidin_koodi = etsi.äidin_koodi artikkeli
    aidin_artikkeli = etsi.artikkeli_koodilla äidin_koodi
    rivinkulutus = 1
    if aidin_artikkeli
      rivinkulutus = etsi_vanhempien_solun_sijainti(taulukon_solut, aidin_artikkeli, rivi, sarake)


      rivin_solut = hae_rivi_hajautustaulusta(taulukon_solut, rivi)
      rivin_solut[sarake] = [aidin_artikkeli.data.koodi, rivinkulutus]
    end
    rivinkulutus
  end

  def etsi_isän_solun_sijainti(artikkeli, taulukon_solut, rivi, sarake)
    isan_koodi = etsi.isän_koodi artikkeli
    isan_artikkeli = etsi.artikkeli_koodilla isan_koodi
    rivikulutus = 0

    if isan_artikkeli
      rivikulutus = etsi_vanhempien_solun_sijainti(taulukon_solut, isan_artikkeli, rivi, sarake)

      rivin_solut = hae_rivi_hajautustaulusta(taulukon_solut, rivi)
      rivin_solut[sarake] = [isan_artikkeli.data.koodi, rivikulutus]

    end
    rivikulutus
  end

  def luo_puulinkki(artikkeli)
    artikkeli.html.etunimi
  end

  def hae_rivi_hajautustaulusta(hajautustaulu, rivi)
    rivin_html = hajautustaulu[rivi]
    unless rivin_html
      hajautustaulu[rivi] = {}
      rivin_html = hajautustaulu[rivi]
    end
    rivin_html
  end

end