$:.unshift(File.expand_path(File.dirname(__FILE__) + "/../"))
require 'rubygems'
require 'state_machine'
require 'lib/group'

module StateMachineExt

  class InvalidGroup < StandardError
  end
  
  def self.included(base)
    base.class_eval do

      def group(name, &block)
        @groups = [] if @groups.nil?
        group = @groups.detect {|item| item.name == name}
        @groups << group = Group.new(name,self) if group.nil?
        group.instance_eval(&block) if block
      end
      
      attr_accessor :groups
      alias_method :define_event_helpers_original, :define_event_helpers

      def define_event_helpers
        define_event_helpers_original

        # Define the method that returns the group with the given name
        define_instance_method(:group) do |machine, object, request_group|
          group = nil
          group = @groups.detect {|item| item.name == request_group}
          if group.nil?
            raise InvalidGroup, "\"#{request_group}\" is an unknown state machine group"
          end
          
          group
        end

        # Define the method that returns the state machine's group for the given
        # state
        define_instance_method(:find_group) do |machine, object, request_state|
          @groups.inject([]) do |res,group|
            res << group.name if group.include?(request_state.to_sym)
            res
          end
        end

        #Define the method that returns all states which can be reached
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
            next_transition = 
              return_transition(next_transitions, request_state,
              machine, object, transition.to_name)
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
