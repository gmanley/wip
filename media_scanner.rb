require 'bundler/setup'
Bundler.require(:default, :media_scanner)
require 'digest/sha1'
require 'pathname'

class Scanner
  VIDEO_EXTENSIONS = ['3gp', 'asf', 'asx', 'avc', 'avi', 'avs', 'bin', 'bivx', 'bup', 'divx', 'dv', 'dvr-ms', 'evo', 'fli', 'flv', 'ifo', 'img',
                      'iso', 'm2t', 'm2ts', 'm2v', 'm4v', 'mkv', 'mov', 'mp4', 'mpeg', 'mpg', 'mts', 'nrg', 'nsv', 'nuv', 'ogm', 'ogv',
                      'pva', 'qt', 'rm', 'rmvb', 'sdp', 'svq3', 'strm', 'ts', 'tp', 'ty', 'vdr', 'viv', 'vob', 'vp3', 'wmv', 'wpl', 'xsp', 'xvid']

  def initialize(path)
    @scan_path = Pathname.new(path)
    read_contents
  end

  def read_contents
    media = []
    @scan_path.find do |file_path|
      if VIDEO_EXTENSIONS.include?(file_path.extname.gsub('.', ''))

        begin
          media_info = Mediainfo.new(file_path)
        rescue Exception => e
          puts "Error: #{e}"
          puts "Can't parse #{file_path}"
          next
        end

        media_info_hash = media_info.to_h
        media_info_hash.delete_if {|k,v| key == :menu}
        media_info_hash.each do |k,v|
          if v.is_a?(Array)
            if v.size > 1
              stream_widths = []
              v.each do |stream|
                stream_widths << stream[:width].to_i
              end
              if stream_widths.first > stream_widths.last
                stream_widths.first
              elsif stream_widths.last > stream_widths.first
                stream_widths.last
              else
                puts "Files with more than 3 streams of one type aren't supported yet!"
              end
            else

            end
          end
        end

        sha = Digest::SHA1.new(file_path).to_s
        info = {:name => file_path.basename, :path => file_path.to_s, :info => media_info_hash, :hash => sha}
        raise info.inspect
      end
    end
  end
end


Scanner.new("/Volumes/G-Raid/Videos/SNSD/Performances")
