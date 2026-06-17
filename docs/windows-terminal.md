# 🖥️ Windows Terminal Integration Guide

> Optimize Windows Terminal for the best tmux persistent console experience

## 🚀 Quick Setup

### 1. Install Windows Terminal
Download from Microsoft Store or GitHub releases:
- **Microsoft Store**: Search "Windows Terminal"
- **GitHub**: https://github.com/microsoft/terminal/releases

### 2. Basic Server Profile
Add to Windows Terminal `settings.json`:

```json
{
  "profiles": {
    "list": [
      {
        "name": "🖥️ Server Console",
        "commandline": "ssh user@your-server.com -t \"connect-console\"",
        "icon": "📟",
        "colorScheme": "Campbell",
        "experimental.input.forceVT": true
      }
    ]
  }
}
```

## 🎨 Complete Profile Setup

### Individual Console Profiles
```json
{
  "profiles": {
    "list": [
      {
        "name": "🤖 Claude Code Console",
        "commandline": "ssh user@server.com -t \"tmux attach -t console-1\"",
        "icon": "🤖",
        "colorScheme": "One Half Dark",
        "experimental.input.forceVT": true,
        "font": {
          "face": "Cascadia Code PL",
          "size": 11
        },
        "background": "#1e1e1e",
        "startingDirectory": null
      },
      {
        "name": "🎪 Copilot Console",
        "commandline": "ssh user@server.com -t \"tmux attach -t console-2\"",
        "icon": "🎪",
        "colorScheme": "GitHub Dark",
        "experimental.input.forceVT": true,
        "font": {
          "face": "Cascadia Code PL",
          "size": 11
        }
      },
      {
        "name": "💻 Development Console",
        "commandline": "ssh user@server.com -t \"tmux attach -t console-3\"",
        "icon": "💻",
        "colorScheme": "Campbell Powershell",
        "experimental.input.forceVT": true
      },
      {
        "name": "🧪 Testing Console",
        "commandline": "ssh user@server.com -t \"tmux attach -t console-4\"",
        "icon": "🧪",
        "colorScheme": "Solarized Dark",
        "experimental.input.forceVT": true
      },
      {
        "name": "📊 Monitoring Console",
        "commandline": "ssh user@server.com -t \"tmux attach -t console-5\"",
        "icon": "📊",
        "colorScheme": "Vintage",
        "experimental.input.forceVT": true
      },
      {
        "name": "🌐 Git Console",
        "commandline": "ssh user@server.com -t \"tmux attach -t console-6\"",
        "icon": "🌐",
        "colorScheme": "Tango Dark",
        "experimental.input.forceVT": true
      },
      {
        "name": "🔧 System Console",
        "commandline": "ssh user@server.com -t \"tmux attach -t console-7\"",
        "icon": "🔧",
        "colorScheme": "Campbell",
        "experimental.input.forceVT": true
      }
    ]
  }
}
```

## ⌨️ Keyboard Shortcuts

### Global Shortcuts for Console Access
Add to `settings.json` under `"actions"`:

```json
{
  "actions": [
    {
      "command": { "action": "newTab", "profile": "🤖 Claude Code Console" },
      "keys": "ctrl+alt+1"
    },
    {
      "command": { "action": "newTab", "profile": "🎪 Copilot Console" },
      "keys": "ctrl+alt+2"
    },
    {
      "command": { "action": "newTab", "profile": "💻 Development Console" },
      "keys": "ctrl+alt+3"
    },
    {
      "command": { "action": "newTab", "profile": "🧪 Testing Console" },
      "keys": "ctrl+alt+4"
    },
    {
      "command": { "action": "newTab", "profile": "📊 Monitoring Console" },
      "keys": "ctrl+alt+5"
    },
    {
      "command": { "action": "newTab", "profile": "🌐 Git Console" },
      "keys": "ctrl+alt+6"
    },
    {
      "command": { "action": "newTab", "profile": "🔧 System Console" },
      "keys": "ctrl+alt+7"
    },
    {
      "command": { "action": "newTab", "profile": "🖥️ Server Console" },
      "keys": "ctrl+alt+0"
    }
  ]
}
```

### Function Key Support
Ensure Ctrl+F keys work properly in tmux:

```json
{
  "profiles": {
    "defaults": {
      "experimental.input.forceVT": true
    }
  }
}
```

## 🎨 Color Schemes

### Optimized Color Schemes for Console Work
Add custom color schemes to `settings.json`:

```json
{
  "schemes": [
    {
      "name": "Console Dark",
      "black": "#0C0C0C",
      "red": "#C50F1F",
      "green": "#13A10E",
      "yellow": "#C19C00",
      "blue": "#0037DA",
      "purple": "#881798",
      "cyan": "#3A96DD",
      "white": "#CCCCCC",
      "brightBlack": "#767676",
      "brightRed": "#E74856",
      "brightGreen": "#16C60C",
      "brightYellow": "#F9F1A5",
      "brightBlue": "#3B78FF",
      "brightPurple": "#B4009E",
      "brightCyan": "#61D6D6",
      "brightWhite": "#F2F2F2",
      "background": "#1e1e1e",
      "foreground": "#CCCCCC"
    },
    {
      "name": "AI Console Theme",
      "black": "#282c34",
      "red": "#e06c75",
      "green": "#98c379",
      "yellow": "#e5c07b",
      "blue": "#61afef",
      "purple": "#c678dd",
      "cyan": "#56b6c2",
      "white": "#abb2bf",
      "brightBlack": "#5c6370",
      "brightRed": "#e06c75",
      "brightGreen": "#98c379",
      "brightYellow": "#e5c07b",
      "brightBlue": "#61afef",
      "brightPurple": "#c678dd",
      "brightCyan": "#56b6c2",
      "brightWhite": "#ffffff",
      "background": "#282c34",
      "foreground": "#abb2bf"
    }
  ]
}
```

## 🔧 Advanced Configuration

### Complete settings.json Template
Here's a complete optimized configuration:

```json
{
  "$help": "https://aka.ms/terminal-documentation",
  "$schema": "https://aka.ms/terminal-profiles-schema",
  "defaultProfile": "{🖥️ Server Console GUID}",
  "copyOnSelect": false,
  "copyFormatting": "none",
  "profiles": {
    "defaults": {
      "experimental.input.forceVT": true,
      "font": {
        "face": "Cascadia Code PL",
        "size": 11,
        "weight": "normal"
      },
      "antialiasingMode": "cleartype",
      "scrollbarState": "visible",
      "snapOnInput": true,
      "historySize": 9001
    },
    "list": [
      {
        "name": "🖥️ Server Console Menu",
        "commandline": "ssh user@your-server.com -t \"connect-console\"",
        "icon": "📟",
        "colorScheme": "Console Dark",
        "experimental.input.forceVT": true,
        "startingDirectory": "%USERPROFILE%",
        "suppressApplicationTitle": false
      },
      {
        "name": "🤖 Claude Code",
        "commandline": "ssh user@your-server.com -t \"tmux attach -t console-1\"",
        "icon": "🤖",
        "colorScheme": "AI Console Theme",
        "experimental.input.forceVT": true,
        "bellStyle": "none"
      },
      {
        "name": "🎪 Copilot CLI",
        "commandline": "ssh user@your-server.com -t \"tmux attach -t console-2\"",
        "icon": "🎪",
        "colorScheme": "GitHub Dark",
        "experimental.input.forceVT": true
      },
      {
        "name": "💻 Development",
        "commandline": "ssh user@your-server.com -t \"tmux attach -t console-3\"",
        "icon": "💻",
        "colorScheme": "One Half Dark",
        "experimental.input.forceVT": true
      },
      {
        "name": "🧪 Testing",
        "commandline": "ssh user@your-server.com -t \"tmux attach -t console-4\"",
        "icon": "🧪",
        "colorScheme": "Solarized Dark",
        "experimental.input.forceVT": true
      },
      {
        "name": "📊 Monitoring",
        "commandline": "ssh user@your-server.com -t \"tmux attach -t console-5\"",
        "icon": "📊",
        "colorScheme": "Vintage",
        "experimental.input.forceVT": true
      },
      {
        "name": "🌐 Git Operations",
        "commandline": "ssh user@your-server.com -t \"tmux attach -t console-6\"",
        "icon": "🌐",
        "colorScheme": "Campbell Powershell",
        "experimental.input.forceVT": true
      },
      {
        "name": "🔧 System Admin",
        "commandline": "ssh user@your-server.com -t \"tmux attach -t console-7\"",
        "icon": "🔧",
        "colorScheme": "Campbell",
        "experimental.input.forceVT": true
      }
    ]
  },
  "actions": [
    {
      "command": { "action": "copy", "singleLine": false },
      "keys": "ctrl+c"
    },
    {
      "command": "paste",
      "keys": "ctrl+v"
    },
    {
      "command": { "action": "newTab", "profile": "🤖 Claude Code" },
      "keys": "ctrl+alt+1"
    },
    {
      "command": { "action": "newTab", "profile": "🎪 Copilot CLI" },
      "keys": "ctrl+alt+2"
    },
    {
      "command": { "action": "newTab", "profile": "💻 Development" },
      "keys": "ctrl+alt+3"
    },
    {
      "command": { "action": "newTab", "profile": "🧪 Testing" },
      "keys": "ctrl+alt+4"
    },
    {
      "command": { "action": "newTab", "profile": "📊 Monitoring" },
      "keys": "ctrl+alt+5"
    },
    {
      "command": { "action": "newTab", "profile": "🌐 Git Operations" },
      "keys": "ctrl+alt+6"
    },
    {
      "command": { "action": "newTab", "profile": "🔧 System Admin" },
      "keys": "ctrl+alt+7"
    },
    {
      "command": { "action": "newTab", "profile": "🖥️ Server Console Menu" },
      "keys": "ctrl+alt+0"
    },
    {
      "command": "find",
      "keys": "ctrl+shift+f"
    },
    {
      "command": { "action": "splitPane", "split": "auto", "splitMode": "duplicate" },
      "keys": "alt+shift+d"
    }
  ],
  "schemes": [
    {
      "name": "Console Dark",
      "black": "#0C0C0C",
      "red": "#C50F1F",
      "green": "#13A10E",
      "yellow": "#C19C00",
      "blue": "#0037DA",
      "purple": "#881798",
      "cyan": "#3A96DD",
      "white": "#CCCCCC",
      "brightBlack": "#767676",
      "brightRed": "#E74856",
      "brightGreen": "#16C60C",
      "brightYellow": "#F9F1A5",
      "brightBlue": "#3B78FF",
      "brightPurple": "#B4009E",
      "brightCyan": "#61D6D6",
      "brightWhite": "#F2F2F2",
      "background": "#1e1e1e",
      "foreground": "#CCCCCC"
    }
  ]
}
```

## 🔒 SSH Key Integration

### Setting up SSH Keys for Password-less Access

1. **Generate SSH Key** (in PowerShell):
```powershell
ssh-keygen -t ed25519 -C "windows-terminal-console"
```

2. **Copy Key to Server**:
```powershell
# Using ssh-copy-id (if available)
ssh-copy-id user@your-server.com

# Or manually
Get-Content ~/.ssh/id_ed25519.pub | ssh user@your-server.com "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"
```

3. **Test Connection**:
```powershell
ssh user@your-server.com "echo 'SSH key authentication works'"
```

## 🏃‍♂️ Performance Optimization

### Reduce Connection Latency
Add to `~/.ssh/config` on Windows:

```bash
Host your-server.com
    HostName your-server.com
    User your-username
    Port 22
    ControlMaster auto
    ControlPath C:/Users/%USERNAME%/.ssh/master-%r@%h:%p
    ControlPersist 10m
    ServerAliveInterval 60
    ServerAliveCountMax 3
    Compression yes
```

### Direct-Attach SSH Alias (UTF-8 safe)

If you want `ssh my-ptty` to drop you straight into a console, use
`RemoteCommand` — but **bake `LANG=C.UTF-8` and the `-u` flag into the
command**, otherwise Nerd Font icons render as `_` underscores. SSH
`RemoteCommand` bypasses shell init (`~/.bashrc` is **not** sourced) so
locale exports there don't reach tmux.

```sshconfig
Host my-ptty
    Hostname your.server.com
    User your-username
    IdentityFile ~/.ssh/id_ed25519
    RequestTTY yes
    RemoteCommand LANG=C.UTF-8 LC_ALL=C.UTF-8 /usr/bin/tmux -u attach -t console-1
    ServerAliveInterval 30
    ServerAliveCountMax 6
```

Pair with a separate clean alias for `scp`/`rsync`/non-interactive commands:

```sshconfig
Host your.server.com
    User your-username
    IdentityFile ~/.ssh/id_ed25519
    # No RemoteCommand — runs anything you pass
```

This way `ssh my-ptty` opens tmux directly with UTF-8 forced, and
`ssh your.server.com 'uptime'` keeps working for scripts.

### Font Optimization
Best fonts for console work:
- **Cascadia Code PL** (includes Powerline glyphs)
- **Fira Code** (programming ligatures)
- **JetBrains Mono** (excellent readability)
- **Source Code Pro** (Adobe's programming font)

### Terminal Performance Settings
```json
{
  "profiles": {
    "defaults": {
      "antialiasingMode": "cleartype",
      "experimental.rendering.forceFullRepaint": false,
      "experimental.rendering.software": false
    }
  }
}
```

## 🎪 Workflow Examples

### AI Development Workflow
1. **Open Windows Terminal**
2. **Ctrl+Alt+1**: Open Claude Code console
3. **Ctrl+Alt+2**: Open Copilot CLI in new tab
4. **Ctrl+Alt+3**: Open development console in new tab
5. **Switch between tabs** with Ctrl+Tab
6. **Within tmux**: Use Ctrl+F1-F10 for instant switching

### Multi-Project Management
```json
// Create project-specific profiles
{
  "name": "📱 Mobile Project",
  "commandline": "ssh mobile-server -t \"tmux attach -t console-1\"",
  "icon": "📱"
},
{
  "name": "🌐 Web Project",
  "commandline": "ssh web-server -t \"tmux attach -t console-1\"",
  "icon": "🌐"
}
```

## 🚨 Troubleshooting Windows Terminal

### Function Keys Not Working
**Problem**: Ctrl+F keys don't switch tmux sessions

**Solution 1**: Enable forceVT
```json
{
  "experimental.input.forceVT": true
}
```

**Solution 2**: Check Windows Terminal key bindings
- Ensure no conflicts with Windows Terminal shortcuts
- Disable conflicting key bindings in `actions` array

### SSH Connection Issues

**Problem**: "Connection refused" or timeouts

**Solutions**:
```powershell
# Test basic connectivity
Test-NetConnection your-server.com -Port 22

# Check SSH service
ssh -v user@your-server.com

# Try different SSH client
ssh -o PreferredAuthentications=password user@your-server.com
```

### Color Display Issues

**Problem**: Colors not showing correctly

**Solutions**:
```json
{
  "experimental.rendering.forceFullRepaint": true,
  "antialiasingMode": "cleartype"
}
```

### Copy/Paste Issues

**Problem**: Ctrl+C/Ctrl+V not working properly

**Solution**: Configure proper key bindings
```json
{
  "actions": [
    {
      "command": { "action": "copy", "singleLine": false },
      "keys": "ctrl+shift+c"
    },
    {
      "command": "paste",
      "keys": "ctrl+shift+v"
    }
  ]
}
```

## 📱 Windows Terminal Mobile

### Using Windows Terminal on Surface/Tablet
- **Touch-friendly**: Increase font size for touch use
- **On-screen keyboard**: Configure for better visibility
- **Pen support**: Use Surface Pen for selection

```json
{
  "profiles": {
    "defaults": {
      "font": { "size": 14 },
      "padding": "8, 8, 8, 8"
    }
  }
}
```

## 🔧 Automation Scripts

### PowerShell Helper Functions
Create `ConsoleHelper.ps1`:

```powershell
# Quick console connection functions
function Connect-Console1 { ssh user@server -t "tmux attach -t console-1" }
function Connect-Console2 { ssh user@server -t "tmux attach -t console-2" }
function Connect-Console3 { ssh user@server -t "tmux attach -t console-3" }
function Connect-ConsoleMenu { ssh user@server -t "connect-console" }

# Add to PowerShell profile
# Run: notepad $PROFILE
# Add: . C:\path\to\ConsoleHelper.ps1
```

### Batch File Shortcuts
Create `.bat` files for desktop shortcuts:

```batch
@echo off
wt.exe -p "🤖 Claude Code"
```

Save as `ClaudeCode.bat` on Desktop for one-click access.

---

**💡 Pro Tip**: Use Windows Terminal's command palette (Ctrl+Shift+P) to quickly switch between profiles without memorizing all shortcuts!
