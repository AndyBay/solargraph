module Solargraph
  class YardMap::Cache
    def initialize
      @constants = {}
      @methods = {}
      @instance_methods = {}
    end

    def set_constants namespace, scope, suggestions
      @constants[[namespace, scope]] = suggestions
    end

    def set_methods namespace, scope, visibility, suggestions
      @methods[[namespace, scope, visibility]] = suggestions
    end

    def set_instance_methods namespace, scope, visibility, suggestions
      @instance_methods[[namespace, scope, visibility]] = suggestions
    end

    def get_methods namespace, scope, visibility
      @methods[[namespace, scope, visibility]]
    end

    def get_instance_methods namespace, scope, visibility
      @instance_methods[[namespace, scope, visibility]]
    end

    def get_constants namespace, scope
      @constants[[namespace, scope]]
    end
  end
end
