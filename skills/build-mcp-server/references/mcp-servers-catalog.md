# MCP Servers Catalog

Curated list of useful MCP servers for software development workflows. These are community and official servers that can be added to your IDE agent.

## Official (by Anthropic / MCP team)

| Server | Package | Purpose |
|--------|---------|---------|
| **Filesystem** | `@modelcontextprotocol/server-filesystem` | Read/write files, search directories |
| **GitHub** | `@modelcontextprotocol/server-github` | PRs, issues, repos, code search |
| **GitLab** | `@modelcontextprotocol/server-gitlab` | MRs, issues, pipelines |
| **PostgreSQL** | `@modelcontextprotocol/server-postgres` | Query databases, inspect schemas |
| **SQLite** | `@modelcontextprotocol/server-sqlite` | Local database queries |
| **Brave Search** | `@modelcontextprotocol/server-brave-search` | Web search |
| **Memory** | `@modelcontextprotocol/server-memory` | Persistent key-value memory across sessions |
| **Fetch** | `@modelcontextprotocol/server-fetch` | HTTP requests to external APIs |
| **Puppeteer** | `@modelcontextprotocol/server-puppeteer` | Browser automation, screenshots |

## Community Highlights

| Server | Source | Purpose |
|--------|--------|---------|
| **Docker** | `mcp/docker` | Manage containers, images, compose |
| **Kubernetes** | Community | Manage k8s clusters, pods, deploys |
| **Sentry** | `@sentry/mcp-server-sentry` | Error tracking and monitoring |
| **Linear** | Community | Issue tracking and project management |
| **Notion** | Community | Document and database access |
| **Slack** | Community | Read messages, post updates |
| **AWS** | Community | S3, Lambda, CloudWatch |

## Configuration Examples

### Filesystem (read/write project files)
```json
{
  "filesystem": {
    "command": "npx",
    "args": ["-y", "@modelcontextprotocol/server-filesystem", "/path/to/allowed/directory"]
  }
}
```

### GitHub (PR reviews, issues, code search)
```json
{
  "github": {
    "command": "npx",
    "args": ["-y", "@modelcontextprotocol/server-github"],
    "env": {
      "GITHUB_PERSONAL_ACCESS_TOKEN": "ghp_your_token"
    }
  }
}
```

### PostgreSQL (query databases)
```json
{
  "postgres": {
    "command": "npx",
    "args": ["-y", "@modelcontextprotocol/server-postgres", "postgresql://user:pass@localhost:5432/dbname"]
  }
}
```

### Memory (persistent memory across sessions)
```json
{
  "memory": {
    "command": "npx",
    "args": ["-y", "@modelcontextprotocol/server-memory"]
  }
}
```

### Fetch (make HTTP requests)
```json
{
  "fetch": {
    "command": "npx",
    "args": ["-y", "@modelcontextprotocol/server-fetch"]
  }
}
```

## Finding More Servers

- **MCP Registry**: [modelcontextprotocol.io/registry](https://modelcontextprotocol.io/registry/about)
- **GitHub search**: [`topic:mcp-server`](https://github.com/topics/mcp-server)
- **npm search**: search for `@modelcontextprotocol` or `mcp-server`
- **Awesome MCP Servers**: [github.com/punkpeye/awesome-mcp-servers](https://github.com/punkpeye/awesome-mcp-servers)

## Building Your Own

If no existing server fits your needs, use the `build-mcp-server` skill to create a custom one.
Common reasons to build your own:
- Internal APIs or services that need agent access
- Custom tooling specific to your team's workflow
- Combining multiple data sources into one unified server
- Adding domain-specific logic or validation
