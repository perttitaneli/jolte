module CustomHelpers

  def taulukoodit
    koodit = []
    sitemap.resources.each do |article|
      if article.path.include?('suku/') && get_id(article)
        koodit << get_id(article)
      end
    end
    koodit.sort
  end

  def people_articles
    articles = []
    sitemap.resources.each do |article|
      if article.path.include?('suku/')
        articles << article
      end
    end
    articles
  end

  def git_link(article)
    taulu = get_id(article)
    etunimi = normalize_name(article.data.etunimi)
    sukunimi = normalize_name(article.data.sukunimi)
    repo = 'http://github.com/perttitaneli/jolte/blob/master/source/suku/'
    appendix = '.html.markdown.erb'
    if sukunimi
      key = sprintf "%s%s-%s-%s%s", repo, taulu, sukunimi, etunimi, appendix
    else
      key = sprintf "%s%s-%s%s", repo, taulu, sukunimi, etunimi, appendix
    end

    key
  end

  def normalize_name(name)
    result = nil
    if name
      # The monster line below removes any characters that cant be shown
      # and normalizes scandinavian chars
      result = name.gsub(/ä/, 'a').
          gsub(/å/, 'a').gsub(/ö/, 'o').gsub(/Å/, 'A').gsub(/Ä/, 'A').gsub(/Ö/, 'O').
          gsub(/\W\-/, "").downcase.tr(" ", "-")
    end
    result
  end

  def sukutaulu?(article)
    article.path.include?('sukupuut/')
  end

  def sukupuu_esivanhemmat(koodi)
    result = nil
    if koodi
      art = article_by_id koodi
      depth = tree_depth 0, art

      row = 0
      column = 0
      data_hash = {}

      row_data = get_row_data(data_hash, row)
      row_data[column] = [tree_link_from_article(art), depth*2]

      find_parent_table_locations(data_hash, art, depth, row, column)
      result = table_from_hash data_hash, depth
      # test this by enabling this
      # return data_hash
    end
    result
  end

  def get_row_data(data_hash, row)
    row_data = data_hash[row]
    unless row_data
      data_hash[row] = {}
      row_data = data_hash[row]
    end
    row_data
  end

  def table_from_hash(data_hash, column_count)
    # return data_hash
    data = ['<table>']
    for row in 0..(column_count*2)
      row_data = data_hash[row]
      if row_data
        data << '<tr>'
        for column in 0..column_count
          person, rowspan = row_data[column]
          if person
            if rowspan != 0
              if row == 0 && column == 0
                data << sprintf("<td rowspan='%s' class='td-align-top bold'>%s</td>", rowspan, person)
              else
                data << sprintf("<td rowspan='%s' class='td-align-top'>%s</td>", rowspan, person)
              end
            else
              data << sprintf("<td class='td-align-top'>%s</td>", person)
            end

          end
        end
        data << '</tr>'
      end
    end
    data << '</table>'

    data.join('')
  end

  def find_parent_table_locations(data_hash, art, depth, row, column)
    current_depth = depth-1
    current_column = column+1

    father_code = father_id art
    dad_art = article_by_id father_code
    if dad_art
      row_data = get_row_data(data_hash, row)
      row_data[current_column] = [tree_link_from_article(dad_art), current_depth*2]
      find_parent_table_locations data_hash, dad_art, current_depth,
                                  row, current_column
    end

    mother_code = mom_id art

    mom_art = article_by_id mother_code
    if mom_art
      if current_depth == 0
        mom_depth = 1
      else
        mom_depth = current_depth*2
      end
      mom_row = row + mom_depth
      mom_row_data = get_row_data(data_hash, mom_row)
      person = tree_link_from_article(mom_art)
      mom_row_data[current_column] = [person, current_depth*2]
      find_parent_table_locations data_hash, mom_art, current_depth,
                                  mom_row, current_column
    end

  end

  def tree_depth(current_depth, art)
    father_code = father_id art
    mother_code = mom_id art

    depth = current_depth+1

    mom_art = article_by_id mother_code
    mother_depth = current_depth
    if mom_art
      mother_depth = tree_depth(depth, mom_art)
    end

    dad_art = article_by_id father_code
    dad_depth = current_depth
    if mom_art
      dad_depth = tree_depth(depth, dad_art)
    end

    if mother_depth > dad_depth
      depth = mother_depth
    else
      depth = dad_depth
    end
    depth
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
          if get_id(article) == table_id
            result = search_name article
            break
          end
        end
      end
    end
    result
  end

  def search_name(article)
    sprintf "%s %s %s", article.data.etunimi, article.data.sukunimi, get_id(article)
  end

  def vanhemmat(current_page)
    name = search_name current_page
    parents(name)
  end

  def father_id(article)
    result=nil
    if article.present?
      result=article.data.try("isän koodi")
    end
    result
  end

  def mom_id(article)
    result = nil
    if article.present?
      result= article.data.try("Äidin koodi")
    end
    result
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

    # sitemap.resources.each do |article|
    #
    #   persons = article.data.henkilöt
    #   if persons
    #     list = persons.split(',')
    #     list.each do |person|
    #       if is_same_person(person, current_page)
    #         result << article
    #       end
    #     end
    #   end
    # end

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
    official_name = sprintf "%s %s", article.data.etunimi, article.data.sukunimi
    link = link_to official_name, article
    if article.data.syntymäpaikka
      text = sprintf "%s s. %s", link, article.data.syntymäpaikka
    else
      text = link
    end
    text
  end

  def artikkelilinkki(name_or_id)
    result = name_or_id
    article = article_by_name_or_id(name_or_id)

    if article
      text = "#{article.data.etunimi} #{article.data.sukunimi}"
      link = link_to text, article
      result = sprintf("%s %s s. %s", get_id(article), link, article.data.syntymäaika)
    end

    result
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
    # return article.data.etunimi
    link = link_to get_id(article), article

    start ="<div class='td-align-top'>"
    end_s = "</div>"
    sprintf("%s<span class='bold'>%s</span> %s <br>s.%s %s<br><div class='pull-right'>%s</div>%s",
            start, article.data.etunimi,
            article.data.sukunimi,
            article.data.syntymäaika,
            article.data.paikka,
            link,
            end_s)
  end

  def taululinkki(name_or_id, text=nil)
    result = text || name_or_id

    article = article_by_name_or_id(name_or_id)

    if article
      if text.nil?
        text = sprintf("%s %s", article.data.etunimi, article.data.sukunimi)
      end

      result = sprintf "%s %s", link_to(text, article), article.data.syntymäpaikka
    end

    result
  end

  def nimilinkki(name_or_id, text=nil)
    result = text || name_or_id

    article = article_by_name_or_id(name_or_id)

    if article
      if text.nil?
        text = "#{article.data.etunimi} #{article.data.sukunimi}"
      end

      result = link_to text, article
    end

    result
  end

  def kids(father_art, mom_art)
    kids = []
    father_code = get_id father_art
    mom_code = get_id mom_art
    people_articles.each do |article|
      if father_code.present? &&
          (father_code.eql? father_id(article)) &&
          mom_code.present? && (mom_code.eql? mom_id(article))
        kids << article
      end
    end

    kids
  end

  def puolisot(article)
    moms = []

    koodi = get_id(article)
    people_articles.each do |article|
      if koodi.eql? article.data.try('isän koodi')
        mom = article.data.try('Äidin koodi')
        if mom.present?
          art = article_by_id mom
          moms << (art || mom)
        end
      end
    end

    moms
  end

  def get_id(article)
    article.data.koodi
  end

  def person_info(article)
    sprintf "%s %s %s s.%s %s",
            get_id(article),
            article.data.etunimi,
            article.data.sukunimi,
            article.data.syntymäaika,
            article.data.paikka
  end

  def linkki(article)
    sprintf "%s %s %s s.%s %s",
            (link_to get_id(article), article),
            article.data.etunimi,
            article.data.sukunimi,
            article.data.syntymäaika,
            article.data.paikka
  end

  def article_by_name_or_id(name_or_id)
    if name_has_numbers?(name_or_id)
      article = article_by_id(name_or_id)
    else
      article = find_person_by_name name_or_id
    end
    article
  end

  def article_by_id(koodi)
    result = nil
    if koodi.present?
      id = find_table(koodi)
      result = find_person_by_id id
    end
    result
  end

  def find_table(name_string)
    result = nil
    if name_string.present?
      parts = name_string.split(' ')
      parts.each do |name_or_id|
        if name_has_numbers?(name_or_id)
          result = name_or_id
          break
        end
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
      etunimi = article.data.etunimi
      all_found = true
      first_names.each do |etunimi|
        unless etunimi.include?(etunimi)
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

      art_id = get_id(article)
      if art_id == id
        result = article
        break
      end
    end
    result
  end

end