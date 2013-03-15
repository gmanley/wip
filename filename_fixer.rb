require 'unicode'

require 'fileutils'
require 'find'
require 'pathname'

PATH = '/mnt/NAS/Videos/K-Pop/To Be Organized'

DRY_RUN = false

module FileTools

  def self.safe_rename(path, new_name)
    path = File.expand_path(path)
    target = File.join(File.dirname(path), new_name)

    original_name = File.basename(path)

    unless File.exist?(target) || original_name == new_name
      puts "Renaming #{original_name} to #{new_name}"
      FileUtils.mv(path, target) unless DRY_RUN
    else
      # puts "skipping #{path.inspect} because #{target.inspect} already exists or is the same."
    end
  rescue => e
    puts "Rescued #{e.message}"
  end
end

Find.find(PATH) do |path|
  normalized_name = Unicode.nfkc(File.basename(path))
  FileTools.safe_rename(path, normalized_name)
end