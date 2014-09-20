require 'rspec'
require_relative '../src/domain/proto_trait_tipos'
describe 'Prototype' do


  before {
    @a=5
  }

  it 'Asigno propiedad a guerrero' do

    guerrero = PrototypedObject.new
    guerrero.set_property(:energia, 100)
    expect(guerrero.energia).to eq(100)
  end

  it 'Cuando un guerrero ataca a otro' do

    guerrero = PrototypedObject.new
    guerrero.set_property(:energia, 100)
    guerrero.set_property(:potencial_defensivo, 10)
    guerrero.set_property(:potencial_ofensivo, 30)

    guerrero.set_method(:atacar_a,
                        lambda {
                            |otro_guerrero|
                          if (otro_guerrero.potencial_defensivo < self.potencial_ofensivo)
                            otro_guerrero.recibe_danio(self.potencial_ofensivo - otro_guerrero.potencial_defensivo)
                          end
                        });

    guerrero.set_method(:recibe_danio, lambda { |ataque| self.energia -= ataque })
    otro_guerrero = guerrero.clone #clone es un metodo que ya viene definido en Ruby
    guerrero.atacar_a otro_guerrero
    expect(otro_guerrero.energia).to eq(80)

  end

  it 'Asigno a un objeto su prototipo' do

    guerrero = PrototypedObject.new
    guerrero.set_property(:energia, 100)
    guerrero.set_property(:potencial_defensivo, 10)
    guerrero.set_property(:potencial_ofensivo, 30)

    guerrero.set_method(:atacar_a,
                        lambda {
                            |otro_guerrero|
                          if (otro_guerrero.potencial_defensivo < self.potencial_ofensivo)
                            otro_guerrero.recibe_danio(self.potencial_ofensivo - otro_guerrero.potencial_defensivo)
                          end
                        });

    guerrero.set_method(:recibe_danio, lambda { |ataque| self.energia -= ataque })


    espadachin = PrototypedObject.new

    espadachin.set_prototype(guerrero)
    espadachin.set_property(:habilidad, 0.5)
    espadachin.set_property(:potencial_espada, 30)
    espadachin.energia = 100
    espadachin.potencial_ofensivo = 10

    espadachin.set_method(:potencial_ofensivo, proc {
      @potencial_ofensivo + self.potencial_espada * self.habilidad
    })

    otro_guerrero = guerrero.clone

    espadachin.atacar_a(otro_guerrero)
    expect(otro_guerrero.energia).to eq(85)

  end

  it 'Cuando modifico un prototipo, se modifican las instancias que lo tengan como prototipo' do

    guerrero = PrototypedObject.new
    guerrero.set_property(:energia, 100)

    espadachin = PrototypedObject.new
    espadachin.set_prototype(guerrero)
    espadachin.energia = 100

    guerrero.set_method(:sanar, proc {
      self.energia = self.energia + 10
    })
    espadachin.sanar
    expect(espadachin.energia).to eq(110)

  end

  it 'No son afectados los metodos que fueron redefinidos por el objeto derivado' do

    guerrero = PrototypedObject.new
    guerrero.set_property(:energia, 100)
    guerrero.set_property(:potencial_defensivo, 10)
    guerrero.set_property(:potencial_ofensivo, 30)

    guerrero.set_method(:atacar_a,
                        lambda {
                            |otro_guerrero|
                          if (otro_guerrero.potencial_defensivo < self.potencial_ofensivo)
                            otro_guerrero.recibe_danio(self.potencial_ofensivo - otro_guerrero.potencial_defensivo)
                          end
                        });

    guerrero.set_method(:recibe_danio, lambda { |ataque| self.energia -= ataque })


    espadachin = PrototypedObject.new

    espadachin.set_prototype(guerrero)
    espadachin.set_property(:habilidad, 0.5)
    espadachin.set_property(:potencial_espada, 30)
    espadachin.energia = 100
    espadachin.potencial_ofensivo = 10

    espadachin.set_method(:potencial_ofensivo, proc {
      @potencial_ofensivo + self.potencial_espada * self.habilidad
    })


    guerrero.set_method(:potencial_ofensivo, proc {
      1000
    })
    expect(espadachin.potencial_ofensivo).to eq(25)

  end

  it 'Cuando creo una instancia de un objeto con un prototipo predefinido' do
    expect(@a).to eq(5)
    guerrero = PrototypedObject.new

    Guerrero = PrototypedConstructor.new(guerrero)

    un_guerrero = Guerrero.new(
        {energia: 100, potencial_ofensivo: 30, potencial_defensivo: 10}
    )
    expect(un_guerrero.potencial_ofensivo).to eq(30)
  end

  it 'Cuando copia estado actual del prototipo' do

    guerrero = PrototypedObject.new
    guerrero.set_property(:energia, 100)
    guerrero.set_property(:potencial_defensivo, 10)
    guerrero.set_property(:potencial_ofensivo, 30)

    Guerrero = PrototypedConstructor.copy(guerrero)

    un_guerrero = Guerrero.new

    expect(un_guerrero.potencial_defensivo).to eq(10)
  end

  it 'Cuando un constructor altera los metodos que entiende un objeto' do

    guerrero = PrototypedObject.new
    guerrero.set_property(:energia, 100)
    guerrero.set_property(:potencial_defensivo, 10)
    guerrero.set_property(:potencial_ofensivo, 30)

    Guerrero = PrototypedConstructor.copy(guerrero)

    Espadachin = Guerrero.extended (lambda {
        |habilidad, potencial_espada|
      self.set_property(:habilidad, habilidad)
      self.set_property(:potencial_espada, potencial_espada)
      self.set_method(:potencial_ofensivo, proc {
        @potencial_ofensivo + self.potencial_espada * self.habilidad
      })
    })
    espadachin = Espadachin.new({energia: 100, potencial_ofensivo: 30, potencial_defensivo: 10, habilidad: 0.5, potencial_espada: 30})
    expect(espadachin.potencial_ofensivo).to eq(45)
  end


  it 'Asignar nuevos atributos (Azucar Sintactico p1)' do
    guerrero_proto2 = PrototypedObject.new
    guerrero_proto2.energia = 100
    expect(guerrero_proto2.energia).to eq(100)
  end

  it 'Agregar nuevos metodos (Azucar sintactico p1)' do

    guerrero_proto = PrototypedObject.new
    guerrero_proto.energia = 100
    guerrero_proto.potencial_defensivo = 10
    guerrero_proto.potencial_ofensivo = 30


    guerrero_proto.atacar_a = proc { |otro_guerrero|
      if (otro_guerrero.potencial_defensivo < self.potencial_ofensivo)
        otro_guerrero.recibe_danio(self.potencial_ofensivo - otro_guerrero.potencial_defensivo)
      end
    }

    guerrero_proto.recibe_danio= proc { |ataque| self.energia -= ataque }
    otro_guerrero= guerrero_proto.clone

    guerrero_proto.atacar_a otro_guerrero
    expect(otro_guerrero.energia).to eq(80)

  end

  it 'Azucar Sintactico sobre new' do
    #PrototypedObject.new {
    #   puts 'bloque desde el new'
    #}
    guerrero_proto = PrototypedObject.new {
      self.energia = 100
      self.potencial_ofensivo = 30
      self.potencial_defensivo = 10

      self.atacar_a = proc { |otro_guerrero|
        if (otro_guerrero.potencial_defensivo < self.potencial_ofensivo)
          otro_guerrero.recibe_danio(self.potencial_ofensivo - otro_guerrero.potencial_defensivo)
        end
      }

      self.recibe_danio = proc { |ataque| self.energia -= ataque }
    }
    guerrero= guerrero_proto.clone

    guerrero_proto.atacar_a guerrero
    #expect(guerrero.atributos.include?(:energia)).to eq(true)
    expect(guerrero.energia).to eq(80)

    # No funciona debido a que bajo nuestra definicion de new, recibe como parametro *args y no encontramos la manera de que corran ambos comportamientos a la vez.
  end

  it 'Azucar Sintactico para obtener prototipos' do

    guerrero = PrototypedObject.new

    Guerrero = PrototypedConstructor.copy(guerrero)

    atila = Guerrero.new(
        {energia: 100, potencial_ofensivo: 50, potencial_defensivo: 30}
    )
    expect(atila.potencial_ofensivo).to eq(50)
    proto_guerrero = Guerrero.prototype
    proto_guerrero.potencial_ofensivo = proc {
      1000
    } #no cumple el assertion ya que el setter "potencial_ofensivo=" esta definido y nosotros implementamos azucar sintactico con method_missing
    expect(atila.potencial_ofensivo).to eq(1000)

  end

  it 'Azucar sintactico sobre extended' do

    guerrero = PrototypedObject.new

    Guerrero = PrototypedConstructor.copy(guerrero)

    Guerrero.energia = 100
    Guerrero.potencial_defensivo = 10

    Espadachin = Guerrero.extended (lambda {
        |una_habilidad, un_potencial_espada|
      self.habilidad = una_habilidad
      self.potencial_espada = un_potencial_espada
      self.potencial_ofensivo = proc {
        @potencial_ofensivo + self.potencial_espada * self.habilidad
      }
    })
    espadachin = Espadachin.new({energia: 100, potencial_ofensivo: 30, potencial_defensivo: 10, habilidad: 0.5, potencial_espada: 30})
    expect(espadachin.potencial_ofensivo).to eq(45)

  end

  it 'Cuando seteo un prototipo se obtienen todos sus metodos' do

    guerrero = PrototypedObject.new
    guerrero.set_property(:energia, 100)
    guerrero.set_property(:potencial_defensivo, 10)
    guerrero.set_property(:potencial_ofensivo, 30)

    otro_guerrero = PrototypedObject.new
    otro_guerrero.set_property(:energia, 100)
    otro_guerrero.set_property(:potencial_defensivo, 10)
    otro_guerrero.set_property(:potencial_ofensivo, 30)

    otro_guerrero.set_method(:atacar_a,
                             proc {
                                 |otro_guerrero|
                               if (otro_guerrero.potencial_defensivo < self.potencial_ofensivo)
                                 otro_guerrero.recibe_danio(self.potencial_ofensivo - otro_guerrero.potencial_defensivo)
                               end
                             });
    otro_guerrero.set_method(:recibe_danio, lambda { |ataque| self.energia -= ataque })

    guerrero.set_prototype(otro_guerrero)
    expect(otro_guerrero.methods(false)).to eq(guerrero.methods(false))

  end

  it 'guerrero ataca a su prototipo' do

    guerrero = PrototypedObject.new
    guerrero.set_property(:energia, 100)
    guerrero.set_property(:potencial_defensivo, 10)
    guerrero.set_property(:potencial_ofensivo, 30)

    otro_guerrero = PrototypedObject.new
    otro_guerrero.set_property(:energia, 100)
    otro_guerrero.set_property(:potencial_defensivo, 10)
    otro_guerrero.set_property(:potencial_ofensivo, 30)

    otro_guerrero.set_method(:atacar_a,
                             proc {
                                 |otro_guerrero|
                               if (otro_guerrero.potencial_defensivo < self.potencial_ofensivo)
                                 otro_guerrero.recibe_danio(self.potencial_ofensivo - otro_guerrero.potencial_defensivo)
                               end
                             });
    otro_guerrero.set_method(:recibe_danio, lambda { |ataque| self.energia -= ataque })

    guerrero.set_prototype(otro_guerrero)
    guerrero.atacar_a(otro_guerrero)
    expect(otro_guerrero.energia).to eq(80)
  end


  it 'un prototipo guerrero deberia entender los mensajes de los multiples prototipos que forman al prototipo' do

    guerrero = PrototypedObject.new
    guerrero.set_property(:energia, 100)
    guerrero.set_property(:potencial_defensivo, 10)
    guerrero.set_property(:potencial_ofensivo, 30)
    Guerrero = PrototypedConstructor.copy(guerrero)

    proto_atacante = PrototypedObject.new
    proto_atacante.set_method(:atacar_a,
                              proc {
                                  |otro_guerrero|
                                if (otro_guerrero.potencial_defensivo < self.potencial_ofensivo)
                                  otro_guerrero.recibe_danio(self.potencial_ofensivo - otro_guerrero.potencial_defensivo)
                                end
                              });

    proto_defensor = PrototypedObject.new
    proto_defensor.set_method(:recibe_danio, lambda { |ataque| self.energia -= ataque })

    guerrero.set_prototypes([proto_atacante, proto_defensor])

    un_guerrero = Guerrero.new
    otro_guerrero = Guerrero.new

    un_guerrero.atacar_a(otro_guerrero)
    expect(otro_guerrero.energia).to eq(80)

  end


  it 'Crear nuevo objeto con nuevo prototipo (solo con metodos)' do

    Guerrero = PrototypedConstructor.create {
      self.metodo1 = proc { "hola " }
      self.metodo2 = proc { "y chau" }
    }

    atila = Guerrero.new
    expect(atila.metodo1 + atila.metodo2).to eq("hola y chau")

  end

  it 'Crear nuevo objeto con nuevo prototipo (con metodos y atributos)' do

    Guerrero = PrototypedConstructor.create {
      self.metodo1 = proc { "hola " }
      self.metodo2 = proc { "y chau" }
    }.with_properties([:energia, :potencial_ofensivo, :potencial_defensivo])

    atila = Guerrero.new
    expect(atila.atributos.include?(:energia)).to eq(true)

  end


it 'Test call_next' do

   guerrero = PrototypedObject.new

   Guerrero = PrototypedConstructor.copy(guerrero)

   Guerrero.energia = 100
   Guerrero.potencial_defensivo = 10

   Espadachin = Guerrero.extended ( lambda {
       |una_habilidad, un_potencial_espada|
     self.habilidad = una_habilidad
     self.potencial_espada = un_potencial_espada
     self.potencial_ofensivo = proc {
       self.call_next + self.potencial_espada * self.habilidad
     }
   })

   guerrero.potencial_ofensivo = 50
   espadachin = Espadachin.new({energia: 100, potencial_defensivo: 10, habilidad: 0.5, potencial_espada: 30})

   espadachin.set_prototype = guerrero
   expect(espadachin.potencial_ofensivo).to eq(65)

end
end