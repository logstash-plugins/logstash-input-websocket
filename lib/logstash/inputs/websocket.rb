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

  # Retry interval.
  config :retry, :validate => :number, :default => 1

  # Select the plugin's mode of operation. Right now only client mode
  # is supported, i.e. this plugin connects to a websocket server and
  # receives events from the server as websocket messages.
  config :mode, :validate => ["client"], :default => "client"

  def register
    require "ftw"
  end # def register

  public
  def run(output_queue)
    agent = FTW::Agent.new
    begin
      websocket = agent.websocket!(@url)
      websocket.each do |payload|
        @codec.decode(payload) do |event|
          decorate(event)
          output_queue << event
        end
      end
    rescue => e
      @logger.warn("websocket input client threw exception, restarting",
                   :exception => e)
      # Ensure all connections are cleaned up before retrying.
      begin
        agent.shutdown()
      rescue => e
        @logger.warn("websocket input client exception on shutdown",
                     :exception => e)
      end
      sleep(@retry)
      retry
    ensure
      # Ensure all connections are cleaned up.
      agent.shutdown()
    end # begin
  end # def run

end # class LogStash::Inputs::Websocket
