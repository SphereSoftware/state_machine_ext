module ExStateMachine

  class Group

    def initialize(name,parent)
      @machine = parent
      @name = name
      @group_states = []
    end

    attr_accessor :name
    def state(*args)
      args.each do |arg|
        is_include = false
        @machine.states.each do |state|
          if state.name == arg
            @group_states << state
            is_include = true
          end
        end
        raise "There is no such state in this state machine #{arg}" unless is_include
      end
    end

    def include?(state)
      @group_states.each do |item|
        return true if item.name == state
      end
      return false
    end
  end

end
