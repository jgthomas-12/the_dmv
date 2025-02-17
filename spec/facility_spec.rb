require 'spec_helper'

RSpec.describe Facility do
  before(:each) do
    @facility = Facility.new({name: 'Albany DMV Office', address: '2242 Santiam Hwy SE Albany OR 97321', phone: '541-967-2014' })
  end
  describe "Established information" do

    describe '#initialize' do
      it 'can initialize' do
        expect(@facility).to be_an_instance_of(Facility)
        expect(@facility.name).to eq('Albany DMV Office')
        expect(@facility.address).to eq('2242 Santiam Hwy SE Albany OR 97321')
        expect(@facility.phone).to eq('541-967-2014')
        expect(@facility.services).to eq([])
      end
    end
  
    describe '#add service' do
      it 'can add available services' do
        expect(@facility.services).to eq([])
        @facility.add_service('New Drivers License')
        @facility.add_service('Renew Drivers License')
        @facility.add_service('Vehicle Registration')
        expect(@facility.services).to eq(['New Drivers License', 'Renew Drivers License', 'Vehicle Registration'])
      end
    end
  end

  describe "Vehicle Registration" do
    before(:each) do

      @facility_1 = Facility.new({name: 'Albany DMV Office', address: '2242 Santiam Hwy SE Albany OR 97321', phone: '541-967-2014' })
      @facility_2 = Facility.new({name: 'Ashland DMV Office', address: '600 Tolman Creek Rd Ashland OR 97520', phone: '541-776-6092' })
      
      @cruz = Vehicle.new({vin: '123456789abcdefgh', year: 2012, make: 'Chevrolet', model: 'Cruz', engine: :ice} )
      @bolt = Vehicle.new({vin: '987654321abcdefgh', year: 2019, make: 'Chevrolet', model: 'Bolt', engine: :ev} )
      @camaro = Vehicle.new({vin: '1a2b3c4d5e6f', year: 1969, make: 'Chevrolet', model: 'Camaro', engine: :ice} )
    end

    it "returns the services added" do

      expect(@facility_1.add_service('Vehicle Registration')).to eq(["Vehicle Registration"])

    end

    it "vehicle registration_date defaults to nil" do

      expect(@cruz.registration_date).to eq(nil)

    end

    it "registered_vehicles attribute defaults to empty" do

      expect(@facility_1.registered_vehicles).to eq([])

    end

    it "collected_fees attribute defaults to 0" do

      expect(@facility_1.collected_fees).to eq(0)

    end
    
    it "returns the register_vehicle method" do
      
      @facility_1.add_service('Vehicle Registration')

      expect(@facility_1.register_vehicle(@cruz)).to eq([@cruz])

      expect(@facility_1.register_vehicle(@camaro)).to eq([@cruz, @camaro])

      expect(@facility_1.register_vehicle(@bolt)).to eq([@cruz, @camaro, @bolt])

    end

    it "will set the vehicle registration date" do

      date = Time.new.strftime("%d/%m/%Y")
      @facility_1.register_vehicle(@cruz)
      @facility_1.register_vehicle(@camaro)
      @facility_1.register_vehicle(@bolt)

      expect(@cruz.registration_date).to eq(date)
      expect(@camaro.registration_date).to eq(date)
      expect(@bolt.registration_date).to eq(date)

    end
    
    it "adds plate_type to vehicle when registered" do
      
      @facility_1.add_service("Vehicle Registration")
      expect(@cruz.plate_type).to eq(nil)
      @facility_1.register_vehicle(@cruz)

      expect(@facility_1.registered_vehicles[0].plate_type).to eq(:regular)
      expect(@cruz.plate_type).to eq(:regular)

    end

    it "can have a :regular plate type" do
      @facility_1.add_service("Vehicle Registration")
      expect(@cruz.plate_type).to eq(nil)
      @facility_1.register_vehicle(@cruz)

      expect(@cruz.plate_type).to eq(:regular)

    end

    it "can have an :ev plate type" do
      @facility_1.add_service("Vehicle Registration")
      @facility_1.register_vehicle(@bolt)
      expect(@bolt.plate_type).to eq(:ev)

    end

    it "can have an :antique plate type" do
      @facility_1.add_service("Vehicle Registration")
      @facility_1.register_vehicle(@camaro)
      expect(@camaro.plate_type).to eq(:antique)
      
    end


    it "adds vehicles to @registered_vehicles attribute" do

      @facility_1.add_service('Vehicle Registration')

      @facility_1.register_vehicle(@cruz)
      
      expect(@facility_1.registered_vehicles).to eq([@cruz])

      @facility_1.register_vehicle(@camaro)
      
      expect(@facility_1.registered_vehicles).to eq([@cruz, @camaro])

      @facility_1.register_vehicle(@bolt)

      expect(@facility_1.registered_vehicles).to eq([@cruz, @camaro, @bolt])


    end
      
    it "can collect fees for any type of car" do

      @facility_1.add_service('Vehicle Registration')
      
      @facility_1.register_vehicle(@cruz)
      
      expect(@facility_1.collected_fees).to eq(100)
      
      @facility_1.register_vehicle(@camaro)
      
      expect(@facility_1.collected_fees).to eq(125)
      
      @facility_1.register_vehicle(@bolt)

      expect(@facility_1.collected_fees).to eq(325)
      
    end

    
    it "facility_2 is empty" do

      expect(@facility_2.registered_vehicles).to eq([])

      expect(@facility_2.services).to eq([])
      
      expect(@facility_2.register_vehicle(@bolt)).to eq(nil)
      
      expect(@facility_2.registered_vehicles).to eq([])
      
      expect(@facility_2.collected_fees).to eq(0)
      
    end
  end

  describe "Getting a Driver's License" do
    before(:each) do

      @registrant_1 = Registrant.new('Bruce', 18, true )
      @registrant_2 = Registrant.new('Penny', 16 )
      @registrant_3 = Registrant.new('Tucker', 15 )
      
      @facility_1 = Facility.new({name: 'Albany DMV Office', address: '2242 Santiam Hwy SE Albany OR 97321', phone: '541-967-2014' })
      @facility_2 = Facility.new({name: 'Ashland DMV Office', address: '600 Tolman Creek Rd Ashland OR 97520', phone: '541-776-6092' })
      
    end

    describe "#Written Test" do
    
      it "a registrant has accessible data" do 
        #does this need to be tested? Have I already asserted this above?
        
        expected = {
          :written=>false, 
          :license=>false, 
          :renewed=>false
        }
        
        expect(@registrant_1.license_data).to eq(expected)
        
        expect(@registrant_1.permit?).to be(true)
        
        expect(@registrant_2.age).to eq(16)
        
      end
      
      it "CAN'T administer written_test w/o service" do
        
        expect(@facility_1.administer_written_test(@registrant_1)).to be(false)
        
        expected = {
          :written=>false, 
          :license=>false, 
          :renewed=>false
        }
        
        expect(@registrant_1.license_data).to eq(expected)
        
      end
      
      it "CAN administer written test w/ service" do
        
        expect(@facility_1.add_service('Written Test')).to eq(["Written Test"])
        
        expect(@facility_1.administer_written_test(@registrant_1)).to be(true)
        
        expected = {
          :written=>true, 
          :license=>false, 
          :renewed=>false
        }
        
        expect(@registrant_1.license_data).to eq(expected)
        
      end
      
      it "a registrant can't take a written_test w/o a permit" do
        
        @facility_1.add_service('Written Test')
        
        expect(@registrant_2.permit?).to be(false)
        
        expect(@facility_1.administer_written_test(@registrant_2)).to be(false)
        
        @registrant_2.earn_permit
        
        expect(@facility_1.administer_written_test(@registrant_2)).to be(true)
        
        expected = {
          :written=>true, 
          :license=>false, 
          :renewed=>false
        }
        
        expect(@registrant_2.license_data).to eq(expected)
        
      end
      
      it "a registrant w/ permit can't obtain written_test if age is under 16" do
        
        
        expect(@registrant_3.age).to eq(15)
        
        expect(@registrant_3.permit?).to be(false)
        
        expect(@facility_1.administer_written_test(@registrant_3)).to be(false)
        
        @registrant_3.earn_permit
        
        expect(@facility_1.administer_written_test(@registrant_3)).to be(false)
        
        expected_2 = {
          :written=>false, 
          :license=>false, 
          :renewed=>false
        }
        
        expect(@registrant_3.license_data).to eq(expected_2)
        
      end
    end
    
    describe "Road Test" do
      
      it "CAN'T administer road test w/o a written test" do

        expect(@facility_1.administer_road_test(@registrant_3)).to be(false)
        
        @registrant_3.earn_permit
        
        expect(@facility_1.administer_road_test(@registrant_3)).to be(false)
        
        expected = {
          :written=>false, 
          :license=>false, 
          :renewed=>false
        }

        expect(@registrant_3.license_data).to eq(expected)
        
      end
      
      it "CAN'T administer road test w/o adding service" do
        @facility_1.add_service("Written Test")
        @facility_1.administer_written_test(@registrant_1)
        expected_1 = {
          :written=>true, 
          :license=>false, 
          :renewed=>false
        }
        
        expect(@registrant_1.license_data).to eq(expected_1)
        
        expect(@facility_1.administer_road_test(@registrant_1)).to be(false)

        expect(@facility_1.add_service('Road Test')).to eq(["Written Test", "Road Test"])
        
        expect(@facility_1.administer_road_test(@registrant_1)).to be(true)
        
        expected_2 = {
          :written=>true, 
          :license=>true, 
          :renewed=>false
        }

        expect(@registrant_1.license_data).to eq(expected_2)

      end

      it "can administer road_test with written test" do
        
        @facility_1.add_service("Written Test")
        @facility_1.add_service("Road Test")
        @registrant_2.earn_permit
        @facility_1.administer_written_test(@registrant_2)

          expect(@facility_1.administer_road_test(@registrant_2)).to be(true)

        expected_2 = {
          :written=>true, 
          :license=>true, 
          :renewed=>false
        }
      
        expect(@registrant_2.license_data).to eq(expected_2)

      end
    end
      
    describe "Renew License" do 

      it "CAN'T renew license without adding service" do

        expect(@facility_1.renew_drivers_license(@registrant_1)).to be(false)
        
        @facility_1.add_service("Written Test")
        @facility_1.add_service("Road Test")
        services_offered = ["Written Test", "Road Test", "Renew License"]

        expect(@facility_1.add_service('Renew License')).to eq(services_offered)
      end

      it "can renew license with written and road tests" do

        @facility_1.add_service("Written Test")
        @facility_1.add_service("Road Test")
        @facility_1.add_service('Renew License')
        @facility_1.administer_written_test(@registrant_1)
        @facility_1.administer_road_test(@registrant_1)

        expect(@facility_1.renew_drivers_license(@registrant_1)).to be(true)

        expected = {
          :written=>true, 
          :license=>true, 
          :renewed=>true
        }
        
        expect(@registrant_1.license_data).to eq(expected)
        
      end

      it "CAN'T renew license without written or license data" do

        @facility_1.add_service("Written Test")
        @facility_1.add_service("Road Test")
        @facility_1.add_service('Renew License')
        @registrant_2.earn_permit
        @registrant_3.earn_permit
        @facility_1.administer_written_test(@registrant_2)
        @facility_1.administer_road_test(@registrant_2)

        expect(@facility_1.renew_drivers_license(@registrant_3)).to be(false)

        expected = {
          :written=>false, 
          :license=>false, 
          :renewed=>false
        }

        expect(@registrant_3.license_data).to eq(expected)
        
        expect(@facility_1.renew_drivers_license(@registrant_2)).to be(true)
        
        expected_2 = {
          :written=>true, 
          :license=>true, 
          :renewed=>true
        }

        expect(@registrant_2.license_data).to eq(expected_2)
        
      end
    end
  end
end
