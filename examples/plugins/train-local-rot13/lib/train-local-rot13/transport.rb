


require 'train-local-rot13/connection'
require 'train-local-rot13/platform'

# Train Plugins v1 are usually declared under the Train::Trainsports namespace.
# That's a bit misleading, as each plugin has three components: Transport, Connection, and Platform.
# We'll only define the Transport here, but we'll refer to the others.
module Train::Transports
  module LocalRot13
    class Transport < Train.plugin(1)

      name :'local-rot13'

      # In here, you have access to `logger`,
    end
  end
end