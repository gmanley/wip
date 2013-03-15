require 'spec_helper'

DRY_RUN = true

describe VideoScanner do

  before do
    @scanner = VideoScanner.new('/Volumes/G-Raid/Videos')
    create_fs_seeds(load_fixture('files.yml'))
  end

  describe '#video_files' do

    it 'should be a array' do
      binding.pry
      @scanner.video_files.should be_kind_of(Array)
    end
  end
end
