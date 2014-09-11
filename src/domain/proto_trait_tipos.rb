class PrototypedObject
  attr_accessor :interested, :bloques, :atributos

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

      self.set_method( a_attr, lambda { self.instance_variable_get("@#{a_attr}") } )
      self.set_method( "#{a_attr}=", lambda { |something| self.instance_variable_set("@#{a_attr}",
                                                          something)})

  end

  def set_prototype (a_prototype)
    a_prototype.set_interested(self)
  end

  def set_interested( a_interested)
    self.interested << a_interested
    # aca habria que bindear los metodos del prototipo con los del objeto

    #self.methods(false).each { |a_method| a_interested.define_singleton_method(":#{a_method}", &self.method(":#{a_method}")) }

    self.atributos.each { |a_attr| a_interested.instance_variable_set("@#{a_attr}", nil)}

    self.bloques.each{|a_method, a_block| a_interested.set_method(a_method, a_block)}


  end
end

module PrototypeConstructor
def new()

end
  def copy(an_object)
    an_object.clone
  end
end