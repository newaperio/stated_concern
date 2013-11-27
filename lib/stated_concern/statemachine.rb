module StateMachine
  extend ActiveSupport::Concern

  included do
    define_model_callbacks :transition

    scope :with_state, ->(state) { where(state: state) }
  end

  module ClassMethods
    def states(states)
      const_set('STATES', states)

      states.each do |state|
        scope "in_#{state}".to_sym, -> { with_state(state) }

        delegate "#{state}?".to_sym, to: :current_state
      end

      class_eval do
        def can_transition?(options)
          raise ArgumentError, '`transition_matrix` must be defined by the model.' unless defined? transition_matrix
          raise ArgumentError, 'Transition requires a target' unless options[:to]
          to_state = options[:to]
          to_state = to_state.to_s unless to_state.is_a?(String)
          raise ArgumentError, 'Undefined state' unless self.class.const_get('STATES').include? to_state

          transition_matrix(to_state)
        end
      end
    end
  end

  def current_state
    state.inquiry
  end

  def transition(options)
    run_callbacks :transition do
      raise ArgumentError, 'Transition requires a target' unless options[:to]
      to_state = options[:to]
      to_state = to_state.to_s unless to_state.is_a?(String)

      if can_transition?(to: to_state)
        update_attribute(:state, to_state)
      else
        raise RuntimeError, 'Improper state transition'
      end
    end
  end
end
