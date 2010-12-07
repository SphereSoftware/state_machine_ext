$:.unshift(File.expand_path(File.dirname(__FILE__) + "/../"))
require 'rubygems'
require 'state_machine'
require 'lib/group'
module StateMachineExt

  def self.included(base)
    base.class_eval do
      
      def group(name, &block)
        @groups = [] if @groups.nil?
        group = Group.new(name, self)
        group.instance_eval(&block) if block
        @groups << group
      end
      
      attr_accessor :groups
      alias_method :define_event_helpers_original, :define_event_helpers

      def define_event_helpers
        define_event_helpers_original

        #Define the method that return the group with the given name
        define_instance_method(:group) do |machine, object, request_group|
          group = nil
          group = @groups.detect {|item| item.name == request_group}
          if group.nil?
            raise "There is no group with such name as #{request_group}\
in this state machine"
          end
          
          group
        end

        #Define the method that return the state machine's group for the given
        #state
        define_instance_method(:find_group) do |machine, object, request_state|
          res = []
          @groups.each do |group|
            res << group.name if group.include?(request_state.to_sym)
          end
          
          res
        end

        #Define the method that return all states which can be reached
        #from the given one
        define_instance_method(attribute(:all_transitions)) do |machine, object, *args|
          next_transitions = []
          request_state = []
         
          transitions = return_transition(next_transitions, request_state, machine, object, *args)

          res = []
          transitions.each do |trans|
            res << trans.to_name unless trans.is_a?(Array)
          end

          res.uniq
        end

      end
      
      def return_transition(next_transitions, request_state, machine, object, *args)
        state = args.empty? ? object.state_name : args.first
        request_state << state

        *args = {:from => args.first} unless args.empty?
        transitions = machine.events.transitions_for(object, *args)

        transitions.each do |transition|
          unless request_state.include?(transition.to_name)
            next_transition = return_transition(next_transitions, request_state, machine, object, transition.to_name)
            next_transitions << next_transition unless next_transition.empty?
          end
          next_transitions << transition
        end

        next_transitions
      end
      private :return_transition
    end
  end

end

class StateMachine::Machine
  include StateMachineExt
end
