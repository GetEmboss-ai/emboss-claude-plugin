# Emboss

Turn flat PDFs into fillable forms, fill them, and fax them, right from Claude.

## What it does

Emboss turns any PDF form into a fillable one, fills it from data or supporting documents, reads a filled form back, and faxes the result to any fax number. Everything runs through the Emboss API, so results depend on what you send it and how the source document is structured.

## Install in Claude Code

```
/plugin marketplace add GetEmboss-ai/emboss-claude-plugin
/plugin install emboss@getemboss
```

Then run `/mcp` and sign in to Emboss to connect your account.

## Install in Claude.ai and Claude Desktop

Claude.ai and Claude Desktop connect to Emboss through the custom connector button rather than the plugin marketplace. See [https://getemboss.ai/docs/claude](https://getemboss.ai/docs/claude) for the setup steps. To give Claude the Emboss skill directly, download [emboss-skill.zip](https://github.com/GetEmboss-ai/emboss-claude-plugin/releases/latest/download/emboss-skill.zip) and upload it as a skill.

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
