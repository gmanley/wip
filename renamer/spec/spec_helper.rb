$:.unshift(File.expand_path('../../lib', __FILE__), File.dirname(__FILE__))
require 'renamer'
Bundler.require(:test)

module Helpers
  def path_to_fixture(name)
    File.join(File.dirname(__FILE__), 'fixtures', name)
  end

  def load_fixture(name)
    YAML.load_file(path_to_fixture(name))
  end

  def create_fs_seeds(paths)
    paths.each do |path|
      FakeFS.activate!
      FileUtils.mkdir_p(File.dirname(path))
      FileUtils.touch(path)
    end
  end
end

RSpec.configure do |config|
  config.include Helpers
end
