# Claude Code: Top GitHub Resources and Token Best Practices

A short guide to community repos worth knowing and to using tokens well. "Tokens" covers
both GitHub access tokens and LLM context tokens. Repo lists come from third-party
roundups, so check GitHub for current star counts and activity.

## Top GitHub repos for Claude Code

### Discovery lists
- [hesreallyhim/awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code): directory of skills, hooks, slash commands, agent frameworks and plugins.
- [Andycodeman/awesome-claude-code](https://github.com/Andycodeman/awesome-claude-code): smaller, separate curated list.

### Skills
- [anthropics/skills](https://github.com/anthropics/skills): Anthropic's official repo; best place to learn the skill format.
- [alirezarezvani/claude-skills](https://github.com/alirezarezvani/claude-skills): 200+ skills, also usable with Codex, Gemini CLI and Cursor.
- [K-Dense-AI/claude-scientific-skills](https://github.com/K-Dense-AI/claude-scientific-skills): research, science, analysis and finance.

### Subagents
- [VoltAgent/awesome-claude-code-subagents](https://github.com/VoltAgent/awesome-claude-code-subagents): 100+ specialized subagents.
- [supatest-ai/awesome-claude-code-sub-agents](https://github.com/supatest-ai/awesome-claude-code-sub-agents): smaller collection.

### Learning and setup
- [shareAI-lab/learn-claude-code](https://github.com/shareAI-lab/learn-claude-code): how a Claude Code-style agent works internally.
- [gsd-build/get-shit-done](https://github.com/gsd-build/get-shit-done): spec-driven development and context management. Archived by its owner in June 2026; one secondary source says active development moved to `open-gsd/gsd-core`, so verify before relying on either.
- claude-code-templates: ready-made agent, command, hook, settings and MCP configs.

## Using GitHub tokens properly

- **Prefer fine-grained tokens over classic ones.** A classic token with the `repo` scope reaches every repo you own; a fine-grained token can be limited to specific repos and permissions.
- **Scope to "Only select repositories".** Pick just the repo Claude needs, and grant only the permissions the task requires.
- **Set a short expiry.** Fine-grained tokens must expire; 30-60 days is a sensible default. Add a reminder to renew.
- **Keep tokens out of git.** If a token lives in a file such as `.mcp.json`, add that file to `.gitignore`. Never hardcode tokens in shared config, logs or screenshots.
- **Rotate immediately if exposed.**
- **Know the limits.** Fine-grained tokens don't support some API operations and can't reach repos in external organizations where you are only a collaborator. Org resources may need owner approval.

See GitHub's [fine-grained PAT announcement](https://github.blog/security/application-security/introducing-fine-grained-personal-access-tokens-for-github/)
and Anthropic's Claude Code documentation for exact setup steps.

## Using LLM tokens efficiently

- **Keep `CLAUDE.md` short.** It loads every turn, so its size is a recurring cost. Store stable rules only (test commands, package manager, directories to avoid).
- **Load only what you need.** Name specific files with `@file` rather than whole directories.
- **Disable unused MCP servers.** Each one adds tool definitions to context. Run `/context` to see the cost.
- **Start fresh for unrelated work.** Use `/compact` or a new session so old file reads and abandoned approaches don't pile up.
- **Match model and effort to the task.** Use the strongest model for hard problems, a lighter one for mechanical work, and lower `/effort` on simple tasks.
- **Avoid redundant reads.** Don't re-read unchanged files, and keep tool output small.

Savings percentages quoted in blog posts vary widely and are unverified.
