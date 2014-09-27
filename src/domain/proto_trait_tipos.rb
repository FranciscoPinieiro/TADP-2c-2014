module Prototyped
  attr_accessor :interested, :bloques, :atributos, :prototypes, :call_next_iteration

  def initialize
    @call_next_iteration = 0
  end

  def interested
    @interested = @interested || []
    @interested
  end

  def bloques
    @bloques = @bloques || []
    @bloques
  end

  def atributos
    @atributos = @atributos || []
    @atributos
  end

  def prototypes
    @prototypes = @prototypes || []
    @prototypes
  end

  def prototype
    @prototypes[0]
  end

  #Si se cambia un metodo en el prototipo, se tiene que reflejar el cambio en el prototipado
  def set_method (a_method, a_block)
    #Van a necesitar un Hash para poder obtener el bloque a partir del nombre del metodo
    self.bloques << [a_method,a_block]
    self.singleton_class.send(:define_method,a_method,&a_block)

    self.interested.each { |interesado|
      if !interesado.implements_own?(a_method) then
        interesado.create_proto_ref_method(a_method, self.method(a_method).arity)
      end
    }
  end

  def implements_own? (a_method)
    implementations = self.bloques.select{|method_imp| method_imp[0] == a_method}
    if implementations.size == 0 then
      return false
    else
      return true
    end
  end

  def create_proto_ref_method(a_method, arity)
    if arity == 0 then
      self.singleton_class.send(:define_method, a_method, proc do
        method_block = self.find_block_in_prototypes(a_method, self.call_next_iteration)
        result = self.instance_eval &method_block
        result
      end)
    else
      self.singleton_class.send(:define_method, a_method, proc do |args|
        method_block = self.find_block_in_prototypes(a_method, self.call_next_iteration)
        result = self.instance_exec args, &method_block
        result
      end)
    end
  end

  def create_property (a_attr, a_value)
    if !self.instance_variable_defined?("@#{a_attr}")
      self.atributos << a_attr
      self.instance_variable_set("@#{a_attr}", a_value)
      self.interested.each{|a_interested|
        if !a_interested.instance_variable_defined?("@#{a_attr}")
          a_interested.instance_variable_set("@#{a_attr}", nil)
        end
      }
    end
  end

  def create_property_accessors (a_attr)
    #getter
    if not self.respond_to?(a_attr)
      self.set_method( a_attr, Proc.new {self.instance_variable_get("@#{a_attr}") } )
    end

    #setter
    if not self.respond_to?("#{a_attr}=")
      self.set_method( "#{a_attr}=", lambda { |something| self.instance_variable_set("@#{a_attr}",something)})
    end
  end

  def set_property (a_attr, a_value)
    self.create_property(a_attr, a_value)
    self.create_property_accessors(a_attr)
  end

  def set_identifier(a_key, a_value)
    if a_value.respond_to? :call
      self.set_method(a_key, a_value)
    else
      self.set_property(a_key, a_value)
    end
  end

  def set_prototype (a_prototype)
    self.prototypes << a_prototype
    a_prototype.set_interested(self)
  end

  def set_prototypes (a_prototype_list)
    a_prototype_list.each {|a_prototype|
      set_prototype a_prototype
    }
  end

  def set_interested( a_interested)
    self.interested << a_interested
    self.atributos.each { |a_attr| a_interested.create_property(a_attr, nil)}
    self.bloques.each{|a_method|
      a_interested.create_proto_ref_method(a_method[0], self.method(a_method[0]).arity)
    }
  end

  def new *args, &block
    args.flat_map
    a_protoObject = self.clone

    if( args.size != 0)
        a_map = args[0]
        a_map.each_key { |a_key|
          if a_protoObject.instance_variable_defined?("@#{a_key}")
            a_protoObject.instance_variable_set( "@#{a_key}", a_map[a_key])
          else
            a_protoObject.set_property(a_key, a_map[a_key])
          end
        }
    end
    a_protoObject.instance_eval &block unless block == nil
    a_protoObject
  end

  def extended(a_block)
    a_object = PrototypedObject.new
    a_object.set_prototypes(self.prototypes)
    a_object.instance_exec 0,0, &a_block
    a_object
  end

  def call_next (a_method)
    #name_method = caller[0][/`.*'/][1..-2]
    #method_block = self.find_block_in_prototypes(a_method, self.call_next_iteration)
    #result = self.instance_eval &method_block
    proto_list = prototypes.select{|a_prototype| a_prototype.respond_to?(a_method)}
    if proto_list.size != 0 then
      result = proto_list[0].send a_method
    end
    result
  end


  def find_block_in_prototypes (method_wanted, iteration)
    block_wanted = nil
    proto_list = prototypes.select{|a_prototype| a_prototype.respond_to?(method_wanted)}
    if proto_list.size != 0 then
    block_wanted = proto_list[iteration].get_method_block(method_wanted)
    end
    block_wanted
  end

  def get_method_block (method_wanted)
    blocks_wanted = self.bloques.select{|a_method| a_method[0] == method_wanted}
    blocks_wanted[blocks_wanted.size - 1][1] #Si hay varias implementaciones del metodo, tomo la ultima agregada
  end

  def method_missing(method_name, *args)
    #Validar que el nombre del metodo tenga un igual. Si no se cumple, super
      if (method_name.to_s.include? "=")
        set_identifier(method_name.to_s.tr('=',''), args[0])
      else
        super
      end
 end

  def with_properties(block)
    #a_map = block.flat_map
    an_object = self.clone
    #a_map = args[0]
    block.each { |a_key| an_object.set_property( a_key, nil) }
    an_object
  end

end

class PrototypedObject
  include Prototyped
end

class PrototypedConstructor

  class << self
  alias_method :new_name, :new

  def new( a_prototype)
    a_object = PrototypedObject.new
    a_object.set_prototype(a_prototype)
    a_object
  end

  def copy(a_prototype)

    a_object = PrototypedObject.new
    a_object.set_prototype(a_prototype)
    a_prototype.atributos.each { |a_attr| a_object.instance_variable_set("@#{a_attr}",a_prototype.instance_variable_get("@#{a_attr}"))}
    a_object

  end

  def create &block

    new_prototype = PrototypedObject.new
    new_prototype.instance_eval &block

    an_object = PrototypedConstructor.new(new_prototype)

    an_object
  end

end



end