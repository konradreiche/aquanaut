require 'spec_helper'
require 'aquanaut'

describe Aquanaut::Worker do
  describe "#initialize" do
    it "initializes the queue with the target address" do
      target = 'http://www.example.com'
      worker = Aquanaut::Worker.new(target)

      queue = worker.instance_variable_get('@queue')
      expected_queue = [URI.parse(target)]
      expect(queue).to eq(expected_queue)
    end
  end
end
