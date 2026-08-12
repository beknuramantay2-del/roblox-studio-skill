# Современная Audio-система Roblox

Перед новым звуком проверь актуальную документацию: классические `Sound` и `SoundGroup` остаются полезными, но Roblox развивает модульные Audio objects.

## Ментальная модель

- producer: `AudioPlayer` или источник аудиопотока;
- emitter: 2D или 3D объект, который отправляет звук слушателю;
- effect: EQ, compressor, reverb и другие модификаторы;
- wire: соединение источника, эффекта и выхода.

Выбирай 3D emitter для звука мира, 2D setup для UI/музыки и отдельные bus/effects для Music, SFX, Ambience и Voice. Не смешивай legacy и modern pipeline случайно в одной системе.

## Fallback

Если нужные Audio objects или MCP-инструменты недоступны, используй проверенный `Sound`/`SoundService` путь, но зафиксируй это как compatibility fallback. В обоих вариантах сохраняй volume settings, mute, asset ownership, preload только критичных файлов и cleanup/pooling.

## Проверка

Проверь: звук слышен с правильной дистанцией, не дублируется при респавне, не создаёт бесконечных объектов, корректно выключается, не нужен для понимания механики и имеет безопасный fallback при недоступном asset id.