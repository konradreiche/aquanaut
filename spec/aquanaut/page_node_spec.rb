require 'aquanaut'
require 'spec_helper'

describe Aquanaut::PageNode do

  describe "#initialize" do
    it "stores the URI" do
      uri = URI.parse('http://www.example.com')
      node = Aquanaut::PageNode.new(uri)
      expect(node.uri).to eq(uri)
    end
  end

end
