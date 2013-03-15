%[]


require 'find'
root_path = '/Volumes/G-Raid/Videos/SNSD/Misc.'

files = Find.find(root_path).find_all { |path| File.file?(path) }

files.each do |file_path|


end
