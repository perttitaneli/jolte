module CustomHelpers
  def nimilinkki(name, text=nil)
    result = text || name
    sitemap.resources.each do |article|

      if article.data.sukunimi.present? && name.include?(article.data.sukunimi)
        etunimet = article.data.etunimet.split(' ')
        etunimet.each do |etunimi|
          if name.include?(etunimi)
            if text.nil?
              text = "#{article.data.etunimet} #{article.data.sukunimi}"
            end
            result = link_to text, article
            break
          end
        end

      end
    end

    result
  end


end