class BazaModelsStates::Configurator
  attr_reader :callbacks, :state_attribute_name, :states

  def initialize(args)
    @args = args
    @model_class = args.fetch(:model_class)
    @state_attribute_name = args.fetch(:state_attribute_name)
    @states = []

    raise "Invalid state attribute name: #{@state_attribute_name}" unless @state_attribute_name.is_a?(Symbol)

    set_initial_state_callback if @args.fetch(:states_args)[:initial]

    @model_class = @model_class

    @callbacks = {
      before_transition: [],
      after_transition: [],
      around_transition: [],
      failure: []
    }

    @events = []
  end

  def set_initial_state_callback
    @model_class.after_initialize do |model|
      model.assign_attributes(@state_attribute_name => @args.fetch(:states_args).fetch(:initial).to_s)
    end
  end

  def before_transition(requirements, args = {}, &blk)
    @callbacks.fetch(:before_transition) << {requirements: requirements, block: blk, args: args}
  end

  def after_transition(event_name, args = {}, &blk)
    @callbacks.fetch(:after_transition) << {requirements: requirements, block: blk, args: args}
  end

  def event(event_name, &blk)
    event = BazaModelsStates::Event.new(
      configurator: self,
      event_name: event_name,
      model_class: @model_class
    )
    event.instance_eval(&blk)

    @events << event
  end

private

  def fire_callbacks(model, callback_name, from, to)
    event_name = event_name.to_s

    callbacks = @callbacks.fetch(callback_name)

    callbacks.each do |callback|
      requirement_from, requirement_to = callback.fetch(:requirements).first

      requirement_from = [requirement_from] unless requirement_from.is_a?(Array)
      requirement_from.map!(&:to_s)

      requirement_to = [requirement_to] unless requirement_to.is_a?(Array)
      requirement_to.map!(&:to_s)

      if requirement_from.include?(from) && requirement_to.include?(to)
        if callback[:block]
          callback.fetch(:block).call(model)
        elsif callback[:method_name]
          model.__send__(callback.fetch(:method_name))
        else
          raise "Didn't know how to call callback: #{callback}"
        end
      end
    end
  end
end
