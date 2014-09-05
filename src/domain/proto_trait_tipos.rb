class PrototypeObject


end

#Test a partir de aca
describe 'Implementacion de ProtoTraitstipos en Ruby ' do

  it 'un prototipo de guerrero ataca a otro' do

guerrero = PrototypedObject.new
guerrero.set_property(:energia, 100)
expect(guerrero.energia).to eq(100)
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

  it 'creacion de un prototipo de guerrero' do
    Guerrero = PrototypedConstructor.new(guerrero, proc {
        |guerrero_nuevo, una_energia, un_potencial_ofensivo, un_potencial_defensivo|
      guerrero_nuevo.energia = una_energia
      guerrero_nuevo.potencial_ofensivo = un_potencial_ofensivo
      guerrero_nuevo.potencial_defensivo = un_potencial_defensivo
    })
    un_guerrero = Guerrero.new(100, 30, 10)
    expect(un_guerrero.energia).to eq(100)

  end


  end