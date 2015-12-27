module CustomHelpers

  def esivanhemmat(taulu)
    owner = puulinkki taulu
    search_name = search_name_from_table taulu
    parent_data = []
    parents = parents search_name
    parents.each do |parent|
      parent_data << esivanhemmat(parent)
    end
    if parent_data.length > 1
      result = sprintf("<table><tr><td rowspan='2'>%s</td><td>%s</td></tr><tr><td>%s</td></tr></table>",
                       owner, parent_data[0], parent_data[1])
    else
      result = sprintf("<table><tr><td>%s</td><td>%s</td></tr></table>",
                       owner, parent_data[0])
    end
    result
  end

  def jalkelaiset(taulu)
    owner = puulinkki taulu
    search_name = search_name_from_table taulu
    data = []
    article = find_article_by_name search_name
    if article
      child_list = children article
      child_list.each do |child|
        data << jalkelaiset(child)
      end
      if data.length > 1
        result = sprintf("<table><tr><td>%s</td><td rowspan='2'>%s</td></tr><tr><td>%s</td></tr></table>",
                         data[0], owner, data[1])
      else
        result = sprintf("<table><tr><td>%s</td><td>%s</td></tr></table>",
                         data[0], owner)
      end
    end
    result
  end

  def search_name_from_table(table_id)
    result = table_id

    name_without_id = drop_table_id table_id
    if name_without_id.length == 0

      sitemap.resources.each do |article|
        if article.data.taulu == table_id
          result = search_name article
          break
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

    if name_has_numbers?(name_or_id)
      id = find_table(name_or_id)
      article = find_person_by_id id
    else
      article = find_person_by_name name_or_id
    end

    if article
      text = "#{article.data.etunimet} #{article.data.sukunimi}"
      link = link_to text, article
      result = sprintf("%s<br>%s<br>%s", article.data.taulu, link, article.data.syntyi)
    end

    result
  end

  def nimilinkki(name_or_id, text=nil)
    result = text || name_or_id

    if name_has_numbers?(name_or_id)
      id = find_table(name_or_id)
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
    name_parts = name.split(' ')
    surname = name_parts.last
    if name_has_numbers?(surname)
      name_parts = name_parts.reverse.drop(1).reverse
    end
    name_parts.join(' ')
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