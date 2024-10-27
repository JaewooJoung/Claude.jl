# 🤖 Claude.jl

> *Your friendly neighborhood AI assistant, now in Julia!* 

[![Julia](https://img.shields.io/badge/Julia-9558B2?style=for-the-badge&logo=julia&logoColor=white)](https://julialang.org)
[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://JaewooJoung.github.io/Claude.jl/stable)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

```julia
using Claude
client = ClaudeClient()
response = chat(client, "Why is Julia awesome?")
println(response.content[1].text)
# ... Because it's fast, dynamic, and now has Claude! 🚀
```

## 📋 Table of Contents
- [Prerequisites](#-prerequisites)
- [Features](#-features)
- [Installation](#-installation)
- [Quick Start](#-quick-start)
  - [Setting Up API Keys](#setting-up-your-api-key)
  - [Basic Usage](#basic-chat)
  - [Advanced Usage](#advanced-usage)
- [Customization](#-customization)
- [Examples](#-examples)
- [API Reference](#-api-reference)
- [Error Handling](#error-handling)
- [Contributing](#-contributing)

## 📋 Prerequisites
- Julia 1.6 or higher
- An Anthropic API key ([Get one here](https://www.anthropic.com/))
- HTTP.jl and JSON3.jl packages

## ✨ Features
- 🔌 **Simple Integration** - Connect to Claude API in just a few lines
- 🛠️ **Tools Support** - Full support for Claude's powerful tools system
- 🔐 **Secure** - Environment variable support for API keys
- 🎯 **Type-Safe** - Fully typed structs and methods
- 🚀 **Modern** - Built for Claude 3.5 Sonnet and beyond

## 📦 Installation

Pop open your Julia REPL and let's get started:

```julia
using Pkg
Pkg.add(url="https://github.com/JaewooJoung/Claude.jl")
```

## 🚀 Quick Start

### Setting Up Your API Key

Before starting, you'll need to set up your Anthropic API key. Here's how to do it on different operating systems:

#### 🐧 Linux & macOS

**Option 1: Terminal (Temporary - current session only)**
```bash
export ANTHROPIC_API_KEY='your-api-key-here'
```

**Option 2: Shell Config (Permanent)**
```bash
# Add to ~/.bashrc, ~/.zshrc, or ~/.profile
echo 'export ANTHROPIC_API_KEY="your-api-key-here"' >> ~/.bashrc
source ~/.bashrc  # Reload the config
```

#### 🪟 Windows

**Option 1: Command Prompt (Temporary)**
```cmd
set ANTHROPIC_API_KEY=your-api-key-here
```

**Option 2: PowerShell (Temporary)**
```powershell
$env:ANTHROPIC_API_KEY="your-api-key-here"
```

**Option 3: System Environment Variables (Permanent)**
1. Right-click on 'This PC' or 'My Computer'
2. Click 'Properties' → 'Advanced system settings' → 'Environment Variables'
3. Under 'User variables' click 'New'
4. Variable name: `ANTHROPIC_API_KEY`
5. Variable value: `your-api-key-here`

#### 🔒 Security Tips
- Never commit your API key to version control
- Add `.env` to your `.gitignore` file
- Rotate your API key periodically
- Use different API keys for development and production

### Basic Chat

```julia
using Claude

# Create client (API key from environment)
client = ClaudeClient()

# Simple question
response = chat(client, "Write me a haiku about Julia")
println(response.content[1].text)

# Print formatted response
function print_response(resp)
    println("\nResponse Content:")
    println("----------------")
    println(resp.content[1].text)
    println("\nMetadata:")
    println("----------------")
    println("Model: ", resp.model)
    println("Tokens Used: ", resp.usage.output_tokens)
end
```

### Advanced Usage

#### Multi-Turn Conversations
```julia
messages = [
    Message("user", "What's the best programming language?"),
    Message("assistant", "That depends on your needs! What kind of project are you working on?"),
    Message("user", "I need something fast for scientific computing")
]

response = chat(client, messages)
```

#### Health Check and Error Handling
```julia
# API health check function
function check_api_health(client)
    resp = chat(client, "Hello!")
    println("✓ API is working")
    println("✓ Model: ", resp.model)
    println("✓ Message ID: ", resp.id)
end

# Error handling function
function handle_error(e)
    msg = string(e)
    if occursin("credit balance", msg)
        println("⚠️ Credit balance too low")
    elseif occursin("API key", msg)
        println("⚠️ API key issue")
    else
        println("⚠️ Error: ", e)
    end
end

# Using both together
try
    check_api_health(client)
    response = chat(client, "Hello!")
    print_response(response)
catch e
    handle_error(e)
end
```

## 🎨 Customization

### Client Options
```julia
# Custom configuration
client = ClaudeClient(
    model="claude-3-5-sonnet-20241022",  # Choose your model
    max_tokens=1024,                      # Set token limit
    base_url="https://api.anthropic.com/v1"  # Custom endpoint
)

# Update API key
update_api_key!(client, "your-new-key")
```

## 📚 API Reference

### ClaudeClient
```julia
ClaudeClient(;
    api_key::Union{String,Nothing}=nothing,
    model::String="claude-3-5-sonnet-20241022",
    max_tokens::Int=1024,
    tools::Vector{Tool}=Tool[],
    base_url::String="https://api.anthropic.com/v1"
)
```

### Message
```julia
Message(role::String, content::String)
```

### Response Structure
The response object contains:
- `content`: Array of message content objects
  - `text`: The actual response text
- `model`: The model used
- `usage`: Token usage statistics
- `id`: Unique message identifier

## ⚠️ Error Types

1. Credit Balance Errors
   - "Insufficient credit balance"
   
2. API Key Errors
   - Invalid/expired API key
   - Missing API key
   
3. Rate Limit Errors
   - Too many requests

## 💡 Best Practices

1. **Environment Variables**
   - Store API key securely
   - Use `.env` files for development

2. **Error Handling**
   - Always use try-catch blocks(for test uses)
   - Handle specific error cases
   - Provide clear error messages

3. **Resource Management**
   - Monitor token usage
   - Handle rate limits gracefully
   - Check API health regularly

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -am 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📜 License

MIT License - feel free to use this package to chat with Claude to your heart's content! ❤️

## 🙏 Acknowledgments

- Thanks to Anthropic for creating Claude
- Inspired by the amazing Julia community
- Built with ❤️ and Julia

---

<div align="center">
Made with <img src="https://raw.githubusercontent.com/JuliaLang/julia-logo-graphics/master/images/julia-logo-dark.svg" height="30"/> by Jaewoo<br>
If you like Claude.jl, give it a ⭐!
</div>
