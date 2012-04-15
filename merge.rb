require 'pathname'
require 'fileutils'
require 'securerandom'

def safe_file_copy(location, destination)
  if File.exist?(destination)
    unless FileUtils.identical?(location, destination)
      destination = "#{destination}_#{SecureRandom.hex}"
      FileUtils.cp_r(location, destination)
    end
  else
    FileUtils.cp_r(location, destination)
  end
end

folders = ["/Volumes/G-Raid/Soshi Pics/To Be Organized/LG 3D Festival batch", "/Volumes/G-Raid/Soshi Pics/To Be Organized/110403LG 3D Festival"]
dest = "/Volumes/G-Raid/Soshi Pics/To Be Organized/LG 3D Festival batch new"
Dir.mkdir(dest) unless File.directory?(dest)
folders.collect!{|folder| Pathname.new(folder)}
children_folders = {}
folders.each do |folder|
  folder.each_child do |child|
    if child.directory?
      children_folders[child.to_s] = child.basename.to_s
    else
      new_file_location = File.join(dest, File.basename(child))
      safe_file_copy(child, new_file_location)
    end
  end
end

children_folders.each do |k, v|
  children_folders.delete(k)
  if children_folders.has_value?(v)
    folder = Pathname.new(children_folders.rassoc(v).first)
    dup_folder = Pathname.new(k)
    children = folder.children + dup_folder.children
    children.each do |child|
      new_folder = File.join(dest, v)
      Dir.mkdir(new_folder) unless File.directory?(new_folder)
      new_file_location = File.join(new_folder, File.basename(child))
      safe_file_copy(child, new_file_location)
    end
  end
  folder = Pathname.new(k)
  folder.each_child do |child|
    new_folder = File.join(dest, v)
    Dir.mkdir(new_folder) unless File.directory?(new_folder)
    new_file_location = File.join(new_folder, File.basename(child))
    safe_file_copy(child, new_file_location)
  end
end