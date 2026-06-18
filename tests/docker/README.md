# 🐳 Docker Testing for pTTY

> Fast, local testing without cloud infrastructure dependency

## 🎯 Overview

Docker-based testing provides a **fast alternative** to Oracle Cloud testing. Perfect for:
- **Local development** and debugging
- **Quick validation** before cloud testing
- **CI/CD pipelines** that need fast feedback
- **Offline testing** without internet dependency

## ⚡ Quick Start

### One-Command Testing
```bash
# Run all tests (builds + tests + cleanup)
cd tests/docker
./test-local.sh test

# Interactive testing mode
./test-local.sh interactive
```

### Available Commands
```bash
./test-local.sh build         # Build Docker images
./test-local.sh start         # Start test environment
./test-local.sh test          # Run automated tests
./test-local.sh interactive   # Interactive testing mode
./test-local.sh shell         # Enter client container
./test-local.sh server-shell  # Enter server container
./test-local.sh stop          # Stop containers
./test-local.sh clean         # Clean up everything
```

## 🏗️ Architecture

### Multi-Container Setup
```
┌─────────────────┐    SSH    ┌─────────────────┐
│   tmux-client   │ ─────────▶│  tmux-server    │
│                 │           │                 │
│ - SSH aliases   │           │ - Ubuntu 24.04  │
│ - Test scripts  │           │ - tmux-console  │
│ - Automated     │           │ - Multi-users   │
│   testing       │           │ - SSH daemon    │
└─────────────────┘           └─────────────────┘

Optional:
┌─────────────────┐
│  tmux-server2   │  (Multi-server testing)
│                 │
│ - Second server │
│ - Cross-server  │
│   SSH testing   │
└─────────────────┘
```

### Network Configuration
- **Network**: `tmux-test-net` (172.25.0.0/24)
- **Server Port**: 2222 (SSH from host)
- **Server2 Port**: 2223 (Multi-server mode)

## 🚀 Usage Examples

### 1. Quick Development Testing
```bash
# Make changes to src/
vim ../../src/tmux.conf

# Test immediately
./test-local.sh test
```

### 2. Interactive Testing with SSH Shortcuts
```bash
# Start environment
./test-local.sh start

# Enter client container
./test-local.sh shell

# Use super-short SSH commands:
ssh c1      # Direct to console-1
ssh c2      # Direct to console-2
ssh menu    # Interactive menu
ssh dev     # Connect as devuser
```

### 3. Multi-Server Testing
```bash
# Start with multiple servers
./test-local.sh start multi

# Test server-to-server connections
docker exec tmux-test-server ssh tmux-server2
```

### 4. Host-Based Testing
```bash
# Start environment
./test-local.sh start

# Connect from your host machine
ssh -p 2222 testuser@localhost  # Password: testpassword
ssh -p 2222 devuser@localhost   # Password: devpassword
```

## 🔧 SSH Configuration

### Pre-configured Shortcuts in Client Container

| Shortcut | Target | Description |
|----------|--------|-------------|
| `ssh server` | testuser@tmux-server | Main connection |
| `ssh c1` | console-1 | Direct to console-1 |
| `ssh c2` | console-2 | Direct to console-2 |
| `ssh c3` | console-3 | Direct to console-3 |
| `ssh menu` | connect-console | Interactive menu |
| `ssh dev` | devuser@tmux-server | Connect as devuser |
| `ssh root` | root@tmux-server | Admin access |

### User Accounts

| User | Password | Purpose |
|------|----------|---------|
| `testuser` | `testpassword` | Main test user with tmux-console |
| `devuser` | `devpassword` | Second user for multi-user testing |
| `root` | `testpassword` | Administrative access |
| `client` | `clientpass` | Client container user |

## 🧪 Testing Capabilities

### Automated Tests

The Docker environment runs comprehensive tests:

1. **SSH Connectivity** - Verify SSH connections work
2. **Session Creation** - Check all 7 console sessions exist
3. **Script Availability** - Verify connect-console and setup scripts
4. **Multi-user Support** - Test multiple users have tmux sessions
5. **Function Keys** - Test tmux configuration is loaded
6. **Host Access** - Test SSH from host machine
7. **Cross-server** - Test server-to-server connections (multi mode)

### Manual Testing Scenarios

#### Basic Session Testing
```bash
# Enter client container
./test-local.sh shell

# Test different connection methods
ssh c1              # Quick console-1 access
ssh menu            # Interactive menu
ssh server          # Full server access
```

#### Multi-User Testing
```bash
# Test as different users
ssh dev             # Connect as devuser
ssh root            # Connect as root

# Check session isolation
ssh dev -t "tmux ls"    # devuser sessions
ssh server -t "tmux ls" # testuser sessions
```

#### Function Key Testing
```bash
# Connect to any console
ssh c1

# Test function key switching
# Ctrl+F2 -> console-2
# Ctrl+F3 -> console-3
# Ctrl+F12 -> session list
# Ctrl+F8 -> disconnect
```

#### Server-to-Server Testing
```bash
# Start multi-server mode
./test-local.sh start multi

# Test cross-server SSH
docker exec tmux-test-server ssh tmux-server2
```

## 🎯 CI/CD Integration

### GitHub Actions Workflow

The Docker testing integrates with GitHub Actions (`.github/workflows/docker-test.yml`):

- **Triggers**: Push to main, PRs, manual dispatch
- **Duration**: ~10-15 minutes (much faster than cloud)
- **Features**: Automated + multi-server testing
- **Cost**: Free (runs on GitHub runners)

### Comparison: Docker vs Oracle Cloud

| Feature | Docker Testing | Oracle Cloud Testing |
|---------|---------------|---------------------|
| **Speed** | ~5 minutes | ~20 minutes |
| **Setup** | Zero config | Oracle credentials |
| **Cost** | Free | Free (but limited) |
| **Network** | Local only | Real internet |
| **Persistence** | Container lifecycle | True persistence |
| **Use Case** | Development, CI | Production validation |

## 🔧 Configuration Files

### Docker Compose Structure
```
tests/docker/
├── docker-compose.yml      # Main orchestration
├── Dockerfile.server       # Test server image
├── Dockerfile.client       # Test client image
├── test-local.sh           # Test runner script
└── README.md               # This file
```

### Environment Variables

The containers support these environment variables:

```yaml
environment:
  - TZ=UTC                  # Timezone
  - DEBUG=true              # Enable debug mode
  - TMUX_SESSIONS=7         # Number of sessions (default: 7)
```

### Volume Mounts

```yaml
volumes:
  # Live source code testing
  - ../../src:/opt/tmux-persistent-console/src:ro
  - ../../install.sh:/opt/tmux-persistent-console/install.sh:ro

  # Persistent sessions (optional)
  - tmux-sessions:/tmp/tmux-sessions
```

## 🚨 Troubleshooting

### Common Issues

#### "Connection refused"
```bash
# Check containers are running
docker-compose ps

# Check network connectivity
docker exec tmux-test-client ping tmux-server
```

#### "Permission denied (publickey)"
```bash
# The containers use password authentication
# Default passwords:
#   testuser: testpassword
#   devuser: devpassword
#   root: testpassword
```

#### "No sessions found"
```bash
# Enter server and check
docker exec tmux-test-server bash

# Check if installation ran
su - testuser -c "tmux ls"

# Reinstall if needed
su - testuser -c "curl -sSL https://raw.githubusercontent.com/zentala/pTTY/main/install.sh | bash"
```

#### "Port already in use"
```bash
# Check what's using port 2222
sudo netstat -tulpn | grep 2222

# Stop existing containers
./test-local.sh clean

# Try again
./test-local.sh start
```

### Debug Mode

Enable verbose logging:

```bash
# Set debug environment
export DEBUG=1

# Run with verbose output
./test-local.sh test

# Check container logs
./test-local.sh logs
```

### Manual Debugging

```bash
# Enter containers for manual inspection
./test-local.sh server-shell   # Server container
./test-local.sh shell          # Client container

# Check SSH configuration
docker exec tmux-test-client cat /home/client/.ssh/config

# Check tmux sessions
docker exec tmux-test-server su - testuser -c "tmux ls"
```

## 🔄 Development Workflow

### Test-Driven Development

```bash
# 1. Make changes
vim ../../src/tmux.conf

# 2. Quick test
./test-local.sh test

# 3. Interactive verification
./test-local.sh interactive

# 4. Clean up
./test-local.sh clean
```

### Integration with Main Tests

Docker testing complements Oracle Cloud testing:

1. **Docker first**: Fast local validation
2. **Oracle Cloud**: Production-like validation
3. **Both in CI**: Comprehensive coverage

## 🎪 Advanced Usage

### Custom Test Scenarios

Create custom test scripts:

```bash
# Create test script
cat > custom-test.sh << 'EOF'
#!/bin/bash
# Custom test scenario

./test-local.sh start

# Your custom tests here
docker exec tmux-test-client bash -c "
    # Test specific scenario
    ssh c1 -t 'echo test > /tmp/test.txt'
    ssh c2 -t 'cat /tmp/test.txt'
"

./test-local.sh clean
EOF

chmod +x custom-test.sh
```

### Performance Testing

```bash
# Stress test session switching
./test-local.sh start

docker exec tmux-test-client bash -c "
    for i in {1..100}; do
        ssh server -t 'tmux switch-client -t console-\$((i % 7 + 1))'
        sleep 0.1
    done
"
```

### Integration Testing

```bash
# Test with external tools
./test-local.sh start

# Install additional tools in server
docker exec tmux-test-server apt-get update
docker exec tmux-test-server apt-get install -y htop curl

# Test integration
docker exec tmux-test-client ssh c1 -t "htop"
```

---

**🎉 Docker testing makes tmux-persistent-console development fast and reliable!**
