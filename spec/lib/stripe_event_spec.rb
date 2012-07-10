require 'spec_helper'

describe StripeEvent do
  before { StripeEvent.clear_subscribers! }
  
  context "configuration" do
    it "yields itself to the block" do
      expect { |block|
        StripeEvent.configure(&block)
      }.to yield_with_args(StripeEvent)
    end
    
    it "should return itself" do
      value = StripeEvent.configure { |c| }
      value.should == StripeEvent
    end
  end
  
  context "subscribing" do
    let(:event_type) { 'charge.failed' }
    
    it "should register a subscriber" do
      subscriber = StripeEvent.subscriber(event_type) { }
      StripeEvent.subscribers(event_type).should == [subscriber]
    end
    
    it "should register a subscriber for many event types" do
      event_types = StripeEvent::TYPES[0,3]
      subscriber = StripeEvent.subscriber(*event_types) { }
      event_types.each do |type|
        StripeEvent.subscribers(type).should == [subscriber]
      end
    end
    
    it "should require a valid event type" do
      expect {
        StripeEvent.subscriber('fake.event_type') { }
      }.to raise_error(StripeEvent::InvalidEventType)
    end
    
    it "should clear all subscribers" do
      StripeEvent.subscriber(event_type) { }
      StripeEvent.clear_subscribers!
      StripeEvent.subscribers(event_type).should be_empty
    end
  end
  
  context "publishing" do
    let(:event_type) { 'transfer.created' }
    let(:event) { double("event", :type => event_type) }
    
    it "should only pass the event to the subscribed block" do
      expect { |block|
        StripeEvent.subscriber(event_type, &block)
        StripeEvent.publish(event)
      }.to yield_with_args(event)
    end
  end
end
