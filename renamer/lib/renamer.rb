# encoding: UTF-8

require 'bundler/setup'
Bundler.require(:default)

require 'date'
require 'fileutils'
require 'find'
require 'pathname'

require 'file_tools'

VIDEO_EXTENSIONS = ['.3gp', '.asf', '.asx', '.avi', '.flv', '.iso', '.m2t', '.m2ts', '.m2v', '.m4v',
                    '.mkv', '.mov', '.mp4', '.mpeg', '.mpg', '.mts', '.ts', '.tp', '.trp', '.vob', '.wmv', '.swf']

# NUMERAL_DATE_REGEX = /((20)?(07|08|09|10|11|12))(\.|\-|\/)?(0[1-9]|1[012])(\.|\-|\/)?(0[1-9]|[12][0-9]|3[01])/

year = /(?<year>(20)?(07|08|09|10|11|12|13))/
month = /(?<month>0[1-9]|1[012])/
day = /(?<day>0[1-9]|\.[1-9]|[12][0-9]|3[01])/
NUMERAL_DATE_REGEX = /#{year}(?<separator>\.|\-|\/|_)?#{month}(\k<separator>)?#{day}/

HANGUL_DATE_REGEX = /\[(\p{Hangul}+)\.(\p{Hangul}+)\.(\p{Hangul}+)\]/
HANGUL_DATE_TO_NUMERAL = YAML.load_file(File.expand_path('../data/hangul_dates.yml', __FILE__))
EVENT_NAMES = YAML.load_file(File.expand_path('../data/events.yml', __FILE__))

class FilenameParser

  attr_reader :file_name, :replacements

  def initialize(file_name)
    @file_name = file_name
    @replacements = {}
  end

  def parse_normalized_date
    hangul_date || numeral_date
  end

  def hangul_date
    if match = HANGUL_DATE_REGEX.match(file_name)
      original_date, hangul_year, hangul_month, hangul_day = match.to_a
      date = Date.civil(HANGUL_DATE_TO_NUMERAL['year'][hangul_year],
        HANGUL_DATE_TO_NUMERAL['month'][hangul_month],
        HANGUL_DATE_TO_NUMERAL['day'][hangul_day]
      )

      replacements[match.to_s] = date.strftime("[%y.%m.%d]")
    end
  end

  def numeral_date
    if match = NUMERAL_DATE_REGEX.match(file_name)
      date = Date.civil(match[:year].to_i, match[:month].to_i, match[:day].to_i)

      replacements[match.to_s] = date.strftime("[%y.%m.%d]")
    end
  end

  def normalized_event
    EVENT_NAMES.find do |normalized_event, possible_events|
      possible_events.any? { |possible_event| @file_name.include?(@original_event = possible_event) }
    end.first
  end
end

class Renamer
  attr_accessor :new_name, :name

  def initialize(path, new_name = nil)
    @path = Pathname(path)
    @name = Unicode.nfkc(@path.basename.to_s) # http://en.wikipedia.org/wiki/Compatibility_decomposition#Normalization
    @new_name = new_name
  end

  def parser
    @parser ||= FilenameParser.new(@name)
  end

  def no_change?
    @name.eql?(@new_name)
  end

  def rename!
    unless no_change?
      # FileTools.safe_move(@path.to_s, @path.dirname.join(@new_name).to_s)
    end
  end
end

class VideoScanner

  def initialize(path)
    @path = path
  end

  def video_files
    Find.find(@path).find_all do |path|
      FileTest.file?(path) && VIDEO_EXTENSIONS.include?(File.extname(path).downcase)
    end
  end

  def rename!
    renames = 0
    video_files.each do |f|
      renamer = Renamer.new(f)
      file_name = renamer.name
      parsed_video = renamer.parser

      if parsed_video.normalized_date
        new_file_name = "[#{parsed_video.normalized_date}] #{file_name.gsub(parsed_video.original_date.to_s, '')}"
      else
        new_file_name = parsed_video.file_name
      end

      renamer.new_name = new_file_name#.gsub(/\.tp$/, '.ts').gsub(/(\[\]|\(\))/, '').gsub('  ', ' ').gsub('SBS SBS', 'SBS')

      unless renamer.no_change?
        renamer.rename!
        renames += 1
      end
    end

    puts "#{@renames} total renames!"
  end
end
