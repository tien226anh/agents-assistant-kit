# MCP Configuration Templates

Ready-to-use configuration snippets for connecting MCP servers to different IDE clients.

## Claude Desktop

**Config location:**
- macOS: `~/Library/Application Support/Claude/claude_desktop_config.json`
- Windows: `%APPDATA%\Claude\claude_desktop_config.json`

```json
{
  "mcpServers": {
    "my-server": {
      "command": "uv",
      "args": ["--directory", "/absolute/path/to/server", "run", "server.py"],
      "env": {
        "API_KEY": "your-api-key"
      }
    }
  }
}
```

## VS Code (Copilot)

**Config location:** `.vscode/mcp.json` in your project root.

```json
{
  "servers": {
    "my-server": {
      "command": "uv",
      "args": ["--directory", "${workspaceFolder}", "run", "server.py"],
      "env": {
        "API_KEY": "your-api-key"
      }
    }
  }
}
```

Or add to VS Code settings (`settings.json`):

```json
{
  "mcp": {
    "servers": {
      "my-server": {
        "command": "uv",
        "args": ["--directory", "${workspaceFolder}", "run", "server.py"]
      }
    }
  }
}
```

## Cursor

**Config location:** `.cursor/mcp.json` in your project root.

```json
{
  "mcpServers": {
    "my-server": {
      "command": "uv",
      "args": ["--directory", "/absolute/path/to/server", "run", "server.py"],
      "env": {
        "API_KEY": "your-api-key"
      }
    }
  }
}
```

## Claude Code (CLI)

```bash
# Add project-scoped MCP server
claude mcp add my-server uv -- --directory /absolute/path/to/server run server.py

# Add user-scoped MCP server (available globally)
claude mcp add --scope user my-server uv -- --directory /absolute/path/to/server run server.py

# List configured servers
claude mcp list

# Remove a server
claude mcp remove my-server
```

## TypeScript Server Configs

When the MCP server is built with TypeScript/Node:

```json
{
  "mcpServers": {
    "my-ts-server": {
      "command": "node",
      "args": ["/absolute/path/to/server/build/index.js"],
      "env": {
        "API_KEY": "your-api-key"
      }
    }
  }
}
```

Or via npx for published npm packages:

```json
{
  "mcpServers": {
    "published-server": {
      "command": "npx",
      "args": ["-y", "@scope/mcp-server-name"],
      "env": {
        "API_KEY": "your-api-key"
      }
    }
  }
}
```

## Remote MCP Servers (Streamable HTTP)

For servers accessible over HTTP:

```json
{
  "mcpServers": {
    "remote-server": {
      "url": "https://my-server.example.com/mcp",
      "headers": {
        "Authorization": "Bearer your-token"
      }
    }
  }
}
```

## Multi-Server Setup Example

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/home/user/projects"]
    },
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "ghp_xxx"
      }
    },
    "postgres": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-postgres", "postgresql://localhost:5432/mydb"]
    },
    "custom-tools": {
      "command": "uv",
      "args": ["--directory", "/home/user/my-tools", "run", "server.py"]
    }
  }
}
```

## Debugging

Test any MCP server interactively with the MCP Inspector:

```bash
# Python server
npx @modelcontextprotocol/inspector uv run server.py

# TypeScript server
npx @modelcontextprotocol/inspector node build/index.js

# npx-based server
npx @modelcontextprotocol/inspector npx -y @scope/mcp-server-name
```

The Inspector opens a web UI where you can:
- List and call tools
- Browse resources
- Test prompts
- View JSON-RPC messages
