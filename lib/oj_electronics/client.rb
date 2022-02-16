# frozen_string_literal: true

require "active_support"
require "active_support/core_ext/enumerable"
require "faraday_middleware"

module OJElectronics
  class Client
    class AuthenticationError < RuntimeError
      class << self
        def create(error_code)
          klass, message = case error_code
                           when 1 then [InvalidUsernameError, "Invalid Username"]
                           when 2 then [IncorrectPasswordError, "Incorrect password"]
                           else
                             [self, nil]
                           end
          klass.new(error_code, message)
        end
      end

      attr_reader :error_code

      def initialize(error_code, message = nil)
        @error_code = error_code
        super(message || "Unable to authenticate: ErrorCode #{error_code}")
      end
    end

    class IncorrectPasswordError < AuthenticationError; end
    class InvalidUsernameError < AuthenticationError; end

    BRANDS = {
      oj_electronics: 0,
      schluter: 8
    }.freeze

    attr_reader(*%i[username session_id brand expires thermostats])

    def initialize(username, password, session_id: nil, expires: nil, brand: :oj_electronics)
      raise ArgumentError, "unrecognized brand #{brand.inspect}" unless BRANDS.key?(brand)

      @brand = brand
      @username = username
      @password = password
      @session_id = session_id
      @expires = expires
      @api = Faraday.new(url: "https://mythermostat.info/api/") do |f|
        f.request :json
        f.request :retry
        f.response :raise_error
        f.response :json
        f.adapter :net_http_persistent
      end
      @thermostats = {}

      refresh
    end

    def expired?
      @session_id.nil? || @expires.nil? || @expires < Time.now
    end

    # refresh all thermostats
    def refresh
      thermostats = api.get("thermostats", sessionid: session_id)
                       .body["Groups"]
                       .flat_map { |g| g["Thermostats"] }
                       .index_by { |t| t["SerialNumber"] }
      missing = @thermostats.keys - thermostats.keys
      missing.each { |sn| @thermostats.delete(sn) }

      additional = thermostats.keys - @thermostats.keys
      additional.each do |sn|
        @thermostats[sn] = Thermostat.new(self, sn)
      end

      thermostats.each do |sn, json|
        @thermostats[sn].refresh(json)
      end
    end

    # returns nil if nothing changed; otherwise the thermostat that changed
    def long_poll
      response = api.get("notification", sessionid: session_id).body
      json = response["Thermostat"]
      return if json.nil?

      @thermostats[json["SerialNumber"]].tap { |t| t.refresh(json) }
    end

    # !@visibility private
    def api
      reauth
      @api
    end

    private

    def reauth
      return unless expired?

      auth = @api.post("authenticate/user",
                       Email: username,
                       Password: @password,
                       Application: BRANDS[brand]).body
      raise AuthenticationError.create(auth["ErrorCode"]) unless auth["ErrorCode"] == 0 # rubocop:disable Style/NumericPredicate

      @session_id = auth["SessionId"]
      @expires = Time.now + 3600
    end
  end
end
