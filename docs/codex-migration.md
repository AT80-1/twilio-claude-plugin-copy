# Twilio Codex Plugin Scaffold

This repository now includes a Codex-native scaffold under `codex/` plus executable wrappers in `bin/`.

## Included
- Codex manifest: `codex/codex-plugin.json`
- Command specs: `codex/commands/*`
- Role packs: `codex/roles/*`
- Tier-1 Twilio skills: `codex/skills/{voice,messaging,verify,sync,taskrouter,twilio-invariants,deep-validation,tool-boundaries}`
- Reused scripts: `codex/env-doctor.sh`, `codex/check-deps.sh`, `codex/install-deps.sh`

## Run
```bash
bin/preflight
bin/test
bin/deploy
```
