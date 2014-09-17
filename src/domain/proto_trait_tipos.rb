module Prototyped
  attr_accessor :interested, :bloques, :atributos, :prototipo, :prototypes

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

  def set_identifier(a_key, a_value)

    if a_value.respond_to? :call
      self.set_method(a_key, a_value)
    else
      self.set_property(a_key, a_value)
    end
  end

  def set_prototype (a_prototype)
    a_prototype.set_interested(self)
    self.prototipo = a_prototype
    #Hay que readaptar el resto del codigo para que use el array prototypes y no la var prototipo ya que ahora puede tener varios.
    self.prototypes << a_prototype
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

  def call_next
    method_name = caller_locations(1,1)[0].label
    next_prototype_with_method = self.prototype_look_up(method_name)
    if !(next_prototype_with_method.nil?)
      method_block = next_prototype_with_method.get_method_block(method_name)
      self.instance_eval method_block
      #method_block.call(self, 0, 0) #no se cual funciona todavia
    end
    nil #Aca habria que hacer un raise error o algo asi porque no se encontro el metodo en los siguientes prototipos
  end

  def prototype_look_up (method_wanted)
    first_prototype = true
    self.prototypes.each {|a_prototype|
      if a_prototype.respond_to? (method_wanted)
        if first_prototype == true
          #Salteamos el primer prototipo que tenga dicho metodo
          #ya que este coincide con el metodo que llamo al call_next
          first_prototype = false
        else
          # Encontramos el siguiente prototipo que define al metodo buscado
          return a_prototype
        end
      end
    }
    nil #no se encontro un segundo prototipo que implemente dicho metodo
  end

  def get_method_block (method_wanted)
      prototype_method_names = self.bloques.map{|a_method| a_method[0].to_s}
      method_index = prototype_method_names.index(method_wanted)
      if !method_index.nil?
        return self.bloques[method_index][1]
      end
  end

  def method_missing(method_name, *args)
    set_identifier(method_name.to_s.tr('=',''), args[0])
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