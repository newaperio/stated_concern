module StateMachine
  class UndefinedTransitionError < StandardError; end
  class UndefinedTargetError < StandardError; end
  class UndefinedStateError < StandardError; end
  class ImproperStateTransitionError < StandardError; end
end
