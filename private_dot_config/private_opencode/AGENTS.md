# Preferences

## Creating skills

Whenever I ask you to create a skill, **always make it project-scoped**: write it to
`.opencode/skills/<skill-name>/SKILL.md` inside the current project directory. Never
put it in the global `~/.config/opencode/skills/`. Do not ask me to choose a scope —
project-scoped is the default and the answer unless I explicitly say otherwise.

If a skill already exists globally and I ask for a change to it, copy it into the
project's `.opencode/skills/` first, then edit that copy.

## Committing

nono denies `~/.ssh` and the 1Password agent socket, so **signed commits fail** with
`1Password: Could not connect to socket. Is the agent running?`. When that happens,
commit anyway with signing disabled rather than leaving the work uncommitted:

```bash
git -c commit.gpgsign=false commit -m "..."
```

Tell me the commit landed unsigned and that I need to push it myself — `git push`
also fails here (`~/.ssh/known_hosts` is denied). Never amend or rewrite history to
fix the missing signature; the commit stays as it is.
