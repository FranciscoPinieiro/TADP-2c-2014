


class PrototypeObject
 def set_method (a_method, a_block )
   self.singleton_class.send(:define_method,
                              a_method,a_block)

 end
  def set_property (a_attr, a_value)
      self.instance_variable_set(a_attr, a_value)
  end

  def set_prototype (an_object)

  end
end
