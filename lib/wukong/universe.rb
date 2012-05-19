module Wukong

  #
  # Holds graphs, supplies `processor` and similar stage template methods
  #
  module Universe
    def find_or_create_class(superklass, klass_name, namespace, &block)
      klass_name = Gorillib::Inflector.camelize(klass_name.to_s).to_sym
      if namespace.const_defined?(klass_name)
        namespace.const_get(klass_name)
      else
        namespace.send(:const_set, klass_name, Class.new(superklass, &block))
      end
    end

    def processor(processor_name, &block)
      klass = find_or_create_class(Wukong::Processor, processor_name, Wukong::Widget) do
        register_processor(processor_name)
      end
      klass.class_eval(&block) if block_given?
      klass
    end

    def dataflow(name=nil, attrs={}, &block)
      attrs[:name] ||= name || Gorillib::Inflector.underscore(self.name)
      @dataflow ||= Dataflow.new(attrs, &block)
    end
  end

  # Wukong can serve as a universe
  extend Universe
end
