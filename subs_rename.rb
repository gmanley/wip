# encoding: UTF-8
require 'bundler/setup'
Bundler.require(:default, :renamer)

require 'date'
require 'fileutils'
require 'find'
require 'pathname'

VIDEO_EXTENSIONS = ['.3gp', '.asf', '.asx', '.avi', '.flv', '.iso', '.m2t', '.m2ts', '.m2v', '.m4v',
                    '.mkv', '.mov', '.mp4', '.mpeg', '.mpg', '.mts', '.ts', '.tp', '.trp', '.vob', '.wmv', '.swf']


NUMERAL_DATE_REGEX = /((20)?(07|08|09|10|11|12))(\.|\-|\/)?(0[1-9]|1[012])(\.|\-|\/)?(0[1-9]|[12][0-9]|3[01])/

year = /(?<year>(20)?(07|08|09|10|11|12))/
month = /(?<month>0[1-9]|1[012])/
day = /(?<day>0[1-9]|[12][0-9]|3[01])/

NEW_NAME_FORMAT = /(\[soshi subs\])(\[2011\.#{month}\.#{day}\])/i


NUMERAL_DATE_REGEX = /#{year}(?<separator>\.|\-|\/)?#{month}(\k<separator>)?#{day}/

module FileTools

  def self.safe_move(from, to)
    from = File.expand_path(from)
    to = File.expand_path(to)
    target = File.join(to, File.basename(from))

    unless File.exist?(target)
      puts Differ.diff_by_char(File.basename(to), File.basename(from.mb_chars.compose))
      # FileUtils.mv(from, to)
    else
      puts "skipping #{from.inspect} because #{target.inspect} already exists"
    end
  end
end

class VideoParser

  attr_reader :file, :file_name
  attr_accessor :air_date, :original_date

  def initialize(file)
    @file = Pathname.new(file)
    @file_name = @file.basename.to_s
    normalize_date
  end

  private
  def normalize_date
    if match = NUMERAL_DATE_REGEX.match(@file_name)
      @original_date = match.to_s
      @air_date = Date.parse(@original_date).strftime("%Y.%m.%d")
    end
  rescue Exception => e
    puts "Error on file: #{@file_name} (#{e.message})"
  end
end

path = '/Volumes/Elements'
video_files = Find.find(path).find_all {|p| FileTest.file?(p) && VIDEO_EXTENSIONS.include?(File.extname(p).downcase)}
@renames = 0
video_files.each do |f|
  parsed_video = VideoParser.new(f)
  file_name = parsed_video.file_name

  if parsed_video.air_date
    new_file_name = file_name.gsub(parsed_video.original_date, parsed_video.air_date)
  else
    new_file_name = parsed_video.file_name
  end

  unless file_name.eql?(new_file_name)
    FileTools.safe_move(f, File.join(File.dirname(f), new_file_name))
    @renames += 1
  end
end
puts "#{@renames} total renames!"