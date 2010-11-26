require 'rubygems'
require 'state_machine'

module ExStateMachine

  def self.included(base)
    base.class_eval do
      alias_method :define_event_helpers_original, :define_event_helpers

      def define_event_helpers
        define_event_helpers_original

        next_transitions = []
        define_instance_method(attribute(:all_transitions)) do |machine, object, *args|
          *args = {:from => args[0]} if !(args.empty?)
      
          transitions = machine.events.transitions_for(object, *args)

          transitions.each do |transition|
            unless transition.to == object.state
              next_transition = object.state_all_transitions(transition.to_name)

              next_transitions << next_transition unless next_transition.empty?
              next_transitions << transition
            end
          end

          res = []
          next_transitions.each do |trans|
            res << trans.to_name unless trans.is_a?(Array)
          end

          res.uniq
        end
      end
    end
  end

end

class StateMachine::Machine
  include ExStateMachine
end
