module CustomHelpers

  def sukutaulu?(article)
    article.path.include?('suku/')
  end

  def esivanhemmat(taulu)
    result = nil
    if taulu
      article = find_person_by_id taulu
      unless article
        article = find_person_by_name taulu
      end

      if article
        name = search_name article

        pa = father name
        ma = mother name

        mother_data = esivanhemmat(ma)
        father_data = esivanhemmat(pa)

        data = ['<table><tr>']
        owner = tree_link_from_article(article)
        if is_a_woman? article
          data << sprintf("<td rowspan='2' id='mom'>%s</td>", owner)
        else
          data << sprintf("<td rowspan='2'>%s</td>", owner)
        end
        data << sprintf("<td>%s</td></tr><tr><td id='mom'>%s</td>",
                        father_data, mother_data)
        data << '</tr></table>'
        result = data.join('')
      end
    end
    result
  end

  def jalkelaiset(taulu)
    owner = puulinkki taulu
    search_name = full_search_name taulu
    data = []
    article = find_article_by_name search_name
    if article
      child_list = children article
      index = 0
      child_list.each do |child|
        if index == 0
          data << "<td>#{jalkelaiset(child)}</td>"
          # data << "<td>#{child}</td>"
        else
          data << "<tr><td>#{jalkelaiset(child)}</td></tr>"
          # data << "<tr><td>#{(child)}</td></tr>"
        end
        index += 1
      end

      if data.length > 0
        result = sprintf("<table><tr>%s<td rowspan='%s'>%s</td></tr>%s</table>",
                         data[0], data.length, owner, data.drop(1).join(''))
      end
    end
    result
  end

  def full_search_name(table_id)
    result = table_id
    if table_id
      name_without_id = drop_table_id table_id
      if name_without_id.length == 0

        sitemap.resources.each do |article|
          if article.data.taulu == table_id
            result = search_name article
            break
          end
        end
      end
    end
    result
  end

  def search_name(article)
    sprintf "%s %s %s", article.data.etunimet, article.data.sukunimi, article.data.taulu
  end

  def vanhemmat(current_page)
    name = search_name current_page
    parents(name)
  end

  def father(search_name)
    result = nil

    sukutaulut.each do |article|
      unless is_a_woman?(article)
        child_list = children article
        child_list.each do |child|
          if is_same_person_s(search_name, child)
            result = search_name(article)
            break
          end
        end
      end
    end
    result
  end

  def sukutaulut
    taulut = []
    sitemap.resources.each do |article|
      if sukutaulu? article
        taulut << article
      end
    end
    taulut
  end

  def mother(search_name)
    result = nil

    sukutaulut.each do |article|
      if is_a_woman?(article)
        child_list = children article
        child_list.each do |child|
          if is_same_person_s(search_name, child)
            result = search_name(article)
            break
          end
        end
      end
    end
    result
  end

  def is_a_woman?(article)
    sukupuoli = article.data.sukupuoli
    'n'.eql?(sukupuoli) || 'N'.eql?(sukupuoli)
  end

  def parents(search_name)
    result = []

    sitemap.resources.each do |article|

      child_list = children article
      child_list.each do |child|
        if is_same_person_s(search_name, child)
          result << search_name(article)
        end
      end
    end

    result
  end

  def children(article)
    child_list = []
    list = article.data.lapset
    if list
      child_list = list.split(',')
    end
    child_list
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

  def is_same_person(name_on_file, search_article)
    if name_has_numbers?(name_on_file)
      id = find_table(name_on_file)
      result = id == search_article.data.id
    else
      result = does_article_belong_to? name_on_file, search_article
    end
    result
  end

  def is_same_person_s(search_name, name_on_file)
    if name_has_numbers?(name_on_file) && name_has_numbers?(search_name)
      id = find_table(name_on_file)
      search_id = find_table search_name
      result = id == search_id
    elsif name_has_numbers?(search_name)
      search_name = drop_table_id search_name
      result = names_match search_name, name_on_file
    else
      result = names_match search_name, name_on_file
    end

    result
  end

  def person_link(article)
    official_name = sprintf "%s, %s", article.data.sukunimi, article.data.etunimet
    link = link_to official_name, article
    if article.data.syntyi
      text = sprintf "%s s. %s", link, article.data.syntyi
    else
      text = link
    end
    text
  end

  def puulinkki(name_or_id)
    result = name_or_id
    article = article_by_name_or_id(name_or_id)

    if article
      result = tree_link_from_article(article)
    end

    result
  end

  def tree_link_from_article(article)
    text = "#{article.data.etunimet} #{article.data.sukunimi}"
    link = link_to text, article
    result = sprintf("%s<br>%s<br>%s", article.data.taulu, link, article.data.syntyi)
  end

  def taululinkki(name_or_id, text=nil)
    result = text || name_or_id

    article = article_by_name_or_id(name_or_id)

    if article
      if text.nil?
        text = sprintf("%s %s", article.data.etunimet, article.data.sukunimi)
      end

      result = sprintf "%s %s", link_to(text, article), article.data.syntyi
    end

    result
  end

  def nimilinkki(name_or_id, text=nil)
    result = text || name_or_id

    article = article_by_name_or_id(name_or_id)

    if article
      if text.nil?
        text = "#{article.data.etunimet} #{article.data.sukunimi}"
      end

      result = link_to text, article
    end

    result
  end

  def article_by_name_or_id(name_or_id)
    if name_has_numbers?(name_or_id)
      id = find_table(name_or_id)
      article = find_person_by_id id
    else
      article = find_person_by_name name_or_id
    end
    article
  end

  def find_table(name_string)
    result = nil
    parts = name_string.split(' ')
    parts.each do |name_or_id|
      if name_has_numbers?(name_or_id)
        result = name_or_id
        break
      end
    end
    result
  end

  def name_has_numbers?(name_or_id)
    name_or_id =~ /\d/
  end

  def drop_table_id(name)
    result = nil
    if name
      name_parts = name.split(' ')
      surname = name_parts.last
      if name_has_numbers?(surname)
        name_parts = name_parts.reverse.drop(1).reverse
      end
      result = name_parts.join(' ')
    end
    result
  end

  def names_match(search_name, name_on_file)
    result = false
    name_parts = search_name.split(' ')
    search_surname = name_parts.last

    file_name_parts = name_on_file.split(' ')
    surname = file_name_parts.last

    if surname == search_surname
      search_first_names = name_parts.reverse.drop(1).reverse
      first_names = file_name_parts.reverse.drop(1).reverse

      all_found = true
      search_first_names.each do |etunimi|
        unless first_names.include?(etunimi)
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

  def does_article_belong_to?(name, article)
    result = false

    if name_has_numbers?(name)
      name = drop_table_id name
    end

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

  def find_article_by_name(name)
    find_person_by_name name
  end

  def find_person_by_name(name)
    result = nil
    if name
      sitemap.resources.each do |article|

        if does_article_belong_to?(name, article)
          result = article
          break
        end
      end
    end
    result
  end

  def find_person_by_id(id)
    result = nil
    sitemap.resources.each do |article|

      art_id = article.data.taulu
      if art_id == id
        result = article
        break
      end
    end
    result
  end

end