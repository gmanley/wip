require 'bundler/setup'
Bundler.require(:lister_pro_parser)

year = /(?<year>(20)?(07|08|09|10|11|12))/
month = /(?<month>0[1-9]|1[012])/
day = /(?<day>0[1-9]|[12][0-9]|3[01])/
NUMERAL_DATE_REGEX = /#{year}(?<separator>\.|\-|\/)?#{month}(\k<separator>)?#{day}/

class FileListParser

  def initialize(file_name)
    @doc = Nokogiri::HTML(File.read(File.expand_path(file_name)))
  end

  def parse!
    @doc.xpath('//tr//td[1]').collect {|file| format_file(file.text)}.uniq.join("\n")
  end

  def format_file(file_name)
    file_name = file_name.gsub(/(\d+,)?\d+\. /, '').gsub(/ \(\d\)(\.\w+)$/, '\1')
    if match = NUMERAL_DATE_REGEX.match(file_name)
      date = "#{match[:year].gsub('20', '')}.#{match[:month]}.#{match[:day]}"
      file_name.gsub(match.to_s, date)
    end
  end
end

file_name = ARGV[0]
crawl = FileListParser.new(file_name)
puts crawl.parse!

