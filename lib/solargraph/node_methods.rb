module Solargraph
  module NodeMethods
    def unpack_name(node)
      pack_name(node).join("::")
    end
    
    def pack_name(node)
      parts = []
      if node.kind_of?(AST::Node)
        node.children.each { |n|
          if n.kind_of?(AST::Node)
            if n.type == :cbase
              parts = pack_name(n)
            else
              parts += pack_name(n)
            end
          else
            parts.push n unless n.nil?
          end
        }
      end
      parts
    end

    def const_from node
      if node.kind_of?(AST::Node) and node.type == :const
        result = ''
        unless node.children[0].nil?
          result = const_from(node.children[0])
        end
        if result == ''
          result = node.children[1].to_s
        else
          result = result + '::' + node.children[1].to_s
        end
        result
      else
        nil
      end
    end

    def drill_signature node, signature
      return signature unless node.kind_of?(AST::Node)
      if node.type == :const or node.type == :cbase
        unless node.children[0].nil?
          signature += drill_signature(node.children[0], signature)
        end
        signature += '::' unless signature.empty?
        signature += node.children[1].to_s
      elsif node.type == :lvar
        signature += '.' unless signature.empty?
        signature += node.children[0].to_s
      elsif node.type == :send
        unless node.children[0].nil?
          signature += drill_signature(node.children[0], signature)
        end
        signature += '.' unless signature.empty?
        signature += node.children[1].to_s
      end
      signature
    end

    def infer node
      if node.type == :str
        return 'String'
      elsif node.type == :array
        return 'Array'
      elsif node.type == :hash
        return 'Hash'
      elsif node.type == :int
        return 'Integer'
      elsif node.type == :float
        return 'Float'
      end
      nil
    end

    # Get a call signature from a node.
    # The result should be a string in the form of a method path, e.g.,
    # String.new or variable.method.
    #
    # @return [String]
    def resolve_node_signature node
      #stack_node_signature(node).join('.')
      drill_signature node, ''
    end

    def stack_node_signature node
      parts = []
      if node.kind_of?(AST::Node)
        if node.type == :send
          unless node.children[0].nil?
            parts = [unpack_name(node.children[0])] + parts
          end
          parts += stack_node_signature(node.children[1])
        else
          parts = [unpack_name(node)] + stack_node_signature(node.children[1])
        end
      else
        parts.push node.to_s
      end
      parts
    end

    def yard_options
      if @yard_options.nil?
        @yard_options = {
          include: [],
          exclude: [],
          flags: []
        }
        unless workspace.nil?
          yardopts_file = File.join(workspace, '.yardopts')
          if File.exist?(yardopts_file)
            yardopts = File.read(yardopts_file)
            yardopts.lines.each { |line|
              arg = line.strip
              if arg.start_with?('-')
                @yard_options[:flags].push arg
              else
                @yard_options[:include].push arg
              end
            }
          end
        end
        @yard_options[:include].concat ['app/**/*.rb', 'lib/**/*.rb'] if @yard_options[:include].empty?
      end
      @yard_options
    end
  end
end
