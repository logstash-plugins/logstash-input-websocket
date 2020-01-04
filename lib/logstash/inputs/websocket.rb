# encoding: utf-8
require "logstash/inputs/base"
require "logstash/namespace"
require "stud/interval"

# Read events over the websocket protocol.
class LogStash::Inputs::Websocket < LogStash::Inputs::Base
  config_name "websocket"

  default :codec, "json"

  # The URL to connect to.
  config :url, :validate => :string, :required => true

  # The retry interval in seconds connections start with.
  config :retry_initial, :validate => :number, :default => 1

  # The maximum retry interval in seconds backoff will increase too.
  config :retry_max, :validate => :number, :default => 60

  # The number of log entries that have to be processed before
  # the retry interval is reset to retry_initial. This allows
  # connections to quickly recover from a small interruption
  # after we have successfully connected and processed some
  # entries.
  config :retry_reset, :validate => :number, :default => 1

  # Logs responses with the given HTTP status codes as debug instead
  # of warning.
  config :debug_status, :valdate => :array, :default => []

  # Select the plugin's mode of operation. Right now only client mode
  # is supported, i.e. this plugin connects to a websocket server and
  # receives events from the server as websocket messages.
  config :mode, :validate => ["client"], :default => "client"

  def register
    require "ftw"
    require "uri"

    p = URI.parse(@url)
    p.userinfo = "***:***" unless p.userinfo.nil?

    @url_safe = p.to_s
    @interval = @retry_initial
    @agent = FTW::Agent.new
    @processed = 0
  end # def register

  public
  def run(output_queue)
    @logger.info("Starting", :url => @url_safe)
    while !stop?
      run_single(output_queue)
      Stud.stoppable_sleep(@interval) { stop? }
      backoff()
    end # loop
  end # def run

  def stop
    # Force close all connections to escape any blocking reads.
    cleanup()
  end # def stop

  private
  def cleanup()
    @agent.shutdown() rescue nil
  end # def cleanup

  def run_single(output_queue)
    @processed = 0
    r = @agent.websocket!(@url)
    if r.instance_of?(FTW::WebSocket)
      r.each do |payload|
        @codec.decode(payload) do |event|
          decorate(event)
          output_queue << event
          @processed += 1
        end
      end
    elsif r.instance_of?(FTW::Response)
      if @debug_status.include?(r.status)
        @logger.debug("Request failed",
                     :status => r.status_line,
                     :url => @url_safe,
                     :retry => @interval) unless stop?
      else
        @logger.warn("Request failed",
                     :status => r.status_line,
                     :url => @url_safe,
                     :retry => @interval) unless stop?
      end
    else
      @logger.warn("Request unexpected type",
                   :type => r.class.name,
                   :url => @url_safe,
                   :retry => @interval) unless stop?
    end
  rescue EOFError => e
    @logger.debug("Run error ",
                 :exception => e,
                 :url => @url_safe,
                 :retry => @interval) unless stop?
  rescue => e
    @logger.warn("Run error ",
                 :exception => e,
                 :url => @url_safe,
                 :retry => @interval) unless stop?
  ensure
    cleanup()
  end # def run_single

  def backoff()
    if @processed > @retry_reset
      @interval = @retry_initial
    else
      @interval = [@interval * 2, @retry_max].min
    end
  end # def backoff

end # class LogStash::Inputs::Websocket
