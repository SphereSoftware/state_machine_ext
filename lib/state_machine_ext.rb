$:.unshift(File.expand_path(File.dirname(__FILE__) + "/../"))
require 'rubygems'
require 'state_machine'
require 'lib/group'
module ExStateMachine

  def self.included(base)
    base.class_eval do
      
      def group(name,&block)
        @groups = [] if @groups.nil?
        group = Group.new(name,self)
        group.instance_eval(&block) if block
        @groups << group
      end
      
      attr_accessor :groups
      alias_method :define_event_helpers_original, :define_event_helpers

      def define_event_helpers
        define_event_helpers_original

        define_instance_method(:group) do |machine,object,request_group|
          group = nil
          @groups.each {|item| group = item if request_group == item.name }
          
          group
        end

        define_instance_method(:find_group) do |machine,object,request_state|
          res = []
          @groups.each do |group|
            res << group.name if group.include?(request_state.to_sym)
          end
          
          res
        end

        next_transitions = []
        request_state = []
        define_instance_method(attribute(:all_transitions)) do |machine, object, *args|
          state = args.empty? ? object.state_name : args.first
          request_state << state

          *args = {:from => args.first} if !(args.empty?)
      
          transitions = machine.events.transitions_for(object, *args)

          transitions.each do |transition|
            unless request_state.include?(transition.to_name)
              next_transition = object.state_all_transitions(transition.to_name)

              next_transitions << next_transition unless next_transition.empty?
            end
            next_transitions << transition
            
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
