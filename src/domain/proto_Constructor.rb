
class PrototypedConstructor

  class << self

    def new( a_prototype)
      a_object = PrototypedObject.new
      a_object.set_prototype(a_prototype)
      a_object
    end

    def copy(a_prototype)

      a_object = self.new(a_prototype)
      a_prototype.atributos.each { |a_attr| a_object.instance_variable_set("@#{a_attr}",a_prototype.instance_variable_get("@#{a_attr}"))}
      a_object

    end

    def create &block

      new_prototype = PrototypedObject.new
      new_prototype.instance_eval &block
      a_object = PrototypedConstructor.new(new_prototype)

      a_object
    end

  end



  end