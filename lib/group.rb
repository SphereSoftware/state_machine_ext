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
        @machine.states.each do |state|
          @group_states << state if state.name == arg
        end
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
