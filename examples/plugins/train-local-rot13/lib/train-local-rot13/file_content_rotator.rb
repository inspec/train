# Here's our helper class for the file object.  This is just some
# silliness specific to the task of applying rot13 to the file content.

require 'rot13'

module TrainPlugins
  module LocalRot13
    class FileContentRotator
      # The FileContentRotator has-a Train::File
      def initialize(train_file)
        @train_file = train_file
      end

      # We implement content ourselves, rotating the contents of the file
      def content
        Rot13.rotate(@train_file.content)
      end

      # Everything else, we delegate to the Train::File object.
      # This is not a safe or efficient implementation.
      def method_missing(meth, *args, &block)
        @train_file.send(meth, *args, &block)
      end
    end
  end
end
