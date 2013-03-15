# encoding: UTF-8

require 'bundler/setup'
Bundler.require(:default, :imgur_dl)

# https://gist.github.com/1866389
# requires ruby 1.9.3 and up
# gem install nokogiri typhoeus
# require 'nokogiri'
# require 'typhoeus'

module Imgur
  class AlbumDownloader

    def initialize(album_uri)
      @album_uri = album_uri
    end

    def start
      hydra = Typhoeus::Hydra.new
      album_request = Typhoeus::Request.new(@album_uri)

      album_request.on_complete do |response|
        doc = Nokogiri::HTML(response.body)
        album_download_folder = "#{Dir.pwd}/downloads/#{File.basename(@album_uri)}"
        FileUtils.mkdir_p(album_download_folder)

        urls = doc.css('.image-hover.download a')
        img_count = 1
        img_total = urls.count

        urls.each do |img_url|
          image_request = Typhoeus::Request.new("http://imgur.com/#{img_url['href']}")
          image_request.on_complete do |response|
            file_name = response.headers_hash['content-disposition'].match(/filename=\"(.+)\"/)[1]
            File.binwrite("#{album_download_folder}/#{file_name}", response.body) # This method was added in 1.9.3
            puts "Downloaded #{img_count}/#{img_total}"
            img_count += 1
          end
          hydra.queue(image_request)
        end
      end

      hydra.queue(album_request)
      hydra.run
    end
  end
end

case ARGV.first
when '-h', '--help', '--usage', '-?', 'help', nil
  puts "Usage: ruby #{$0} imgur_album_url"
  puts "  Where 'imgur_album_url' is the imgur album you would like to download."
  puts "  Example: ruby #{$0} http://imgur.com/a/M5a2O"
  exit 0
end

downloader = Imgur::AlbumDownloader.new(ARGV[0])
downloader.start