require "logstash/devutils/rspec/spec_helper"
require "logstash/inputs/websocket"

describe LogStash::Inputs::Websocket do

  context "when url option isn't set" do
    subject { LogStash::Inputs::Websocket.new() }

    it "should raise exception" do
      expect { subject.register }.to raise_error(LogStash::ConfigurationError)
    end
  end

  context "when attempting to enable server mode" do
    subject {
      LogStash::Inputs::Websocket.new("url" => "http://example.com",
                                      "mode" => "server")
    }

    it "should raise exception" do
      expect { subject.register }.to raise_error(LogStash::ConfigurationError)
    end
  end

end
