require 'rspec'
require 'extensions'

describe Array do
  before do
    @array = [1, 2, 3, 4, 5, 6]
  end

  it 'should implement rest function' do
    @array.rest.should == [2, 3, 4, 5, 6]
  end

  it 'should implement middle function' do
    @array.middle.should == [2, 3, 4, 5]
  end
end
