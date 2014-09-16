module Prototyped
  attr_accessor :interested, :bloques, :atributos, :prototipo

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

  def set_method (a_method, a_block )

   self.bloques << [a_method, a_block]

   self.singleton_class.send(:define_method,
                              a_method,a_block)

   self.interested.each do |a_interested|
     if not a_interested.respond_to? (a_method)
      a_interested.set_method( a_method, a_block)
     end
   end

 end
  def set_property (a_attr, a_value)

      self.atributos << a_attr

      self.instance_variable_set("@#{a_attr}", a_value)
      self.interested.each{|a_interested| a_interested.instance_variable_set("@#{a_attr}", nil) }

      if not self.respond_to?(a_attr)
        self.set_method( a_attr, lambda { self.instance_variable_get("@#{a_attr}") } )
      end

      if not self.respond_to?("#{a_attr}=")
        self.set_method( "#{a_attr}=", lambda { |something| self.instance_variable_set("@#{a_attr}",something)})
      end
  end

  def set_prototype (a_prototype)
    a_prototype.set_interested(self)
    self.prototipo = a_prototype
  end

  def set_interested( a_interested)
    self.interested << a_interested
    # aca habria que bindear los metodos del prototipo con los del objeto

    #self.methods(false).each { |a_method| a_interested.define_singleton_method(":#{a_method}", &self.method(":#{a_method}")) }

    self.atributos.each { |a_attr| a_interested.set_property(a_attr, nil)}

    self.bloques.each{|a_method, a_block| a_interested.set_method(a_method, a_block)}


  end

  def new (*args )
    args.flat_map
    a_protoObject = self.clone
    if( args.size != 0) then
        a_map = args[0]
        a_map.each_key { |a_key| a_protoObject.set_property( a_key, a_map[a_key]) }
    end

    a_protoObject

  end

  def extended( a_block)
    a_object = PrototypedObject.new
    a_object.set_prototype(self.prototipo)

    a_block.call(a_object, 0, 0)

    a_object
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
    a_prototype.atributos.each { |a_attr| a_object.set_property( a_attr, a_prototype.instance_variable_get("@#{a_attr}"))}
    a_object

  end
end


end


