# -*- encoding : utf-8 -*-

describe Cardio::Logger::Performance do
  def log_method opts
    Cardio::Logger::Performance.load_config methods: opts
  end

  def expect_logger_to_receive_once message
    allow(Rails.logger).to receive(:info).with(/((?!#{message}).)*/)
    expect(Rails.logger).to receive(:info).once.with(message)
    with_logging { yield }
  end

  def expect_logger_to_receive message
    allow(Rails.logger).to receive(:info)
    Array.wrap(message).each do |msg|
      expect(Rails.logger).to receive(:info).with(msg)
    end
    with_logging { yield }
  end

  def expect_logger_not_to_receive message
    allow(Rails.logger).to receive(:info)
    Array.wrap(message).each do |msg|
      expect(Rails.logger).not_to receive(:info).with(msg)
    end
    with_logging { yield }
  end

  def with_logging
    Cardio::Logger::Performance.start method: 'test'
    yield
    Cardio::Logger::Performance.stop
  end

  it 'creates tree for nested method calls' do
    log_method [:view]
    expect_logger_to_receive(
/\n\
\([\d.]+ms\) test\n\
\s{2}\|--\([\d.]+ms\) process: c1\n\
\s{5}\|--\([\d.]+ms\) view\: core\n\
\s{8}\|--\([\d.]+ms\) view\: raw\n\
content: [\d.]+ms\n\
total: [\d.]+ms\n/
                            ) do
      Card['c1'].format.render_core
    end
  end

  describe 'logger configuration' do
    it 'handles array with method name' do   # log arbitrary card method
      log_method [:content]
      expect_logger_to_receive(/content/) do
        Card[:all].content
      end
    end

    it 'handles instance method type' do
      class Card
        def test _a, _b
          Rails.logger.info("orignal method is still alive")
        end
        def self.test a, b; end
      end
      log_method(
        Card => { :instance => { :test=> { :title=>:name, :message=>2 } } }
      )

      expect_logger_to_receive([/still alive/,/all: magic/]) do
        Card[:all].test "ignore this argument", "magic"
        Card.test "you won't", "get this one"
      end
    end

    it 'handles classes and singleton method type' do
      log_method Card => { singleton: [:fetch] }
      expect_logger_to_receive(/fetch/) do
        Card.fetch 'A', new: {}
      end
    end

    it 'handles different class and singleton method type' do
      log_method( { Cardio => { :singleton=>[:gem_root] } } )
      expect_logger_to_receive(/gem_root/) do
        Cardio.gem_root
      end
    end

    it 'handles method log options' do
      log_method({ Card::Set::Type::CustomizedBootswatchSkin =>
                     {:item_names => {:message=>:content, :title=>"skin item names"}}} )
      expect_logger_to_receive(/skin item names/) do
        Card['classic bootstrap skin'].item_names
        Card['*all+*read'].item_names
      end
    end

    # it 'uses default method log options' do
    #   log_method [:fetch]
    #   expect_logger_to_receive( /fetch: all/ ) do
    #     Card.fetch 'all'
    #   end
    # end

    it 'handles procs and integers for method log options' do  # use method arguments and procs to customize log messages
      log_method( :instance => { :name= => { :title => proc { |method_context| "change name '#{method_context.name}' to"}, :message=>1 } } )
      expect_logger_to_receive_once(/change name 'c1' to: Alfred/) do
        Card['c1'].name = 'Alfred'
      end
    end

    describe 'special methods' do
      # FIXME: this test fails because of the logging stuff above. Need a way to reset the Card class or use test classes in all tests
      # it "doesn't log special methods if disabled" do
#         log_method []
#         expect(Rails.logger).to receive(:wagn).with(/test/).once
#         with_logging  do
#           Card::Auth.as_bot { Card.fetch('c1').update!(:content=>'c1') }
#           Card.search :name=>'all'
#           Card[:all].format.render_raw
#         end
#       end

      it 'logs searches if enabled' do
        log_method [:search]
        expect_logger_to_receive( /search:/ ) do
          Card.search :name=>'all'
        end
      end

      it 'logs views if enabled' do
        log_method [:view]
        expect_logger_to_receive([/process: \*all.+view:/m ] ) do
          Card[:all].format.render_raw
        end
      end

      it 'logs events if enabled' do
        log_method [:event]
        expect_logger_to_receive([/process: c1.+    \|--\([\d.]+ms\) event:/m] ) do
          Card::Auth.as_bot { Card.fetch('c1').update!(:content=>'c1') }
        end
      end
    end
  end

  describe Cardio::Logger::Performance::BigBrother do
    before do
      class TestClass
        extend Cardio::Logger::Performance::BigBrother
        def inst_m; end
        def self.sing_m; end
      end
    end

    describe '#watch_singleton_method' do
      before do
        TestClass.watch_singleton_method :sing_m
      end

      it 'logs singleton method' do
        expect_logger_to_receive_once(/sing_m/) do
          TestClass.sing_m
        end
      end

      it 'does not log instance method' do
        expect_logger_not_to_receive(/inst_m/) do
          TestClass.new.inst_m
        end
      end
    end

    describe '#watch_instance_method' do
      before do
        TestClass.watch_instance_method :inst_m
      end

      it 'logs instance method' do
        expect_logger_to_receive_once(/inst_m/) do
          TestClass.new.inst_m
        end
      end

      it 'does not log singleton method' do
        expect_logger_not_to_receive(/sing_m/) do
          TestClass.sing_m
        end
      end
    end

    describe '#watch_all_singleton_methods' do
      before do
        TestClass.watch_all_singleton_methods
      end
      it 'logs singleton method' do
        expect_logger_to_receive(/sing_m/) do
          TestClass.sing_m
        end
      end
    end

    describe 'watch_all_instance_methods' do
      before do
        TestClass.watch_all_instance_methods
      end

      it 'logs instance method' do
        expect_logger_to_receive(/inst_m/) do
          TestClass.new.inst_m
        end
      end
    end

    describe '#watch_all_methods' do
      before do
        TestClass.watch_all_methods
      end

      it 'logs instance and singleton methods' do
        expect_logger_to_receive(/inst_m.+sing_m/m) do
          TestClass.new.inst_m
          TestClass.sing_m
        end
      end
    end
  end
end
