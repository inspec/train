# encoding: utf-8
#
# Author:: Dominik Richter (<dominik.richter@gmail.com>)

require 'train/version'
require 'train/options'
require 'train/plugins'
require 'train/errors'
require 'train/platforms'
require 'uri'

module Train
  # Create a new transport instance, with the plugin indicated by the
  # given name.
  #
  # @param [String] name of the plugin
  # @param [Array] *args list of arguments for the plugin
  # @return [Transport] instance of the new transport or nil
  def self.create(name, *args)
    cls = load_transport(name)
    cls.new(*args) unless cls.nil?
  end

  # Retrieve the configuration options of a transport plugin.
  #
  # @param [String] name of the plugin
  # @return [Hash] map of default options
  def self.options(name)
    cls = load_transport(name)
    cls.default_options unless cls.nil?
  end

  # Load the transport plugin indicated by name. If the plugin is not
  # yet found in the plugin registry, it will be attempted to load from
  # `train/transports/plugin_name`.
  #
  # @param [String] name of the plugin
  # @return [Train::Transport] the transport plugin
  def self.load_transport(transport_name)
    transport_name = transport_name.to_s
    transport_class = Train::Plugins.registry[transport_name]
    return transport_class unless transport_class.nil?

    # Try to load the transport name from the core transports...
    require 'train/transports/' + transport_name
    return Train::Plugins.registry[transport_name]
  rescue LoadError => _
    begin
      # If it's not in the core transports, try loading from a train plugin gem.
      gem_name = 'train-' + transport_name
      require gem_name
      return Train::Plugins.registry[transport_name]
      # rubocop: disable Lint/HandleExceptions
    rescue LoadError => _
      # rubocop: enable Lint/HandleExceptions
      # Intentionally empty rescue - we're handling it below anyway
    end

    ex = Train::PluginLoadError.new("Can't find train plugin #{transport_name}. Please install it first.")
    ex.transport_name = transport_name
    raise ex
  end

  # Legacy code to unpack a series of items from an incoming Hash
  # Inspec::Config.unpack_train_credentials now handles this in most cases
  def self.target_config(config) # TODO: deprecate
    conf = config.dup
    # Symbolize keys
    conf.keys.each do |key|
      unless key.is_a? Symbol
        conf[key.to_sym] = conf.delete(key)
      end
    end

    group_keys_and_keyfiles(conf) # TODO: move logic into SSH plugin
    return conf if conf[:target].to_s.empty?
    unpack_target_from_uri(conf[:target], conf).merge(conf)
  end

  def self.unpack_target_from_uri(uri_string, opts = {}) # rubocop: disable Metrics/AbcSize
    creds = {}
    return creds if uri_string.empty?

    # split up the target's host/scheme configuration
    uri = parse_uri(uri_string)
    unless uri.host.nil? and uri.scheme.nil?
      creds[:backend]  ||= uri.scheme
      creds[:host]     ||= uri.hostname
      creds[:port]     ||= uri.port
      creds[:user]     ||= uri.user
      creds[:path]     ||= uri.path
      creds[:password] ||=
        if opts[:www_form_encoded_password] && !uri.password.nil?
          URI.decode_www_form_component(uri.password)
        else
          uri.password
        end
    end

    # ensure path is nil, if its empty; e.g. required to reset defaults for winrm # TODO: move logic into winrm plugin
    creds[:path] = nil if !creds[:path].nil? && creds[:path].to_s.empty?

    creds.compact!

    # return the updated config
    creds
  end

  # Parse a URI. Supports empty URI's with paths, e.g. `mock://`
  #
  # @param string [string] URI string, e.g. `schema://domain.com`
  # @return [URI::Generic] parsed URI object
  def self.parse_uri(string)
    URI.parse(string)
  rescue URI::InvalidURIError => e
    # A use-case we want to catch is parsing empty URIs with a schema
    # e.g. mock://. To do this, we match it manually and fake the hostname
    case string
    when %r{^([a-z]+)://$}
      string += 'dummy'
    when /^([a-z]+):$/
      string += '//dummy'
    else
      raise Train::UserError, e
    end

    uri = URI.parse(string)
    uri.host = nil
    uri
  end
  private_class_method :parse_uri

  # Examine the given credential information, and if all is well,
  # return the transport name.
  def self.validate_backend(credentials, default_transport_name = 'local')
    return default_transport_name if credentials.nil?
    result = credentials[:backend]

    if (result == 'local' || result == 'localhost') && credentials[:sudo]
      fail Train::UserError, 'Sudo is only valid when running against a remote host. '\
        'To run this locally with elevated privileges, run the command with `sudo ...`.'
    end

    return result if !result.nil?

    if !credentials[:target].nil?
      # We should not get here, because if target_uri unpacking was successful,
      # it would have set credentials[:backend]
      fail Train::UserError, 'Cannot determine backend from target '\
           "configuration #{credentials[:target_uri].inspect}. Valid example: ssh://192.168.0.1."
    end

    if !credentials[:host].nil?
      fail Train::UserError, 'Host configured, but no backend was provided. Please '\
           'specify how you want to connect. Valid example: ssh://192.168.0.1.'
    end

    credentials[:backend] = default_transport_name
  end

  def self.group_keys_and_keyfiles(conf)
    # in case the user specified a key-file, register it that way
    # we will clear the list of keys and put keys and key_files separately
    keys_mixed = conf[:keys]
    return if keys_mixed.nil?

    conf[:key_files] = []
    conf[:keys] = []
    keys_mixed.each do |key|
      if !key.nil? and File.file?(key)
        conf[:key_files].push(key)
      else
        conf[:keys].push(key)
      end
    end
  end
end
