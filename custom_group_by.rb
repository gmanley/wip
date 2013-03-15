require 'rspec'

class Array

  def custom_group_by(&block)
    results = {}

    each do |e|
      (results[block.call(e)] ||= []) << e
    end

    results
  end
end

describe Array do
  let(:array) { ['a', 2, :blah, 3, 'b'] }

  describe '#custom_group_by' do

    it 'groups elements in a hash by the result of the given block' do
      grouped_hash = array.custom_group_by { |e| e.class.name.downcase.to_sym }
      expect(grouped_hash).to eql({
        symbol: [:blah],
        string: ['a', 'b'],
        fixnum: [2, 3]
      })
    end
  end
end
