require '../src/domain/proto_module'
require '../src/domain/proto_Constructor'

class PrototypedObject
  include Prototyped


class << self
alias_method :new_name, :new

  def new &block
    object = self.new_name

    #CORRECCION: se puede reemplazar por lo siguiente
    #if(block != nil) then
    #  object.instance_exec 0,0, &block
    #end
    #object

    if( block == nil) then
      object

        else

     object.instance_exec 0,0, &block
    object
    end
  end
end


end
