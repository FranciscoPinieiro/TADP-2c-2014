class PrototypedObject
  attr_accessor :interested

  def interested
    @interested = @interested || []
    @interested
  end

 def set_method (a_method, a_block )
   self.singleton_class.send(:define_method,
                              a_method,a_block)
   self.interested.each{|a_interested| a_interested.set_method( a_method, a_block) }

 end
  def set_property (a_attr, a_value)
      self.instance_variable_set("@#{a_attr}", a_value)
      self.set_method( a_attr, lambda { self.instance_variable_get("@#{a_attr}") } )
      self.set_method( "#{a_attr}=", lambda { |something| self.instance_variable_set("@#{a_attr}",
                                                          something)})
  end

  def set_prototype (a_prototype)
    a_prototype.set_interested(self)
  end

  def set_interested( a_interested)
    @interested << a_interested
    # aca habria que bindear los metodos del prototipo con los del objeto
  end
end

module PrototypeConstructor
def new()

end
  def copy(an_object)
    an_object.clone
  end
end