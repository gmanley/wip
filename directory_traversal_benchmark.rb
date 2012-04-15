#!/usr/bin/env ruby
# encoding: UTF-8
require "benchmark"
require 'digest/sha1'
require 'digest/sha2'
require 'digest/md5'

ROOT_PATH = ARGV[0]

Benchmark.bmbm do |x|
  x.report("SHA1") do
    albums = []
    gallery_root_children = Dir["#{ROOT_PATH}/*"]
    gallery_root_children.each do |gallery_child|
      if File.directory?(gallery_child)
        album = {}
        album[:path] = gallery_child
        album[:name] = File.basename(gallery_child)
        album[:images] = []
        album_children = Dir["#{gallery_child}/*"]
        album_children.each do |album_child|
          image = {}
          image[:path] = album_child
          image[:name] = File.basename(album_child)
          image[:sha] = Digest::SHA1.file(album_child).to_s
          album[:images] << image
        end
        albums << album
      end
    end
  end

  x.report("MD5") do
    albums = []
    gallery_root_children = Dir["#{ROOT_PATH}/*"]
    gallery_root_children.each do |gallery_child|
      if File.directory?(gallery_child)
        album = {}
        album[:path] = gallery_child
        album[:name] = File.basename(gallery_child)
        album[:images] = []
        album_children = Dir["#{gallery_child}/*"]
        album_children.each do |album_child|
          image = {}
          image[:path] = album_child
          image[:name] = File.basename(album_child)
          image[:sha] = Digest::MD5.file(album_child).to_s
          album[:images] << image
        end
        albums << album
      end
    end
  end

  x.report("SHA2") do
    albums = []
    gallery_root_children = Dir["#{ROOT_PATH}/*"]
    gallery_root_children.each do |gallery_child|
      if File.directory?(gallery_child)
        album = {}
        album[:path] = gallery_child
        album[:name] = File.basename(gallery_child)
        album[:images] = []
        album_children = Dir["#{gallery_child}/*"]
        album_children.each do |album_child|
          image = {}
          image[:path] = album_child
          image[:name] = File.basename(album_child)
          image[:sha] = Digest::SHA2.file(album_child).to_s
          album[:images] << image
        end
        albums << album
      end
    end
  end
end