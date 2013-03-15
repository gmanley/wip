parent_album = Album.find_by_slug('performances-2010')

Dir['/mnt/downloads/*'].each do |album_folder|
  puts "Scanning path #{album_folder}"
  album_folder_regex = /(?<title>.+)(?<date>\d{2}\.\d{2}\.\d{4}$)/
  match = album_folder_regex.match(File.basename(album_folder))
  title = match[:title].strip
  date = Date.strptime(match[:date], '%m.%d.%Y')
  album = parent_album.children.create(title: title, event_date: date)
  puts "Created album with title: #{title} & event_date: #{date}."

  Dir[album_folder + '/*'].each do |source_folder|
    source_name = File.basename(source_folder).gsub(/\s\d+$/, '')
    puts "Scanning source #{source_name}."
    source = Source.find_or_create_by_name(source_name)
    allowed_exts = ImageUploader::EXTENSION_WHITE_LIST
    glob_pattern = "#{source_folder}/*.{#{allowed_exts.join(',')}}"

    Dir[glob_pattern].each do |file|
      puts "Adding #{file}"
      image = album.images.new(image: File.open(file))
      image.source_id = source.id
      image.save
    end
  end
end

parent_album = Album.find_by_slug('performances-2010')

Dir['/mnt/downloads/new/*'].each do |album_folder|
  puts "Scanning path #{album_folder}"
  album_folder_regex = /(?<title>.+)(?<date>\d{2}\.\d{2}\.\d{4}$)/
  match = album_folder_regex.match(File.basename(album_folder))
  title = match[:title].strip
  date = Date.strptime(match[:date], '%m.%d.%Y')

  unless album = parent_album.children.where(title: title, event_date: date).first
    parent_album.children.create(title: title, event_date: date)
    puts "Created album with title: #{title} & event_date: #{date}."
  end

  allowed_exts = ImageUploader::EXTENSION_WHITE_LIST.dup
  allowed_exts.push(*allowed_exts.map(&:upcase))
  glob_pattern = "#{album_folder}/*.{#{allowed_exts.join(',')}}"

  Dir[glob_pattern].each do |file|
    if album.images.where(image: File.basename(file)).first
      puts "Skipping #{file} it exists!"
    else
      puts "Adding #{file}"
      image = album.images.new(image: File.open(file))
      image.save
    end
  end

  Dir[album_folder + '/*'].each do |source_folder|
    glob_pattern = "#{source_folder}/*.{#{allowed_exts.join(',')}}"
    unless File.file?(source_folder)
      source_name = File.basename(source_folder).gsub(/\s\d+$/, '')
      puts "Scanning source #{source_name}."
      source = Source.find_or_create_by_name(source_name)

      Dir[glob_pattern].each do |file|
        puts "Adding #{file}"
        if album.images.where(image: File.basename(file)).first
          puts "Skipping #{file} it exists!"
        else
          puts "Adding #{file}"
          image = album.images.new(image: File.open(file))
          image.source_id = source.id
          image.save
        end
      end
    end
  end
end




# for f in ./*/*.{jpg,jpeg,gif,png}; do
#   echo $f
# done

# rm -f ./*/*.{jpg,jpeg,gif,png}

# find .  -type f | wc -l
