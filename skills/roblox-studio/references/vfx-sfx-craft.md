# VFX и SFX: как делать красиво, читаемо и дёшево

Красивый эффект строится не из сотни частиц, а из ясного силуэта, тайминга и синхронного звука. Сначала реши, что игрок должен почувствовать: impact, reward, danger, movement, magic или UI confirmation.

## VFX recipe

Собирай эффект слоями:

1. **Core:** один яркий центр, вспышка или кольцо.
2. **Shape:** частицы, Beam/Trail или mesh, задающие направление.
3. **Motion:** скорость, drag, spread, вращение и цветовой переход.
4. **Impact:** короткий всплеск, screen/UI feedback или hit stop.
5. **Cleanup:** Emit вместо постоянного Rate для разовых событий, `Debris`/Trove и лимит lifetime.

Для `ParticleEmitter` проверяй texture, `Rate`, `Lifetime`, `Speed`, `SpreadAngle`, `Size`, `Transparency`, `Color`, `LightEmission`, `Rotation` и `LockedToPart`. Помни, что живые частицы примерно зависят от `Rate × Lifetime`: высокий Rate с длинной Lifetime быстро съедает бюджет.

`Beam` и `Trail` требуют два `Attachment`; placement и ширина attachments определяют форму. Используй их для мечей, лазеров, трассеров и движения, а не десятки мелких Parts.

## Тайминг

Разделяй эффект на anticipation → action → impact → settle. Для детского мультяшного стиля обычно лучше 0.1-0.4 секунды на основной отклик, а редкая награда может иметь более длинное затухание. Не делай каждый эффект постоянным и бесконечным: игрок перестаёт различать важное.

## Цвет и читаемость

Один эффект должен иметь один главный цвет-смысл и один акцент. Контрастируй эффект с фоном, не используй прозрачный белый поверх яркого неба без обводки. Проверяй эффект на mobile viewport и при выключенном bloom.

## SFX recipe

Синхронизируй звук с визуальным событием:

- anticipation: тихий подъём;
- action: короткий whoosh;
- impact: яркий transient;
- reward: восходящий chime;
- fail: короткий мягкий low sound.

2D звук подходит для UI и музыки, 3D Sound на Part/Attachment для мира. Используй SoundService/SoundGroup или современную Audio-систему, если она доступна в текущей Studio. Не подставляй asset id из памяти: проверь ownership и загрузку.

Делай группы Music, SFX, Ambience и Voice, чтобы настройки громкости работали целиком. Не создавай новый Sound на каждый клик без cleanup или pooling. Всегда добавляй mute/volume settings и не делай звук обязательным для понимания механики.

## VFX/SFX contract

Для каждой механики документируй event name, точку запуска, client/server owner, asset ids, fallback, lifetime, max concurrent count и cleanup. Игровое событие должно работать даже если ассет не загрузился: логика не должна зависеть от красоты эффекта.