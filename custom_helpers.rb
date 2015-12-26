module CustomHelpers

  def vanhemmat(current_page)
    result = []

    sitemap.resources.each do |article|

      lapset = article.data.lapset
      if lapset
        list = lapset.split(',')
        list.each do |child|
          if is_same_person(child, current_page)
            result << article.data.id
          end
        end
      end
    end

    result
  end

  def tarinan_ihmiset(current_page)
    result = []

    sitemap.resources.each do |article|

      lapset = article.data.lapset
      if lapset
        list = lapset.split(',')
        list.each do |child|
          if is_same_person(child, current_page)
            result << article.data.id
          end
        end
      end
    end

    result
  end

  def tarinat(current_page)
    result = []

    sitemap.resources.each do |article|

      persons = article.data.henkilöt
      if persons
        list = persons.split(',')
        list.each do |person|
          if is_same_person(person, current_page)
            result << article
          end
        end
      end
    end

    result
  end

  def is_same_person(name_string, article)
    if name_string =~ /\d/
      id = find_id(name_string)
      result = id == article.data.id
    else
      result = does_article_belong_to? name_string, article
    end
    result
  end

  def nimilinkki(name_or_id, text=nil)
    result = text || name_or_id

    if name_or_id =~ /\d/
      id = find_id(name_or_id)
      article = find_person_by_id id
    else
      article = find_person_by_name name_or_id
    end

    if article
      if text.nil?
        text = "#{article.data.etunimet} #{article.data.sukunimi}"
      end
      result = link_to text, article
    end

    result
  end

  def find_id(name_string)
    result = nil
    parts = name_string.split(' ')
    parts.each do |name_or_id|
      if name_or_id =~ /\d/
        result = name_or_id
        break
      end
    end
    result
  end

  def does_article_belong_to?(name, article)
    result = false
    name_parts = name.split(' ')
    surname = name_parts.last
    first_names = name_parts.reverse.drop(1).reverse
    last_name = article.data.sukunimi

    if last_name.present? && surname.eql?(last_name)
      etunimet = article.data.etunimet
      all_found = true
      first_names.each do |etunimi|
        unless etunimet.include?(etunimi)
          all_found = false
          break
        end
      end
      if all_found
        result = true
      end
    end
    result
  end

  def find_person_by_name(name)
    result = nil

    sitemap.resources.each do |article|

      if does_article_belong_to?(name, article)
        result = article
        break
      end
    end

    result
  end

  def find_person_by_id(id)
    result = nil
    sitemap.resources.each do |article|

      art_id = article.data.id
      if art_id == id
        result = article
        break
      end
    end
    result
  end

end