# MCP registry

`server.json` in the repo root describes Emboss for the [open MCP
registry](https://github.com/modelcontextprotocol/registry), a
community-run directory of MCP servers maintained by the Model Context
Protocol project. It is separate from Anthropic's own Claude connector
directory; publishing here does not list Emboss in the Claude.ai or Claude
Desktop connector directory, and being listed there does not require this.

## Publish

Run from the repo root, with a GitHub account that owns the
`io.github.edwinorange/emboss` namespace used in `server.json`:

```
brew install mcp-publisher
mcp-publisher login github
mcp-publisher publish
```

`mcp-publisher publish` reads `server.json` in the current directory and
submits it to the registry. Re-run the same three commands after bumping
`version` in `server.json` to publish an update.
