# encoding: UTF-8
require 'bundler/setup'
Bundler.require(:default)

require 'date'
require 'fileutils'
require 'find'
require 'pathname'
require 'active_support/core_ext/string'

VIDEO_EXTENSIONS = ['.3gp', '.asf', '.asx', '.avi', '.flv', '.iso', '.m2t', '.m2ts', '.m2v', '.m4v',
                    '.mkv', '.mov', '.mp4', '.mpeg', '.mpg', '.mts', '.ts', '.tp', '.trp', '.vob', '.wmv', '.swf']

# NUMERAL_DATE_REGEX = /((20)?(07|08|09|10|11|12))(\.|\-|\/)?(0[1-9]|1[012])(\.|\-|\/)?(0[1-9]|[12][0-9]|3[01])/

year = /(?<year>(20)?(07|08|09|10|11|12|13))/
month = /(?<month>0[1-9]|1[012])/
day = /(?<day>0[1-9]|\.[1-9]|[12][0-9]|3[01])/
NUMERAL_DATE_REGEX = /#{year}(?<separator>\.|\-|\/)?#{month}(\k<separator>)?#{day}/

HANGUL_DATE_TO_NUMERAL = {
  'year' => {
    '이천십일년' => '11',
    '이천십이년' => '12',
    '이천십삼년' => '13'
  },

  'month' => {
    '일월'  => '01',  # January
    '이월'  => '02',  # Feburary
    '삼월'  => '03',  # March
    '사월'  => '04',  # April
    '오월'  => '05',  # May
    '유월'  => '06',  # June
    '칠월'  => '07',  # July
    '팔월'  => '08',  # August
    '구월'  => '09',  # September
    '시월'  => '10',  # October
    '십일월' => '11', # November
    '십이월' => '12'  # December
  },

  'day' => {
    '일일'   => '01',
    '이일'   => '02',
    '삼일'   => '03',
    '사일'   => '04',
    '오일'   => '05',
    '육일'   => '06',
    '칠일'   => '07',
    '팔일'   => '08',
    '구일'   => '09',
    '십일'   => '10',
    '십일일'  => '11',
    '십이일'  => '12',
    '십삼일'  => '13',
    '십사일'  => '14',
    '십오일'  => '15',
    '십육일'  => '16',
    '십칠일'  => '17',
    '십팔일'  => '18',
    '십구일'  => '19',
    '이십일'  => '20',
    '이십일일' => '21',
    '이십이일' => '22',
    '이십삼일' => '23',
    '이십사일' => '24',
    '이십오일' => '25',
    '이십육일' => '26',
    '이십칠일' => '27',
    '이십팔일' => '28',
    '이십구일' => '29',
    '삼십일'  => '30',
    '삼십일일' => '31'
  }
}

EVENT_NAMES = {
  "MBC Music Core" => [
    '쇼 음악중심',
    '쇼! 음악중심',
    "쇼!음악중심",
    '쇼!음악중심',
    '음악중심',
    'Music Core'
    ],

  'SBS Inkigayo' => [
    '인기가요',
    'Inkigayo',
    'Inkygayo'
  ]
}

module FileTools

  def self.safe_move(from, to)
    from = File.expand_path(from)
    to = File.expand_path(to)
    target = File.join(to, File.basename(from))

    unless File.exist?(target)
      #puts "mv #{from.inspect} #{to.inspect}"
      FileUtils.mv(from, to)
    else
      puts "skipping #{from.inspect} because #{target.inspect} already exists"
    end
  end
end

class VideoParser

  attr_reader :file, :file_name
  attr_accessor :event, :air_date, :original_date

  def initialize(file)
    @file = Pathname.new(file)
    @file_name = @file.basename.to_s.mb_chars.compose.to_s
    parse_file_name
  end

  private
  def parse_file_name
    normalize_date
    # normalize_event
  end

  def normalize_date
    if match = NUMERAL_DATE_REGEX.match(@file_name)
      @original_date = match.to_s
      @air_date = Date.parse(@original_date).strftime("%y.%m.%d")
    elsif hangul_date_match = /\[(\W+)\.(\W+)\.(\W+)\]/.match(@file_name)
      hangul_year  = hangul_date_match[1]
      hangul_month = hangul_date_match[2]
      hangul_day   = hangul_date_match[3]

      @original_date =  hangul_date_match.to_s
      @air_date = [
        (HANGUL_DATE_TO_NUMERAL['year'][hangul_year] || hangul_year),
        (HANGUL_DATE_TO_NUMERAL['month'][hangul_month] || hangul_month),
        (HANGUL_DATE_TO_NUMERAL['day'][hangul_day] || hangul_day)
      ].join('.')
    end
  rescue Exception => e
    puts "Error on file: #{@file_name} (#{e.message})"
  end

  # def normalize_event
  #   @event = EVENT_NAMES.detect {|normalized_event, possible_events| possible_events.any?{|e| @file_name.gsub!(e, normalized_event) } }
  # end
end

path = '/Volumes/NAS/Videos'
video_files = Find.find(path).find_all {|p| FileTest.file?(p) && VIDEO_EXTENSIONS.include?(File.extname(p).downcase)}
@renames = 0
video_files.each do |f|
  parsed_video = VideoParser.new(f)
  if parsed_video.air_date
    new_file_name = "[#{parsed_video.air_date}] #{parsed_video.file_name.gsub(parsed_video.original_date, "")}".gsub(/\.tp$/, '.ts').gsub(/(\[\]|\(\))/, '').gsub('  ', ' ')
    unless parsed_video.file_name.match(/^\[\d\d\.\d\d\.\d\d\]/)
      puts "---------------------------------------"
      puts "Renaming \"#{File.basename(f)}\" to \"#{new_file_name}\""
      begin
        FileTools.safe_move(f, File.join(File.dirname(f), new_file_name))
      rescue => e
       "Skipping \"#{File.basename(f)}\" #{e.message}"
      end
      # puts "FileTools.safe_move(\"#{f}\", File.join(\"#{File.dirname(f)}\", \"#{new_file_name}\"))"
      puts "---------------------------------------"
      @renames += 1
    end
  else
    # puts "---------------------------------------"
    # puts "No matches for: " << parsed_video.file_name
    # puts "---------------------------------------"
  end
end
puts "#{@renames} total renames!"
