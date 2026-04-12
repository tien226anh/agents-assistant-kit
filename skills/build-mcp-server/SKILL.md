---
name: build-mcp-server
description: Build MCP (Model Context Protocol) servers that expose tools, resources, and prompts to AI agents. Use when the user asks to create an MCP server, add MCP support, expose an API as MCP tools, or integrate with Claude Desktop, VS Code, Cursor, or other MCP clients.
---

# Build MCP Server

## When to use
Use this skill when asked to build an MCP server, add MCP tools/resources/prompts to a project, connect an API or service to AI agents via MCP, or configure MCP client connections.

## Background

MCP (Model Context Protocol) is an open standard for connecting AI agents to external tools and data. An MCP server exposes three types of capabilities:

| Feature | Purpose | How the model uses it |
|---------|---------|----------------------|
| **Tools** | Functions the model can call (with user approval) | Model invokes `tools/call` |
| **Resources** | Data/context the model can read (files, API responses) | Model reads via URI |
| **Prompts** | Pre-built templates for common workflows | User selects via slash command |

## Workflow

### Step 1: Choose your language and transport

**Supported SDKs**: Python, TypeScript, Java, Kotlin, C#, Ruby, Rust, Go

**Transport options**:
- **stdio** — Simplest. Client spawns the server as a subprocess. Best for local tools.
- **Streamable HTTP** — For remote/deployed servers. Uses HTTP with optional SSE.

For most local dev tools, use **stdio**.

### Step 2: Set up the project

**Python (recommended for quick builds)**:
```bash
uv init my-mcp-server
cd my-mcp-server
uv venv && source .venv/bin/activate
uv add "mcp[cli]"
```

**TypeScript**:
```bash
mkdir my-mcp-server && cd my-mcp-server
npm init -y
npm install @modelcontextprotocol/sdk zod@3
npm install -D @types/node typescript
```

### Step 3: Implement the server

**Python (FastMCP — high-level API)**:
```python
from mcp.server.fastmcp import FastMCP

mcp = FastMCP("my-server")

@mcp.tool()
async def my_tool(param: str) -> str:
    """Description of what this tool does.

    Args:
        param: Description of param
    """
    # Implementation
    return result

@mcp.resource("myapp://data/{id}")
async def get_data(id: str) -> str:
    """Fetch data by ID."""
    return json.dumps(data)

@mcp.prompt()
def review_prompt(code: str) -> str:
    """Generate a code review prompt."""
    return f"Review this code:\n\n{code}"

if __name__ == "__main__":
    mcp.run(transport="stdio")
```

**TypeScript (SDK)**:
```typescript
import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { z } from "zod";

const server = new McpServer({
  name: "my-server",
  version: "1.0.0",
});

server.registerTool(
  "my_tool",
  {
    description: "Description of what this tool does",
    inputSchema: {
      param: z.string().describe("Description of param"),
    },
  },
  async ({ param }) => ({
    content: [{ type: "text", text: `Result: ${param}` }],
  })
);

const transport = new StdioServerTransport();
await server.connect(transport);
```

### Step 4: Configure the client

Create/update the MCP client configuration:

**Claude Desktop** (`claude_desktop_config.json`):
```json
{
  "mcpServers": {
    "my-server": {
      "command": "uv",
      "args": ["--directory", "/absolute/path/to/my-mcp-server", "run", "server.py"]
    }
  }
}
```

**VS Code** (`.vscode/mcp.json`):
```json
{
  "servers": {
    "my-server": {
      "command": "uv",
      "args": ["--directory", "${workspaceFolder}", "run", "server.py"]
    }
  }
}
```

**Cursor** (`.cursor/mcp.json`):
```json
{
  "mcpServers": {
    "my-server": {
      "command": "uv",
      "args": ["--directory", "/absolute/path/to/my-mcp-server", "run", "server.py"]
    }
  }
}
```

### Step 5: Test

```bash
# Test with MCP Inspector (interactive debugging UI)
npx @modelcontextprotocol/inspector uv run server.py

# Or test directly via stdio
echo '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"test","version":"1.0"}}}' | uv run server.py
```

## Design Principles

1. **Tools should be focused** — One tool per action. Don't create a "do_everything" tool.
2. **Descriptions are critical** — The LLM reads the tool description to decide when to use it. Be specific.
3. **Return structured data** — Prefer JSON in tool responses for reliability.
4. **Never use stdout for logging** — Stdio transport uses stdout for protocol messages. Log to stderr only.
5. **Handle errors gracefully** — Return error messages as content, don't crash the server.
6. **Input validation** — Validate all parameters. Use Zod (TS) or Pydantic (Python).

## Gotchas

- **stdout is the protocol channel** (stdio transport). Using `print()` or `console.log()` will corrupt the protocol. Use `sys.stderr` or `console.error()`.
- **Absolute paths** in client config. Relative paths break because the client's working directory is unpredictable.
- **Restart the client** after changing config. Most MCP clients don't hot-reload server configs.
- **`uv` vs `python`** in command. Using `uv run` handles virtualenv automatically. Using `python` requires activating the venv first.
- **Tool names must be unique** across all connected MCP servers in a client.

For MCP config templates, see [references/mcp-configs.md](references/mcp-configs.md).
For a curated list of useful MCP servers, see [references/mcp-servers-catalog.md](references/mcp-servers-catalog.md).
