# Playbooks реализации

Средней модели нужны не только знания, но и порядок действий. Для каждой задачи выбери playbook и не перескакивай через его gates.

## New mechanic

1. Recon карту и связанные системы.
2. Contract и data schema.
3. Server service и tests.
4. Remote contract и validation.
5. Client controller и optimistic feedback.
6. UI/VFX/SFX.
7. Playtest happy + negative + respawn.
8. Performance and release gates.

## New UI screen

1. Состояния: loading, ready, empty, error, disabled, success.
2. Mobile-first layout с Scale/constraints/safe area.
3. Reusable components из Theme.
4. Controller subscribes to server state, UI не владеет данными.
5. Touch/controller/keyboard input.
6. Screenshot before/after и clipping check.

## New NPC or boss

1. Model contract: PrimaryPart, Humanoid/Animator, tags, attributes, collision.
2. State machine и target rules.
3. Server throttles: target search, path recompute, attack cooldown.
4. Telegraph → execute → recover.
5. Death/respawn/cleanup.
6. Two-player and blocked-path tests.

## New economy feature

1. Data schema and migration.
2. Server-only balance and whitelist config.
3. Atomic transaction with idempotency key.
4. Remote result with explicit reason.
5. Save failure behavior.
6. Duplicate request, reconnect and receipt tests.

## Change existing system

1. Find all callers, remotes, tags, attributes and dependencies.
2. Preserve public contracts or write a migration.
3. Add a regression fixture before changing behavior.
4. Make one minimal change.
5. Run old scenario and new scenario.
6. Remove temporary diagnostics only after proof.

Never implement an entire game from a single vague prompt. Produce a short plan and a playable vertical slice first.