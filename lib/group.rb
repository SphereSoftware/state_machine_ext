module StateMachineExt

  class InvalidState < StandardError
  end
  
  class Group

    attr_accessor :name

    def initialize(name, parent)
      @machine = parent
      @name = name
      @group_states = []
    end

    def state(*args)
      args.each do |arg|
        is_include = false
        @machine.states.each do |state|
          if state.name == arg
            @group_states << state
            is_include = true
          end
        end
        raise InvalidState, "\"#{arg}\" is an unknown state machine state" unless is_include
      end
    end

    def include?(state)
      group_state = @group_states.detect {|item| item.name == state}
      group_state.nil? ? false : true
    end
    
  end

end
