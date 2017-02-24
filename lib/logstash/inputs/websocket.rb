# encoding: utf-8
require "logstash/inputs/base"
require "logstash/namespace"
require "socket"


# Read events over the websocket protocol.
class LogStash::Inputs::Websocket < LogStash::Inputs::Base
  config_name "websocket"

  default :codec, "json"

  # The URL to connect to.
  config :url, :validate => :string, :required => true

  # Select the plugin's mode of operation. Right now only client mode
  # is supported, i.e. this plugin connects to a websocket server and
  # receives events from the server as websocket messages.
  config :mode, :validate => ["client"], :default => "client"

  # Some websocket APIs require that you send a subscribe message of
  # some kind when you have connected in order to recieve any
  # data. Set a value here if you would like this client to 
  # send a message to the websocket server on connect.
  config :on_connect, :validate => :string, :required => false
  
  def register
    require "ftw"
  end # def register

  public
  def run(output_queue)
    agent = FTW::Agent.new
    begin
      websocket = agent.websocket!(@url)
      
      if @on_connect && @on_connect != ""
        websocket.publish(@on_connect)
      end # if
  
      websocket.each do |payload|
        @codec.decode(payload) do |event|
          decorate(event)
          output_queue << event
        end
      end
    rescue => e
      @logger.warn("websocket input client threw exception, restarting",
                   :exception => e)
      sleep(1)
      retry
    end # begin
  end # def run

end # class LogStash::Inputs::Websocket
