require 'rspec'
require_relative '../src/domain/proto_trait_tipos'
describe 'Prototype' do


it 'Asigno propiedad a guerrero' do

  guerrero = PrototypedObject.new
  guerrero.set_property( :energia, 100)
  expect(guerrero.energia).to eq(100)
end

it 'Cuando un guerrero ataca a otro' do

  guerrero = PrototypedObject.new
  guerrero.set_property( :energia, 100)
  guerrero.set_property(:potencial_defensivo, 10)
  guerrero.set_property(:potencial_ofensivo, 30)

  guerrero.set_method(:atacar_a,
                      lambda {
                          |otro_guerrero|
                        if(otro_guerrero.potencial_defensivo < self.potencial_ofensivo)
                          otro_guerrero.recibe_danio(self.potencial_ofensivo - otro_guerrero.potencial_defensivo)
                        end
                      });

  guerrero.set_method(:recibe_danio, lambda { | ataque| self.energia -= ataque})
  otro_guerrero = guerrero.clone #clone es un metodo que ya viene definido en Ruby
  guerrero.atacar_a otro_guerrero
  expect(otro_guerrero.energia).to eq(80)

end

it 'Asigno a un objeto su prototipo' do

  guerrero = PrototypedObject.new
  guerrero.set_property( :energia, 100)
  guerrero.set_property(:potencial_defensivo, 10)
  guerrero.set_property(:potencial_ofensivo, 30)

  guerrero.set_method(:atacar_a,
                      lambda {
                          |otro_guerrero|
                        if(otro_guerrero.potencial_defensivo < self.potencial_ofensivo)
                          otro_guerrero.recibe_danio(self.potencial_ofensivo - otro_guerrero.potencial_defensivo)
                        end
                      });

  guerrero.set_method(:recibe_danio, lambda { | ataque| self.energia -= ataque})


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
  guerrero.set_property( :energia, 100)

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
  guerrero.set_property( :energia, 100)
  guerrero.set_property(:potencial_defensivo, 10)
  guerrero.set_property(:potencial_ofensivo, 30)

  guerrero.set_method(:atacar_a,
                      lambda {
                          |otro_guerrero|
                        if(otro_guerrero.potencial_defensivo < self.potencial_ofensivo)
                          otro_guerrero.recibe_danio(self.potencial_ofensivo - otro_guerrero.potencial_defensivo)
                        end
                      });

  guerrero.set_method(:recibe_danio, lambda { | ataque| self.energia -= ataque})


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

  guerrero = PrototypedObject.new

  Guerrero = PrototypedConstructor.new(guerrero)

  un_guerrero = Guerrero.new(
      {energia: 100, potencial_ofensivo: 30, potencial_defensivo: 10}
  )
  expect(un_guerrero.potencial_ofensivo).to eq(30)
end

it 'Cuando copia estado actual del prototipo' do

  guerrero = PrototypedObject.new
  guerrero.set_property( :energia, 100)
  guerrero.set_property(:potencial_defensivo, 10)
  guerrero.set_property(:potencial_ofensivo, 30)

  Guerrero = PrototypedConstructor.copy(guerrero)

  un_guerrero = Guerrero.new

  expect(un_guerrero.potencial_defensivo).to eq(10)
end

=begin
it 'Cuando seteo un prototipo se obtienen todos sus metodos' do

  guerrero = PrototypedObject.new
  guerrero.set_property( :energia, 100)
  guerrero.set_property(:potencial_defensivo, 10)
  guerrero.set_property(:potencial_ofensivo, 30)

  otro_guerrero = PrototypedObject.new
  otro_guerrero.set_property( :energia, 100)
  otro_guerrero.set_property(:potencial_defensivo, 10)
  otro_guerrero.set_property(:potencial_ofensivo, 30)

  otro_guerrero.set_method(:atacar_a,
                             proc {
                                 |otro_guerrero|
                               if(otro_guerrero.potencial_defensivo < self.potencial_ofensivo)
                                 otro_guerrero.recibe_danio(self.potencial_ofensivo - otro_guerrero.potencial_defensivo)
                               end
                             });
  otro_guerrero.set_method(:recibe_danio, lambda { | ataque| self.energia -= ataque})

  guerrero.set_prototype(otro_guerrero)
  expect(otro_guerrero.methods(false)).to eq(guerrero.methods(false))

end

it 'guerrero ataca a su prototipo' do

  guerrero = PrototypedObject.new
  guerrero.set_property( :energia, 100)
  guerrero.set_property(:potencial_defensivo, 10)
  guerrero.set_property(:potencial_ofensivo, 30)

  otro_guerrero = PrototypedObject.new
  otro_guerrero.set_property( :energia, 100)
  otro_guerrero.set_property(:potencial_defensivo, 10)
  otro_guerrero.set_property(:potencial_ofensivo, 30)

  otro_guerrero.set_method(:atacar_a,
                           proc {
                               |otro_guerrero|
                             if(otro_guerrero.potencial_defensivo < self.potencial_ofensivo)
                               otro_guerrero.recibe_danio(self.potencial_ofensivo - otro_guerrero.potencial_defensivo)
                             end
                           });
  otro_guerrero.set_method(:recibe_danio, lambda { | ataque| self.energia -= ataque})

  guerrero.set_prototype(otro_guerrero)
  guerrero.atacar_a(otro_guerrero)
  expect(otro_guerrero.energia).to eq(80)
end
=end



=begin
  it 'asigno un metodo a un guerrero' do
    guerrero = PrototypedObject.new
    guerrero.set_method(:atacar_a,
                        proc {
                            |otro_guerrero|
                          if(otro_guerrero.potencial_defensivo < self.potencial_ofensivo)
                            otro_guerrero.recibe_danio(self.potencial_ofensivo - otro_guerrero.potencial_defensivo)
                          end
                        });
    guerrero.atacar_a(PrototypedObject.new)
  end

  it 'Un prototipo se crea con energia 100' do

    guerrero = PrototypedObject.new
    guerrero.set_property( energia, 100)
    guerrero.energia == 100
  end

  it 'creacion de un prototipo de guerrero' do
    guerrero = PrototypedObject.new
    Guerrero = PrototypedConstructor.new(guerrero, proc {
        |guerrero_new, una_energia, un_potencial_ofensivo, un_potencial_defensivo|
      guerrero_new.energia = una_energia
      guerrero_new.potencial_ofensivo = un_potencial_ofensivo
      guerrero_new.potencial_defensivo = un_potencial_defensivo
    })
    un_guerrero = Guerrero.new(100, 30, 10)
    expect(un_guerrero.energia).to eq(100)
  end


  it 'un prototipo de guerrero ataca a otro' do

    guerrero.set_property(:potencial_defensivo, 10)
    guerrero.set_property(:potencial_ofensivo, 30)
    guerrero.set_method(:atacar_a,
                        proc {
                            |otro_guerrero|
                          if(otro_guerrero.potencial_defensivo < self.potencial_ofensivo)
                            otro_guerrero.recibe_danio(self.potencial_ofensivo - otro_guerrero.potencial_defensivo)
                          end
                        });
    guerrero.set_method(:recibe_danio, proc {})
    otro_guerrero = guerrero.clone #clone es un metodo que ya viene definido en Ruby
    guerrero.atacar_a otro_guerrero
    expect(otro_guerrero.energia).to eq(80)
  end
=end


end