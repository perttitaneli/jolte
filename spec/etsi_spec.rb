require_relative '../koodi/etsi'

describe Etsi do

  describe '::poista_erikoismerkit' do

    it 'Osaa poistaa kauttaviivat' do
      nimi = Etsi.poista_erikoismerkit 'Justiina/Kristiina'
      expect(nimi).to eq "justiinakristiina"
    end

    it 'osaa poistaa muitakin erikoismerkkejä' do
      nimi = Etsi.poista_erikoismerkit "Erkki D'Incau ? & Veljet"
      expect(nimi).to eq "erkki-dincau-veljet"
    end
  end

end