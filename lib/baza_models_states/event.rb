class BazaModelsStates::Event
  def initialize(args)
    @configurator = args.fetch(:configurator)
    @event_name = args.fetch(:event_name)
    @model_class = args.fetch(:model_class)
  end

  def transition(args)
    from, to = args.first

    from = [from] unless from.is_a?(Array)

    @from = from.map(&:to_s)
    @to = to.to_s

    @from.each do |from|
      register_state(from)
    end

    register_state(@to)

    create_event_method
  end

private

  def register_state(state)
    unless @configurator.states.include?(state)
      @configurator.states << state
    end
  end

  def create_event_method
    configurator = @configurator
    state_attribute_name = configurator.state_attribute_name
    from = @from
    to = @to

    @model_class.__send__(:define_method, @event_name) do
      model_state_from = __send__(state_attribute_name).to_s

      configurator.__send__(:fire_callbacks, self, :before_transition, model_state_from, to)

      unless from.include?(model_state_from)
        raise "Cannot transition from #{model_state_from} to #{to}"
      end

      update_attributes!(state_attribute_name => to)

      configurator.__send__(:fire_callbacks, self, :after_transition, model_state_from, to)
    end
  end
end
