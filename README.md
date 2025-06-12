# MCP Protocol SDK

[![Crates.io](https://img.shields.io/crates/v/mcp-protocol-sdk.svg)](https://crates.io/crates/mcp-protocol-sdk)
[![Documentation](https://docs.rs/mcp-protocol-sdk/badge.svg)](https://docs.rs/mcp-protocol-sdk)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![CI](https://github.com/your-username/mcp-protocol-sdk/workflows/CI/badge.svg)](https://github.com/your-username/mcp-protocol-sdk/actions)
[![Security Audit](https://github.com/your-username/mcp-protocol-sdk/workflows/Security%20Audit/badge.svg)](https://github.com/your-username/mcp-protocol-sdk/actions)
[![codecov](https://codecov.io/gh/your-username/mcp-protocol-sdk/branch/main/graph/badge.svg)](https://codecov.io/gh/your-username/mcp-protocol-sdk)

**A production-ready, feature-complete Rust implementation of the Model Context Protocol**

The MCP Protocol SDK enables seamless integration between AI models and external systems through a standardized protocol. Build powerful tools, resources, and capabilities that AI can discover and use dynamically.

---

## 📚 [Complete Documentation & Guides](./docs/README.md) | 📖 [API Reference](./docs/api/README.md) | 🚀 [Getting Started](./docs/getting-started.md)

---

## ✨ Features

- 🦀 **Pure Rust** - Zero-cost abstractions, memory safety, and blazing performance
- 🔌 **Multiple Transports** - STDIO, HTTP, WebSocket support with optional features
- 🛠️ **Complete MCP Support** - Tools, resources, prompts, logging, and sampling
- 🎯 **Type-Safe** - Comprehensive type system with compile-time guarantees  
- 🚀 **Async/Await** - Built on Tokio for high-performance concurrent operations
- 📦 **Modular Design** - Optional features for minimal binary size
- 🔒 **Production Ready** - Comprehensive error handling, validation, and testing
- 📖 **Excellent Docs** - Complete guides for servers, clients, and integrations

## 🚀 Quick Start

### Add to Your Project

```toml
[dependencies]
mcp-protocol-sdk = "0.1.0"

# Or with specific features only:
mcp-protocol-sdk = { version = "0.1.0", features = ["stdio", "validation"] }
```

### Build an MCP Server (5 minutes)

```rust
use mcp_protocol_sdk::prelude::*;
use serde_json::json;

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    // Create server
    let mut server = McpServer::new("my-calculator", "1.0.0");
    
    // Add a tool
    let calc_tool = Tool::new("add", "Add two numbers")
        .with_parameter("a", "First number", true)
        .with_parameter("b", "Second number", true);
    
    server.add_tool(calc_tool);
    
    // Handle tool calls
    server.set_tool_handler("add", |params| async move {
        let a = params["a"].as_f64().unwrap_or(0.0);
        let b = params["b"].as_f64().unwrap_or(0.0);
        Ok(json!({ "result": a + b }))
    });
    
    // Start server (compatible with Claude Desktop)
    let transport = StdioServerTransport::new();
    server.run(transport).await?;
    
    Ok(())
}
```

### Build an MCP Client

```rust
use mcp_protocol_sdk::prelude::*;

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    // Connect to server
    let client = McpClient::new()
        .with_name("my-client")
        .build();
    
    let transport = StdioClientTransport::new();
    client.connect(transport).await?;
    client.initialize().await?;
    
    // Use server capabilities
    let tools = client.list_tools().await?;
    let result = client.call_tool("add", json!({"a": 5, "b": 3})).await?;
    
    println!("Result: {}", result);
    Ok(())
}
```

## 🎯 Use Cases

| **Scenario** | **Description** | **Guide** |
|--------------|-----------------|-----------|
| 🖥️ **Claude Desktop Integration** | Add custom tools to Claude Desktop | [📝 Guide](./docs/integrations/claude-desktop.md) |
| ⚡ **Cursor IDE Enhancement** | AI-powered development tools | [📝 Guide](./docs/integrations/cursor.md) |
| 📝 **VS Code Extensions** | Smart code assistance and automation | [📝 Guide](./docs/integrations/vscode.md) |
| 🗄️ **Database Access** | SQL queries and data analysis | [📝 Example](./examples/database_server.rs) |
| 🌐 **API Integration** | External service connectivity | [📝 Example](./examples/http_server.rs) |
| 📁 **File Operations** | Filesystem tools and utilities | [📝 Example](./examples/simple_server.rs) |
| 💬 **Chat Applications** | Real-time AI conversations | [📝 Example](./examples/websocket_server.rs) |

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   AI Client     │    │  MCP Protocol   │    │   MCP Server    │
│  (Claude, etc.) │◄──►│      SDK        │◄──►│  (Your Tools)   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                              │
                    ┌─────────┼─────────┐
                    │         │         │
              ┌──────▼──┐ ┌────▼───┐ ┌───▼────┐
              │  STDIO  │ │  HTTP  │ │WebSocket│
              │Transport│ │Transport│ │Transport│
              └─────────┘ └────────┘ └────────┘
```

## 🔧 Feature Flags

Optimize your binary size by selecting only needed features:

| Feature | Description | Default | Size Impact |
|---------|-------------|---------|-------------|
| `stdio` | STDIO transport for Claude Desktop | ✅ | Minimal |
| `http` | HTTP transport for web integration | ✅ | +2MB |
| `websocket` | WebSocket transport for real-time | ✅ | +1.5MB |
| `validation` | Enhanced input validation | ✅ | +500KB |
| `tracing-subscriber` | Built-in logging setup | ❌ | +300KB |

**Minimal Example** (STDIO only):
```toml
mcp-protocol-sdk = { version = "0.1.0", default-features = false, features = ["stdio"] }
```

## 📋 Protocol Support

✅ **Complete MCP 2024-11-05 Implementation**

- **Core Protocol** - JSON-RPC 2.0 with full error handling
- **Tools** - Function calling with parameters and validation  
- **Resources** - Static and dynamic content access
- **Prompts** - Reusable prompt templates with parameters
- **Logging** - Structured logging with multiple levels
- **Sampling** - LLM sampling integration and control
- **Roots** - Resource root discovery and management
- **Progress** - Long-running operation progress tracking

## 🌍 Integration Ecosystem

### AI Clients
- **Claude Desktop** - Ready-to-use STDIO integration
- **Cursor IDE** - Smart development assistance  
- **VS Code** - Extension development framework
- **Custom AI Apps** - HTTP/WebSocket APIs

### Development Tools  
- **Jupyter Notebooks** - Data science workflows
- **Streamlit Apps** - Interactive AI applications
- **Browser Extensions** - Web-based AI tools
- **Mobile Apps** - React Native integration

## 📊 Examples

| Example | Description | Transport | Features |
|---------|-------------|-----------|----------|
| [Echo Server](./examples/echo_server.rs) | Simple tool demonstration | STDIO | Basic tools |
| [Database Server](./examples/database_server.rs) | SQL query execution | STDIO | Database access |
| [HTTP Server](./examples/http_server.rs) | RESTful API integration | HTTP | Web services |
| [WebSocket Server](./examples/websocket_server.rs) | Real-time communication | WebSocket | Live updates |
| [File Server](./examples/simple_server.rs) | File system operations | STDIO | File handling |
| [Client Example](./examples/client_example.rs) | Basic client usage | STDIO | Client patterns |

## 🛠️ Development

### Prerequisites
- Rust 1.75+ 
- Cargo

### Build & Test
```bash
# Build with all features
cargo build --all-features

# Test with different feature combinations  
cargo test --no-default-features --features stdio
cargo test --all-features

# Run examples
cargo run --example echo_server --features stdio,tracing-subscriber
```

### Feature Development
```bash
# Test minimal build
cargo check --no-default-features --lib

# Test specific transports
cargo check --no-default-features --features http
cargo check --no-default-features --features websocket
```

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](./CONTRIBUTING.md) for details.

### Areas for Contribution
- 🐛 **Bug Reports** - Help us improve reliability
- 💡 **Feature Requests** - Suggest new capabilities  
- 📖 **Documentation** - Improve guides and examples
- 🔧 **Tool Integrations** - Build example servers
- 🧪 **Testing** - Expand test coverage
- 🚀 **Performance** - Optimize critical paths

## 📋 Roadmap

- [ ] **Advanced Authentication** - OAuth2, JWT, mTLS support
- [ ] **Monitoring Integration** - Prometheus metrics, health checks
- [ ] **Plugin System** - Dynamic tool loading and registration
- [ ] **Schema Registry** - Tool and resource schema management  
- [ ] **Load Balancing** - Multiple server instance coordination
- [ ] **Caching Layer** - Response caching and invalidation
- [ ] **Rate Limiting** - Advanced traffic control
- [ ] **Admin Dashboard** - Web-based server management

## 📄 License

Licensed under the [MIT License](./LICENSE).

## 🙏 Acknowledgments

- **Anthropic** - For creating the MCP specification
- **Tokio Team** - For the excellent async runtime
- **Serde Team** - For JSON serialization/deserialization
- **Rust Community** - For the amazing ecosystem

---

<div align="center">

**[📚 Read the Full Documentation](./docs/README.md)** | **[🚀 Get Started Now](./docs/getting-started.md)**

*Built with ❤️ in Rust*

</div>
