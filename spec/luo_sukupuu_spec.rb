require_relative '../koodi/temput'
require_relative 'artikkeli'

describe LuoSukupuu do
  let!(:puu) { LuoSukupuu.new [] }
  let!(:juuri) { Artikkeli.luo koodi: 'Juuri' }

  let!(:ilpo) { Artikkeli.isä juuri, 'Ilpo-Juuri' }
  let!(:eva) { Artikkeli.äiti juuri, 'Eva-Juuri' }

  let!(:aki) { Artikkeli.isä ilpo, 'Aki-Ilpo-Juuri' }
  let!(:lea) { Artikkeli.äiti ilpo, 'Lea-Ilpo-Juuri' }

  let!(:pia) { Artikkeli.äiti eva, 'Pia-Eva-Juuri' }
  let!(:temput) { double('Temput') }

  #      0   |     1      |       2
  # 0  juuri | ilpo-juuri | aki-ilpo-juuri
  # 1        |            | lea-ilpo-juuri
  # 2        | eva-juuri  |
  # 3        |            | pia-eva-juuri


  before do
    allow(temput).to receive(:sukupuukoodilinkki).and_return('KOODI_LINKKI')
  end

  describe 'esivanhemmat' do

    it "rakentaa html-taulukon" do
      testidata = [juuri]
      etsi = Etsi.new(testidata)
      allow(Etsi).to receive(:aseta).and_return(etsi)
      puu.etsi = etsi

      html = puu.esivanhemmat 'Juuri', temput
      expect(html).to eq sprintf("%s%s%s%s%s%s%s%s%s%s",
                                 "<table><tr><td class='td-align-top'>",
                                 "<div class='td-align-top'><span class='bold'>",
                                 juuri.etunimi,
                                 "</span> ",
                                 juuri.sukunimi,
                                 "<br>s.",
                                 juuri.syntymäaika,
                                 " ",
                                 juuri.paikka,
                                 "<br><div class='pull-right'>KOODI_LINKKI</div></div></td></tr></table>")
    end
  end

  describe 'etsi_vanhempien_solun_sijainti' do
    let(:solut) { {} }

    it 'rivinkulutus on 2 jos molemmat vanhemmat mukana' do
      testidata = [juuri, ilpo, eva]
      puu.etsi = Etsi.new testidata

      rivinkulutus = puu.etsi_vanhempien_solun_sijainti solut, juuri, 0, 0
      expect(rivinkulutus).to eq 2
    end

    it 'laittaa äidin samaan sarakkeeseen kuin isä' do
      testidata = [juuri, ilpo, eva]
      puu.etsi = Etsi.new testidata

      puu.etsi_vanhempien_solun_sijainti solut, juuri, 0, 0
      expect(solut[0][1]).to eq ["Ilpo-Juuri", 1]
      expect(solut[1][1]).to eq ["Eva-Juuri", 1]
    end
  end

  describe 'laske_taulukon_solut' do

    it 'laskee rivit ja sarakkeet oikein' do
      testidata = [juuri, ilpo, eva, lea]
      puu.etsi = Etsi.new testidata
      solut = puu.laske_taulukon_solut juuri
      expect(solut[0][0]).to eq ['Juuri', 2]
      expect(solut[0][1]).to eq ['Ilpo-Juuri', 1]
      #Ilpon:n isä asettamatta, lea siirtyy ylös
      expect(solut[0][2]).to eq ['Lea-Ilpo-Juuri', 1]

      expect(solut[1][1]).to eq ["Eva-Juuri", 1]
    end
  end

end