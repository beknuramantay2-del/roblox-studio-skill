# Release readiness

Перед публикацией пройди ворота, а не просто запусти один happy path.

## Gates

1. Scope: все acceptance criteria выполнены или явно отмечены.
2. DataModel: нет дубликатов, лишних debug-объектов и `_draft`.
3. Code: `--!strict`, Script Analysis без новых ошибок, deprecated API проверен.
4. Security: все remotes валидируются на сервере, права и покупки серверные.
5. Data: миграция, retry, failed-load protection, BindToClose и receipt idempotency проверены.
6. UX: desktop/mobile/touch/controller, safe area, readable text, localization keys.
7. Runtime: happy path, negative path, respawn, rejoin, player leave, two clients.
8. Performance: memory, FPS, load time, network and high-frequency loops measured.
9. Safety: filtered text, age-appropriate content, monetization and UGC policy checked.
10. Recovery: checkpoint/commit exists and rollback procedure понятен.

Публикация без выполненного gate должна называться prototype, а не production-ready. В финальном отчёте укажи каждый gate как pass, fail или not tested.