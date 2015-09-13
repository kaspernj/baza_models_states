module BazaModelsStates
  path = "#{File.dirname(__FILE__)}/baza_models_states"

  autoload :Configurator, "#{path}/configurator"
  autoload :Event, "#{path}/event"

  module Machine
    def self.included(base)
      base.class_eval do
        def self.states(*args, &blk)
          if args.first.is_a?(Symbol)
            state_attribute_name = args.shift
            states_args = args.last || {}
          elsif args.length == 1
            state_attribute_name = :state
            states_args = args.first
          else
            raise "Didn't know how to set state attribute name and state args from: #{args}"
          end

          configurator = BazaModelsStates::Configurator.new(
            state_attribute_name: state_attribute_name,
            model_class: self,
            states_args: states_args
          )
          configurator.instance_eval(&blk)
        end
      end
    end
  end
end
