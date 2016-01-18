task :add_sukutaulut do
  require_relative 'koodi/sukukortit_taulukosta'
  SukukortitTaulukosta.luo_tiedostot
end