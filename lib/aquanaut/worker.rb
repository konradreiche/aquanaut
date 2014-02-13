class Aquanaut::Worker

  def initialize(target)
    @queue = [URI.parse(target)]
  end

end
