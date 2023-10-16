module Cove
  class DeploymentConfigPathBuilder
    def initialize(parent = nil)
      @parent = parent
    end

    def set(path)
      @path = path
    end

    def get
      if @parent
        File.join(@parent.get, @path)
      else
        @path
      end
    end

    def append(path)
      self.class.new(self).set(path)
    end
  end
end
