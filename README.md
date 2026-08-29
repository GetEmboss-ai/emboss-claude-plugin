# Emboss

Turn flat PDFs into fillable forms and fill them, right from Claude.

## What it does

Emboss detects the fields in a flat PDF and turns it into a real fillable form. It can then fill that form for you using data, notes, or documents you provide, or a spreadsheet of rows for batch filling. Everything runs through the Emboss API, so results depend on what you send it and how the source document is structured.

## Install in Claude Code

```
/plugin marketplace add GetEmboss-ai/emboss-claude-plugin
/plugin install emboss@getemboss
```

Then run `/mcp` and sign in to Emboss to connect your account.

## Install in Claude.ai and Claude Desktop

Claude.ai and Claude Desktop connect to Emboss through the custom connector button rather than the plugin marketplace. See [https://getemboss.ai/docs/claude](https://getemboss.ai/docs/claude) for the setup steps.

## Pricing

The first 5 form creations, 5 context fills, and 5 standard fills each month are free; free operations are limited to 5-page forms. See [/pricing](https://getemboss.ai/pricing) for full details.

## Privacy

Only what you ask Claude to send to Emboss is sent. See [https://getemboss.ai/privacy](https://getemboss.ai/privacy) for the full privacy policy.

## Support

Questions or issues: [edwin@getemboss.ai](mailto:edwin@getemboss.ai)

## Development

Run the repo checks with:

```
bash scripts/check.sh
```
