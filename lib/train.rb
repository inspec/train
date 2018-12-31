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

  # Resolve target configuration, using information in the config object.
  # in URI-scheme. respective fields and merge with existing configuration.
  # e.g. ssh://bob@remote  =>  backend: ssh, user: bob, host: remote
  def self.unpack_target_creds(config = nil) # rubocop:disable Metrics/AbcSize
    unless config.respond_to?(:target_uri)
      return target_config(config)
    end

    # A set of connecting information that will make sense to
    # the selected transports. Different transports expect different
    # keys here.
    credentials = { target: config.target_uri }
    return credentials if config.target_uri.empty?

    # Look for transport://credset format
    %r{^(?<transport_name>[a-z_\-0-9]+)://(?<cred_set_name>[a-z_\-0-9]*)$} =~ config.target_uri

    unless transport_name
      # We must need to parse from a more complex URI
      return credentials.merge(unpack_target_from_uri(config.target_uri)) # TODO: dubious
    end

    transport_name = transport_name.to_sym
    credentials[:backend] = transport_name

    transport_class = load_transport(transport_name)
    credentials.merge(config.fetch_credentials(
      transport_name,
      cred_set_name.to_sym,
      option_defaults: transport_class.credential_option_defaults,
    ))
    # TODO: we could ask the transport class to validate / preflight the credset
    #  (Inspec::Backend#create calls Train.validate_backend)
  end

  # Legacy code to unpack a series of items from an incoming Hash
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
    return (unpack_target_from_uri(conf[:target], conf)).merge(conf)
  end

  def self.unpack_target_from_uri(uri_string, opts = {})
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
  def self.validate_backend(credentials, default_transport_name = :local)
    return default_transport_name if credentials.nil?
    result = credentials[:backend]

    if (result.nil? || result == 'localhost') && credentials[:sudo]
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
