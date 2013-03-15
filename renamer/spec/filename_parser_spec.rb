require 'spec_helper'

DRY_RUN = true

describe FilenameParser do

  describe '#numeral_date' do

    it 'parses numeral dates from filename' do
      parser = FilenameParser.new('120515 Mnet Japan MCD BS - TTS [GBSHD].ts')
      parser.numeral_date.should eql('[12.05.15]')
    end
  end
end
