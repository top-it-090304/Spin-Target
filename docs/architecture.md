# Архитектура проекта

## Технические параметры

- **Движок:** Godot 4
- **Язык:** GDScript
- **Разрешение:** 540 × 960 пикселей
- **Ориентация:** Вертикальная (портретная)
- **Платформа:** Aurora OS

---

## Структура файлов

```
spin-target/
├── core/
│   ├── globals.gd          # Глобальное состояние, данные ножей, прогрессия
│   ├── events.gd           # Сигналы-события между компонентами
│   └── music_manager.gd    # Управление музыкой и SFX
│
├── elements/
│   ├── apple/
│   │   ├── apple.gd        # Механика яблока: коллизия, частицы, награда
│   │   └── apple.tscn
│   ├── knife/
│   │   ├── knife.gd        # Полёт ножа, коллизии, шлейф, состояния
│   │   ├── knife_trail_mote.gd  # Частицы-мотки шлейфа
│   │   └── knife.tscn
│   ├── Knife_shooter/
│   │   ├── knifeshooter.gd # Спавн ножей, обработка ввода, счётчик
│   │   └── knifeshooter.tscn
│   ├── targets/target/
│   │   ├── target.gd       # Вращение, размещение предметов, регистрация попаданий
│   │   ├── apple_reward_floater.gd  # Плавающий текст наград
│   │   └── target.tscn
│   └── ui/
│       ├── hud/
│       ├── win_banner/
│       ├── lose_banner/
│       ├── restart_overlay/
│       └── banner_font_util.gd   # Утилита подгонки текста в баннерах
│
├── scens/
│   ├── game/
│   │   ├── game.gd         # Контроллер игровой сцены
│   │   └── game.tscn
│   ├── start_screen/
│   │   ├── start_screen.gd # Стартовый экран, настройки, лучший результат
│   │   └── start_screen.tscn
│   └── knife_shop/
│       ├── knife_shop.gd   # UI магазина
│       ├── shop_item/
│       ├── stat_icon.gd    # Программная отрисовка иконок характеристик
│       └── unblock_butten/ # Кнопка разблокировки
│
├── assets/
│   ├── audio/              # SFX: knife_hit.wav, wood_hit.wav, target_explosion.wav
│   ├── fonts/
│   └── textures/
│
├── music/
│   ├── normal/             # 8 треков для обычных уровней
│   └── boss/               # 6 треков для боссовых уровней
│
└── icon/                   # Иконки приложения
```

---

## Синглтоны (Autoload)

Три глобальных синглтона, доступных из любой сцены:

### Globals (`core/globals.gd`)

Центральное хранилище состояния игры.

**Данные:**
- `KNIFE_DATA` — массив из 9 определений ножей
- `current_level` — текущий уровень (0–5)
- `apples` — баланс яблок
- `current_knife_index` — индекс выбранного ножа
- `unlocked_knives` — bool[9], какие ножи открыты
- `total_levels_passed` — всего пройдено уровней
- `max_level_record` — рекорд
- Статистика текущего забега (6 счётчиков)
- `best_runs` — топ-5 забегов

**Ключевые функции:**
- `get_current_knife_data()` — возвращает данные активного ножа
- `get_knife_stat_lines()` — форматирует характеристики для магазина
- `add_apples(amount)` — обновляет баланс + сохраняет + сигнал
- `go_to_next_level()` — прогресс уровня + проверка рекорда
- `unlock_random_knife()` — открывает случайный нож за яблоки
- `save_game()` / `load_game()` — работа с файлом сохранения

### Events (`core/events.gd`)

Шина событий (сигналы) для слабой связности компонентов.

| Сигнал | Когда | Данные |
|--------|-------|--------|
| `location_changed(location)` | Переход между сценами | enum LOCATIONS |
| `apples_changed(apples)` | Изменение баланса яблок | int |
| `knives_changed()` | Разблокировка/смена ножа | — |
| `combo_changed(combo, multiplier)` | Изменение комбо | int, float |
| `combo_broken()` | Сброс комбо | — |

### MusicManager (`core/music_manager.gd`)

Управление аудио.

**Функции:**
- `set_music_for_level(level_index)` — выбор трека по уровню
- `set_music_volume_linear(value)` — установка громкости (0.0–1.0)
- `get_music_volume_percent()` — текущая громкость в процентах

---

## Иерархия игровой сцены

```
Game (Node2D)
├── HUD (CanvasLayer)
│   ├── WinBanner
│   ├── LoseBanner
│   └── RestartOverlay
├── Knifeshooter (Node2D)  @ (360, 944)
│   └── Knife (CharacterBody2D)  ← активный нож
├── Target (CharacterBody2D)  @ (360, 394)
│   ├── Sprite2D
│   ├── ItemsContainer (Node2D)  ← ножи и яблоки на мишени
│   ├── AppleRewardFloater
│   ├── CollisionShape2D (радиус 120)
│   ├── Particles × 4
│   └── AudioExplosion
└── Camera2D  @ (360, 544)
```

---

## Слои коллизий

| Слой | Назначение |
|------|-----------|
| 2 | Ножи (летящие) |
| Маска 14 | Цели: мишень + дерево + воткнутые ножи |

Коллайдер яблока: `Area2D`, круг радиусом 36 пкс.  
Коллайдер ножа: `CapsuleShape2D`, радиус 12, высота 150.

---

## Система переходов между сценами

Управляется через сигнал `Events.location_changed(location)`.

```
LOCATIONS enum:
  START_SCREEN
  GAME
  KNIFE_SHOP
```

| Откуда | Куда | Триггер |
|--------|------|---------|
| START_SCREEN | GAME | Кнопка «Играть» |
| GAME | START_SCREEN | Поражение или «В меню» |
| START_SCREEN | KNIFE_SHOP | Кнопка «Магазин» |
| KNIFE_SHOP | START_SCREEN | Кнопка «В меню» |
| GAME уровень N | GAME уровень N+1 | Победа → авто-переход |
