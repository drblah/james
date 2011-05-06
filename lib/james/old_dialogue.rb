module James

  module Dialogue

    def self.included into
      into.extend ClassMethods
    end

    # We heard phrase.
    #
    def hear phrase
      transition phrase
    end
    def exit phrase
      self.send :"exit_#{name}", phrase if self.respond_to? :"exit_#{name}"
    end
    def enter
      self.send :"enter_#{name}" if self.respond_to? :"enter_#{name}"
    end
    def transition phrase
      # Call exit method.
      #
      yield state.exit dialogue, phrase if block_given?

      # TODO Say response?
      #
      p [state.transitions, phrase]
      state_id = state.next_for(phrase)
      p state_id
      @state = state_for state_id

      # Call entry method.
      #
      yield enter dialogue if block_given?
    end

    # next possible phrases
    # TODO splat
    def expects
      state.hooks
    end

    #
    #
    def state_for name
      self.class.state_for name
    end

    module ClassMethods

      # Defines the hooks into the main dialogue.
      #
      def hooks *sentences
        define_method :hooks do
          sentences
        end
        # self.class_eval do
        #   # set entry state correctly
        #   entry = {}
        #   hooks.each do |hook|
        #     entry[hook] = self.initial
        #   end
        #   # add states class variable
        #   class <<self
        #     attr_accessor :states
        #   end
        #   self.states ||= {}
        #   self.states[:entry] = entry
        #   # define an instance method
        #   define_method(:hooks) do
        #     hooks
        #   end
        # end
      end

      # Defines a state with transitions.
      #
      # state :name, { states }
      #
      attr_reader :states
      def state name, transitions = {}
        @states       ||= {}
        @states[name] ||= {}

        # Lazily create states.
        #
        @states[name] = transitions
      end
      def state_for name
        # Lazily wrap.
        #
        if @states[name].respond_to?(:each)
          @states[name] = State.new(name, @states[name])
        end

        @states[name]
      end

      # Defines the initial hook state.
      #
      def initial name
        define_method :state do
          @state ||= self.class.state_for name
        end
      end

    end

  end

end