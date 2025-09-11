# Kubernetes Transport

The Kubernetes transport provides a unified interface to interact with Kubernetes clusters through Train. It uses kubectl commands under the hood to execute operations and access cluster resources.

## Features

- **Kubeconfig Support**: Automatic detection and validation of kubeconfig files
- **Cluster Endpoint**: Direct connection to cluster API endpoints
- **Command Execution**: Execute kubectl commands through Train's `run_command` interface
- **Resource Access**: Access ConfigMaps, Secrets, and container logs via Train's file interface
- **Platform Detection**: Proper platform identification within Train's family hierarchy
- **Error Handling**: Comprehensive error management with meaningful messages
- **Security**: Secure credential handling and sanitized error output

## Installation

The Kubernetes transport is included with Train core. Ensure you have kubectl installed and accessible in your PATH.

### Prerequisites

- kubectl command-line tool installed
- Valid kubeconfig file or cluster endpoint access
- Appropriate cluster permissions for the operations you want to perform

## Configuration Options

| Option | Default | Description |
|--------|---------|-------------|
| `kubeconfig_path` | `~/.kube/config` | Path to the kubeconfig file |
| `cluster_endpoint` | `nil` | Direct cluster endpoint URL (overrides kubeconfig) |
| `namespace` | `default` | Default namespace for operations |
| `timeout` | `30` | Timeout in seconds for kubectl operations |

## Usage Examples

### Basic Connection

```ruby
require 'train'

# Using default kubeconfig
transport = Train.create('kubernetes')
connection = transport.connection
```

### Custom Configuration

```ruby
require 'train'

# Using custom kubeconfig file
transport = Train.create('kubernetes', 
  kubeconfig_path: '/path/to/custom/kubeconfig',
  namespace: 'production',
  timeout: 60
)
connection = transport.connection
```

### Direct Cluster Connection

```ruby
require 'train'

# Direct cluster endpoint (bypasses kubeconfig)
transport = Train.create('kubernetes',
  cluster_endpoint: 'https://k8s-cluster.example.com:6443',
  namespace: 'staging'
)
connection = transport.connection
```

## Command Execution

Execute kubectl commands using Train's standard `run_command` interface:

```ruby
connection = transport.connection

# Get pods
result = connection.run_command('kubectl get pods')
puts result.stdout

# Get specific resource with output format
result = connection.run_command('kubectl get deployment my-app -o yaml')
puts result.stdout

# Check command success
if result.exit_status == 0
  puts "Command succeeded"
else
  puts "Command failed: #{result.stderr}"
end
```

## File Interface

Access Kubernetes resources through Train's file interface:

### ConfigMaps

```ruby
connection = transport.connection

# Access ConfigMap data
config_file = connection.file('/configmap/default/my-config/app.yml')

if config_file.exist?
  puts "ConfigMap exists"
  puts "Content: #{config_file.content}"
  puts "Size: #{config_file.size} bytes"
end
```

### Secrets

```ruby
connection = transport.connection

# Access Secret data (automatically base64 decoded)
secret_file = connection.file('/secret/default/my-secret/password')

if secret_file.exist?
  puts "Secret exists"
  puts "Password: #{secret_file.content}"
end
```

### Container Logs

```ruby
connection = transport.connection

# Access container logs
log_file = connection.file('/logs/default/my-pod/my-container')

if log_file.exist?
  puts "Recent logs:"
  puts log_file.content
end

# Access logs with tail option
log_file_tail = connection.file('/logs/default/my-pod/my-container?tail=100')
puts log_file_tail.content
```

## File Path Formats

The Kubernetes transport supports the following file path formats:

### ConfigMaps
```
/configmap/<namespace>/<configmap-name>/<key>
```

### Secrets
```
/secret/<namespace>/<secret-name>/<key>
```

### Container Logs
```
/logs/<namespace>/<pod-name>/<container-name>
/logs/<namespace>/<pod-name>/<container-name>?tail=<lines>
```

## Platform Detection

The Kubernetes transport registers itself in Train's platform hierarchy:

```ruby
connection = transport.connection
platform = connection.platform

puts platform.name           # => "kubernetes"
puts platform.family         # => "cloud" 
puts platform.family_hierarchy # => ["cloud", "api"]
```

## Error Handling

The transport provides comprehensive error handling:

```ruby
begin
  connection = transport.connection
  result = connection.run_command('kubectl get invalid-resource')
rescue Train::TransportError => e
  puts "Transport error: #{e.message}"
  # Error messages are sanitized to not expose credentials
end
```

### Common Error Scenarios

1. **kubectl not found**: Ensure kubectl is installed and in PATH
2. **Invalid kubeconfig**: Verify kubeconfig file exists and is readable
3. **Cluster unreachable**: Check network connectivity and cluster endpoint
4. **Insufficient permissions**: Verify RBAC permissions for required operations
5. **Invalid namespace**: Ensure specified namespace exists in the cluster

## Security Considerations

- Credentials and sensitive information are never exposed in error messages
- Kubeconfig files are validated for existence and readability before use
- All kubectl operations respect the permissions of the configured user/service account
- SSL/TLS verification is handled by kubectl based on kubeconfig settings

## Troubleshooting

### Debug kubectl connectivity
```bash
# Test kubectl access manually
kubectl cluster-info
kubectl get namespaces
```

### Verify kubeconfig
```bash
# Check current context
kubectl config current-context

# View kubeconfig
kubectl config view
```

### Enable verbose logging
```ruby
# Set environment variable for kubectl debugging
ENV['KUBECTL_VERBOSE'] = '1'
transport = Train.create('kubernetes')
```

### Common Issues

**Issue**: "kubectl command not found"
**Solution**: Install kubectl and ensure it's in your PATH

**Issue**: "Unable to connect to cluster"
**Solution**: Verify cluster endpoint and network connectivity

**Issue**: "ConfigMap not found"
**Solution**: Check namespace and ConfigMap name, verify it exists with `kubectl get configmap -n <namespace>`

**Issue**: "Permission denied"
**Solution**: Verify RBAC permissions for the authenticated user/service account

## InSpec Integration

When using with InSpec, the Kubernetes transport enables cluster resource testing:

```ruby
# In an InSpec profile
describe kubernetes.pods('default') do
  its('count') { should be > 0 }
end

describe kubernetes.configmap('default', 'my-config') do
  it { should exist }
  its('data.app_config') { should_not be_empty }
end
```

## Examples

See the `examples/` directory for complete usage examples and sample InSpec profiles using the Kubernetes transport.
