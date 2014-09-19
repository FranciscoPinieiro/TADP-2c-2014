module Prototyped
  attr_accessor :interested, :bloques, :proto_methods, :atributos, :prototypes, :call_next_iteration

  def initialize
    call_next_iteration = 0
  end

  def interested
    @interested = @interested || []
    @interested
  end

  def bloques
    @bloques = @bloques || []
    @bloques
  end

  def proto_methods
    @proto_methods = @proto_methods || []
    @proto_methods
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

  def copy_method (a_method, a_block, a_interested)
    a_interested.proto_methods << [a_method, self]
    if not a_interested.respond_to? (a_method)
      a_interested.singleton_class.send(:define_method,a_method,a_block)
    end
    a_interested.broadcast_method(a_method,a_block)
  end

  def copy_subprototypes(a_interested)
    self.prototypes.each{|a_subprototype|
      a_subprototype.set_interested(a_interested)
    }
  end

  def broadcast_method (a_method, a_block)
    self.interested.each do |a_interested|
      copy_method(a_method, a_block, a_interested)
    end
  end

  def set_method (a_method, a_block)
    self.bloques << [a_method,a_block]
    self.singleton_class.send(:define_method,a_method,a_block)
    self.broadcast_method(a_method, a_block)
  end

  def set_property (a_attr, a_value)
    if !self.instance_variable_defined?("@#{a_attr}")
      self.atributos << a_attr
      self.instance_variable_set("@#{a_attr}", a_value)
      self.interested.each{|a_interested|
      if !a_interested.instance_variable_defined?("@#{a_attr}")
        a_interested.instance_variable_set("@#{a_attr}", nil)
      end
      }
    end

    if not self.respond_to?(a_attr)
      self.set_method( a_attr, lambda { self.instance_variable_get("@#{a_attr}") } )
    end

    if not self.respond_to?("#{a_attr}=")
      self.set_method( "#{a_attr}=", lambda { |something| self.instance_variable_set("@#{a_attr}",something)})
    end
  end

  def set_identifier(a_key, a_value)
    if a_value.respond_to? :call
      self.set_method(a_key, a_value)
    else
      self.set_property(a_key, a_value)
    end
  end

  def set_prototype (a_prototype)
    a_prototype.set_interested(self)
    self.prototypes << a_prototype
  end

  def set_prototypes (a_prototype_list)
    a_prototype_list.each {|a_prototype|
      set_prototype a_prototype
    }
  end

  def set_interested( a_interested)
    self.interested << a_interested
    self.atributos.each { |a_attr| a_interested.set_property(a_attr, nil)}
    self.bloques.each{|a_method, a_block| copy_method(a_method, a_block, a_interested)}
    self.copy_subprototypes(a_interested)
  end

  def new (*args )
    args.flat_map
    a_protoObject = self.clone
#    a_protoObject = PrototypedObject.new
#    a_protoObject.set_prototypes(self.prototypes)
#    self.prototypes.each{|a_prototype|
#      a_prototype.atributos.each { |a_attr| a_protoObject.instance_variable_set("@#{a_attr}",a_prototype.instance_variable_get("@#{a_attr}"))}
#    }

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
    a_protoObject
  end

  def extended(a_block)
    a_object = PrototypedObject.new
    if self.prototypes.size != 1
      a_object.set_prototypes(self.prototypes)
    else
      a_object.set_prototype(self.prototypes[0])
    end

    a_block.call(a_object, 0, 0)
    a_object
  end

  def call_next
    #method_name = caller
    call_loc = caller_locations
    method_name = caller_locations(1,1)[0].label
    if call_next_iteration.nil? then
      call_next_iteration = 0
    end
    call_next_iteration =+ 1
    method_wanted_block = self.get_method_block(method_name)
    self.instance_eval method_wanted_block
    call_next_iteration =-1
    nil #Aca habria que hacer un raise error o algo asi porque no se encontro el metodo en los siguientes prototipos
  end

  # def prototype_look_up (method_wanted)
  #   prototype_method_names = self.proto_methods.keep_if{|a_method| a_method[0].to_s == method_wanted}
  #   if !prototype_method_names.nil?
  #     return prototype_method_names[call_next_iteration-1][1] #Devuelve el prototype que implementa ese metodo
  #   end
  #   nil
  # end

  def find_block_in_prototypes (method_wanted)
    block_wanted = nil
    prototypes.each{ |a_prototype|
      if (block_wanted.nil? && a_prototype.respond_to?(method_wanted)) then
        block_wanted = a_prototype.get_method_block(method_wanted)
      end
    }
    block_wanted
  end

  def get_method_block (method_wanted)
    block_wanted = nil
    blocks_wanted = self.bloques.keep_if{|a_method| a_method[0].to_s == method_wanted}
    if !(blocks_wanted.nil? || blocks_wanted == [])
      block_wanted = blocks_wanted[0][1]
    else
      blocks_wanted = find_block_in_prototypes(method_wanted)
    end
    blocks_wanted
  end

  def method_missing(method_name, *args)
    set_identifier(method_name.to_s.tr('=',''), args[0])
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