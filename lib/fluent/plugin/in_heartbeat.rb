require 'fluent/plugin/input'
require 'date'

module Fluent::Plugin
  class Heartbeat < Input
    Fluent::Plugin.register_input('heartbeat', self)

    config_param :coloId, :string
    config_param :interval, :integer
    config_param :tag, :string

    config_param :mdsd, :bool, default: false

    config_param :coloRegion, :string, default: ""
    config_param :buildVersion, :string, default: ""

    helpers :timer

    def start
      super

      timer_execute(:heartbeat_timer, interval) {
        time = Fluent::Engine.now

        if mdsd
          record = {
            "message"=>"HEARTBEAT from a #{coloRegion} fluentd at #{Time.at(time)} UTC", 
            "servicedeploymentinstance" => coloId,
            "buildVersion" => buildVersion,
            "format" => "json",
            "level" => "info"
          }
        elsif
          record = {"message"=>"{\"timestamp\":#{time.to_s}, \"event\":\"heartbeat\", \"data\":{\"coloManagerId\":\"#{coloId}\"}}"}
        end
        
        router.emit(tag, time, record)
      }
    end
  end
end
