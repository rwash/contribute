module Amazon
  module FPS
    class OutboundSignatureV1
      def initialize(args)
        @args = args
      end

      def validate
        if signature.nil?
          raise "Signature is missing from parameters"
        end
      end

      private

      def signature
        parameters = @args[:parameters]
        signature = "";
        signature = parameters[SIGNATURE_KEYNAME];
      end
    end
  end
end
