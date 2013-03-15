require 'bundler/setup'
Bundler.require(:default, :ipgallery_export)

require 'fileutils'
require 'pathname'
require 'cgi'

module IPGallery
  class Album
    include DataMapper::Resource

    storage_names[:default] = "gallery_albums_main"

    has n, :images
    has n, :child_albums, self.name, child_key: [:parent_id]
    belongs_to :parent_album, self.name, child_key: [:parent_id]

    property :id, Serial, field: 'album_id'
    property :title, String, field: 'album_name'
    property :description, String, field: 'album_description'
    property :parent_id, Integer, field: 'album_parent_id'
    property :is_global, Integer, field: 'album_is_global'

    def unescaped_title
       CGI.unescape_html(self.title).strip
    end
  end

  class Image
    include DataMapper::Resource

    storage_names[:default] = "gallery_images"

    belongs_to :album

    property :id, Serial
    property :category_id, Integer
    property :album_id, Integer, field: 'img_album_id'
    property :directory, String
    property :file_name, String, field: 'masked_file_name'

    def file_path(upload_root)
      File.join(upload_root, directory, file_name)
      #File.file?(path) && %w(.jpg .jpeg .gif .png).include?(File.extname(path).downcase) ? path : nil
    end
  end

  class Export

    def initialize(upload_root, destination)
      DataMapper::Logger.new(STDOUT, :warn)
      DataMapper.setup(:default, {user: 'root', password: nil, adapter: 'mysql', host: 'localhost', database: 'ipgallery'})
      @upload_root = File.expand_path(upload_root)
      @destination = File.expand_path(destination)
      FileUtils.mkdir_p(@destination)
      @options = {}
      @options.merge!(noop: true) if dry_run?
      @options.merge!(verbose: true) if verbose?
    end

    def dry_run?
      false
    end

    def verbose?
      false
    end

    def export_album(album, destination)
      FileUtils.mkdir_p(destination, @options)
      image_paths = album.images.collect {|image| image.file_path(@upload_root)}.compact
      FileUtils.cp(image_paths, destination)
    end

    def start
      root_categories = Album.all(parent_id: 0)
      progress_bar = ProgressBar.new('Gallery export', root_categories.count)
      root_categories.each do |root_category|
        root_category_folder = File.join(@destination, root_category.unescaped_title)
        FileUtils.mkdir_p(root_category_folder, @options)
        root_category.child_albums.each do |child_category|
          child_category_folder = File.join(root_category_folder, child_category.unescaped_title)
          FileUtils.mkdir_p(child_category_folder, @options)
          child_category.child_albums.each do |child_album|
            child_album_folder = File.join(child_category_folder, child_album.unescaped_title)
            export_album(child_album, child_album_folder)
          end
        end
        progress_bar.inc
      end
      progress_bar.finish
    end
  end
end

export = IPGallery::Export.new('~/Desktop/Etc./www/forums/uploads', '~/Desktop/ipgallery_export')
album = IPGallery::Album.get(2079)
export.export_album(album, File.expand_path('~/Desktop/ipgallery_export'))
# export.start
