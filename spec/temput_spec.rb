require_relative '../koodi/temput'
require_relative 'artikkeli'

describe Temput do

  let!(:maija) { Artikkeli.luo koodi: 'A1', etunimi: 'Maija', sukunimi: 'Poppanen' }
  let(:testaa) { Class.new { extend Temput } }
  let!(:etsi) { etsi = Etsi.new([maija]) }

  before do
    allow(Etsi).to receive(:aseta).and_return(etsi)
    allow(testaa).to receive(:sivukartta).and_return([maija])
  end

  describe 'henkilötiedot' do
    it 'palauttaa henkilön tiedot' do
      tiedot = testaa.henkilötiedot maija
      expect(tiedot).to eq "A1 Maija Poppanen s.syntymäaika Tampere"
    end
  end

  describe 'nimilinkki' do
    it 'tekee linkin pelkällä nimellä' do
      expect(testaa).to receive(:luo_linkki).with('Maija Poppanen', maija)
      testaa.nimilinkki "Maija A1"
    end
  end
end