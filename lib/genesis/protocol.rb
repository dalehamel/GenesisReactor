module Genesis
  # Use some metaprogramming to DRY up protocol definition
  module Protocol
    def self.included(base) # rubocop:disable Metrics/MethodLength
      class << base
        def included(base)
          protocol = self
          base.define_singleton_method(:protocol) { protocol.protocol }
        end

        def load
          Kernel.const_get((to_s.split('::')[0..-2] << 'Server').join('::'))
        end

        def start_block
        end
      end
    end
  end
end
