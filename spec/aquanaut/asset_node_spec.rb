require 'aquanaut'
require 'spec_helper'

describe Aquanaut::AssetNode do

  describe "#initialize" do
    it "stores the URI and type" do
      uri = URI.parse('http://www.example.com/picture.jpg')
      node = Aquanaut::AssetNode.new(uri, :image)

      expect(node.uri).to eq(uri)
      expect(node.type).to eq(:image)
    end
  end

end
