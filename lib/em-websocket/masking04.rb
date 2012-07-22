require 'xor'
module EventMachine
  module WebSocket
    class MaskedString < String
      MASK_SIZE = 4
      # Read a 4 byte XOR mask - further requested bytes will be unmasked
      def read_mask
        if respond_to?(:encoding) && encoding.name != "ASCII-8BIT"
          raise "MaskedString only operates on BINARY strings"
        end
        raise "Too short" if bytesize < MASK_SIZE # TODO - change
        @masking_key = String.new(self[0, MASK_SIZE])
      end

      # Removes the mask, behaves like a normal string again
      def unset_mask
        @masking_key = nil
      end

      def slice_mask
        slice!(0, MASK_SIZE)
      end

      def getbyte(index)
        if @masking_key
          masked_char = super
          masked_char ? masked_char ^ @masking_key.getbyte(index % MASK_SIZE) : nil
        else
          super
        end
      end

      def getbytes(start_index, count)
        data = slice(start_index, count)
        data.xor! @masking_key[start_index % MASK_SIZE..-1].
            ljust(count, @masking_key) if @masking_key
        data
      end

    end
  end
end
