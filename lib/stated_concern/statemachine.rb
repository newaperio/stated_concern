require 'active_support/concern'

module StateMachine
  extend ActiveSupport::Concern

  included do
    define_model_callbacks :transition

    scope :with_state, ->(state) { where(state: states[state]) }
  end

  module ClassMethods
    def states(states)
      enum state: states

      class_eval do
        def can_transition?(options)
          raise UndefinedTransitionError unless defined? transition_matrix
          raise UndefinedTargetError unless options[:to]
          to_state = options[:to]
          to_state = to_state.to_s unless to_state.is_a?(String)
          raise UndefinedStateError unless self.class.states.include? to_state

          transition_matrix(to_state)
        end
      end
    end
  end

  def transition(options)
    run_callbacks :transition do
      raise UndefinedTargetError unless options[:to]
      to_state = options[:to]
      to_state = to_state.to_s unless to_state.is_a?(String)

      if can_transition?(to: to_state)
        update_attribute(:state, to_state)
      else
        raise ImproperStateTransitionError
      end
    end
  end
end
