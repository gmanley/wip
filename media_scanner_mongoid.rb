# Just a snippet can't be run standalone
require 'digest/md5'
require 'find'

module MediaManager
  class Media
    include Mongoid::Document
    include Mongoid::Timestamps

    embeds_many :thumbnails

    field :path, type: String
    field :metadata
    field :file_hash, type: String
    field :name, type: String
    field :thumbnail_url, type: String

    after_initialize :parse_metadata, :find_heuristic_hash

    VIDEO_EXTENSIONS = ['.3gp', '.asf', '.asx', '.avi', '.flv', '.iso', '.m2t', '.m2ts', '.m2v', '.m4v',
                        '.mkv', '.mov', '.mp4', '.mpeg', '.mpg', '.mts', '.ts', '.tp', '.vob', '.wmv']

    def self.scan(scan_path)
      files = Find.find(scan_path).find_all {|file_path| VIDEO_EXTENSIONS.include?(File.extname(file_path).downcase)}
      files.each {|file_path| create(path: file_path, name: File.basename(file_path))}
    end

    protected
    def parse_metadata
      begin
        self.update_attribute(:metadata, Mediainfo.new(path).to_h)
      rescue Exception => e
        self.metadata = nil
      end
    end

    # Calculates a hash for the video using a portion of the file,
    # because large videos take forever to scan. (Taken from https://github.com/mistydemeo/metadater)
    def find_heuristic_hash
      if File.size(path) < 6291456  # File is too small to seek to 5MB, so hash the whole thing
        self.file_hash = Digest::MD5.hexdigest(IO.binread(path))
      else
        self.file_hash = Digest::MD5.hexdigest(File.open(path, 'rb') { |f| f.seek 5242880; f.read 1048576 })
      end
    end
  end
end
