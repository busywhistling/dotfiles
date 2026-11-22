# Preferences

## Creating skills

Whenever I ask you to create a skill, **always make it project-scoped**: write it to
`.opencode/skills/<skill-name>/SKILL.md` inside the current project directory. Never
put it in the global `~/.config/opencode/skills/`. Do not ask me to choose a scope —
project-scoped is the default and the answer unless I explicitly say otherwise.

If a skill already exists globally and I ask for a change to it, copy it into the
project's `.opencode/skills/` first, then edit that copy.

## Clones

Never create arbitrary directories in my home directory. Git clones, SDK
installations that come as clones (emsdk and the like) and any other fetched
source trees go in `~/Documents/4_github/<name>`. Keep a project's own build
artifacts inside the project, not in `$HOME`.

## Shell scripts

Always write shell scripts in **fish**, never bash or sh — shebang
`#!/usr/bin/env fish`. Do not fall back to POSIX shell just because a script is
short or because the examples you have seen use it. If something genuinely
cannot be done in fish (a tool that only supports another shell), say so
explicitly before writing it in a different shell.

Indent fish scripts with **two spaces** per level, never four. Format with
`fishfmt` and verify with `fishfmt --check`; `fish_indent` would rewrite them
with four spaces and has no width option. `fishfmt` itself is a Python program,
not a shell script.
