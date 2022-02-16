# frozen_string_literal: true

module OJElectronics
  class Thermostat
    REGULATION_MODES = %i[schedule temporary_hold permanent_hold vacation_hold].freeze
    attr_reader(*%i[serial_number temperature set_point_temperature room online heating regulation_mode])

    def initialize(client, serial_number)
      @client = client
      @serial_number = serial_number
    end

    def refresh(json)
      @temperature = json["Temperature"].to_f / 100
      @set_point_temperature = json["SetPointTemp"].to_f / 100
      @room = json["Room"]
      @online = json["Online"]
      @heating = json["Heating"]
      @regulation_mode = REGULATION_MODES[json["RegulationMode"] - 1]
    end

    def set_point_temperature=(value) # rubocop:disable Naming/AccessorMethodName
      @client.api.post("thermostat?sessionid=#{@client.session_id}&serialnumber=#{serial_number}",
                       RegulationMode: 3,
                       VacationEnabled: false,
                       ManualTemperature: (value * 100).to_i)
    end
  end
end
