task :add_sukutaulut do
  require 'roo'

  ods = Roo::Spreadsheet.open('./source/sukutaulukko.ods')
  sheet = ods.sheet('Suku')

  headers = Hash.new
  sheet.row(1).each_with_index { |header, i|
    headers[header] = i
  }

  sheet.each_with_index { |row, i|
    unless i == 0
      table = row[headers['Taulu']]
      add_table_if_needed(table, row, headers)
    end
  }

  # Dir.glob("./source/suku/*") do |file|
  #   # p file
  #   break
  # end

  # Dir.glob("./source/suku/*.WMA") {|file|
  #
  # }

end

def make_sure_table_exists(table, filename)
  files = Dir.glob(filename)
  found = false

  if files.count > 0
    found = true
  else
    files = Dir.glob("./source/suku/#{table}*")
    if files.count > 0
      file = files.first
      check_table = file.split('/').last.split('-').first.split('.').first
      if table.eql?(check_table)
        p "#{table} Renaming: #{file} to #{filename}"
        File.rename(file, filename)
        found = true
      end
    end
  end

  unless found
    p "#{table} Does not have file, creating #{filename}"
    out_file = File.new(filename, "w")
    out_file.puts("---")
    out_file.puts("---")
    out_file.close
  end

  found
end

def current_frontmatter_value_for(matter_key, front_array)
  value = front_array.find { |e| /#{matter_key.downcase}/ =~ e }
end

def add_to_frontmatter(front_array, matter_row)
  front_array.insert(front_array.count-1, matter_row)
end

def replace_in_frontmatter(old_value, new_value, front_array)
  front_array.map! { |x| x.include?(old_value) ? new_value : x }
end

def hash_keys_by_value(hash)
  hash.keys.sort.reverse { |a, b| hash[b] <=> hash[a] }
end

def update_frontmatter(row, frontmatter_data, headers)
  changes = false
  frontmatter = ''
  if frontmatter_data
    front_array = frontmatter_data[0].split(/\n/)
    matter_keys = hash_keys_by_value headers
    matter_keys.each do |matter_key|
      value = row[headers[matter_key]]

      if value.class == Date
        value = value.strftime("%d.%m.%Y")
      end

      matter_row = sprintf "%s: %s", matter_key.downcase, value
      unless front_array.include?(matter_row)
        value = current_frontmatter_value_for(matter_key, front_array)
        if value.nil?
          add_to_frontmatter(front_array, matter_row)
        else
          replace_in_frontmatter(value, matter_row, front_array)
        end
        changes = true
      end
    end
    frontmatter = front_array.join("\n")
  end
  return changes, frontmatter
end

def add_table_if_needed(table, row, headers)
  key = get_file_key(row, headers)

  dir = './source/suku/'
  appendix = '.html.markdown.erb'
  filename = sprintf "%s%s%s", dir, key, appendix
  make_sure_table_exists(table, filename)

  text = File.read(filename)

  frontmatter_data = text.match /---(.|\n)*---/
  changes, frontmatter = update_frontmatter(row, frontmatter_data, headers)

  if changes

    new_contents = text.gsub(/---(.|\n)*---/, frontmatter)
    # puts new_contents
    File.open(filename, "w") { |file| file.puts new_contents }
  end
end

def get_file_key(row, headers)
  taulu = row[headers['Taulu']]
  raw_etunimet = row[headers['Etunimet']]
  raw_sukunimi = row[headers['Sukunimi']]

  etunimet = normalize_name raw_etunimet
  sukunimi = normalize_name raw_sukunimi

  if sukunimi
    key = sprintf "%s-%s-%s", taulu, sukunimi, etunimet
  else
    key = sprintf "%s-%s", taulu, sukunimi, etunimet
  end
  key
end

def normalize_name(name)
  result = nil
  if name
    # The monster line below removes any characters that cant be shown
    # and normalizes scandinavian chars
    result = name.gsub(/ä/, 'a').
        gsub(/å/, 'a').gsub(/ö/,'o').gsub(/Å/,'A').gsub(/Ä/,'A').gsub(/Ö/,'O').
        gsub(/\W\-/, "").downcase.tr(" ", "-")
  end
  result
end