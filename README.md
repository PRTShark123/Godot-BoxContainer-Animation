# BoxContainerAnimationSupport

> **A tiny note from the developer:** I’m not very good at using GitHub yet. 🥹
> So for now, I’m simply sharing the `.gd` source files here.
>
> The project was developed with **Godot 4.4.1**.
>
> I hope it can be useful to someone! ✨

> **Tired of your BoxContainer instantly teleporting everything around?**
> Want smooth drag-and-drop animations, but your Container keeps getting in the way?
>
> Say hello to **BoxContainerAnimationSupport**! ✨
>
> A small Godot component that adds **smooth drag-and-drop sorting animations** to `HBoxContainer`.

---

## ✨ Features

* 🖱️ **Long-press to drag**
* 🧩 **Automatic placeholder creation**
* 🔄 **Smooth slot reordering**
* 🎞️ **Tween-based animations**
* 📦 **Temporarily reparent dragged slots**
* 📡 **Useful drag & drop signals**
* ⚙️ **Customizable spacing**
* 🎨 **Customizable Tween transition, easing and duration**
* 🪶 **Works with Godot's existing Container layout system**
* 💫 No need to fight the Container. Let it do its thing!

---

## 🎬 How does it work?

The trick is surprisingly simple:

**Don't fight the Container. Give it a fake child instead.**

Imagine we have:

```text
[A] [B] [C] [D]
```

You start dragging `B`:

```text
[A] [Placeholder] [C] [D]
       ↑
    B is here!
```

`B` temporarily leaves the `HBoxContainer`, while a semi-transparent placeholder takes its place.

Move your mouse over `D`:

```text
[A] [C] [D] [Placeholder]
```

The placeholder moves, the Container recalculates the layout, and the other slots smoothly Tween to their new positions.

Release the mouse:

```text
[A] [C] [D] [B]
```

The real `B` comes back in, and the placeholder disappears.

✨ **No teleporting. No wrestling with Container layout. Just smooth movement.**

---

# 📦 Installation

Copy these two scripts into your Godot project:

```text
HBoxContainerAnimationSP.gd
SlotAnimationSP.gd
```

That's it!

No external dependencies are required.

---

# 🧱 Basic Setup

A basic scene can look like this:

```text
Control
├── HBoxContainerAnimationSP
│   ├── SlotAnimationSP
│   │   └── Button
│   ├── SlotAnimationSP
│   │   └── Button
│   └── SlotAnimationSP
│       └── Button
│
└── DragContainer
```

`SlotAnimationSP` must be a direct child of `HBoxContainerAnimationSP`.

Each slot also needs an `interact_button`.

---

# ⚠️ Important: `drag_container`

This is probably the most important thing to configure correctly.

When a slot starts being dragged, it is temporarily removed from the `HBoxContainerAnimationSP` and reparented to `drag_container`.

The placeholder stays inside the original container.

For example:

```text
Control
├── HBoxContainerAnimationSP
│   ├── Slot
│   ├── Slot
│   └── Slot
│
└── DragContainer
```

Set:

```text
HBoxContainerAnimationSP
    drag_container = DragContainer
```

### 🚨 Please don't use another auto-layout Container

Avoid using things such as:

```text
VBoxContainer
HBoxContainer
GridContainer
FlowContainer
```

as the `drag_container`.

Since the dragged slot needs to be freely positioned under the mouse, another automatic layout container may cause unexpected behavior.

Basically:

> **Let one Container do the organizing. Don't summon a second Container to the party.** 😂

---

# 🎞️ Animation Settings

You can customize the animation directly from the Inspector:

```gdscript
@export var tween_trans: Tween.TransitionType = Tween.TransitionType.TRANS_CUBIC
@export var tween_ease: Tween.EaseType = Tween.EaseType.EASE_OUT
@export var tween_duration: float = 0.5
```

For example:

```text
Tween Duration = 0.2
```

makes the slots move faster.

---

# 📏 Spacing

Set the spacing between slots with:

```gdscript
@export var separation: float = 10.0
```

For example:

```text
[A]    [B]    [C]
```

instead of:

```text
[A][B][C]
```

---

# 🧩 `SlotAnimationSP`

Your custom slot should inherit from `SlotAnimationSP`:

```gdscript
extends SlotAnimationSP

func _ready() -> void:
    super._ready()
```

You can then add your own data, visuals and behavior on top of it.

The component handles the boring drag-and-drop stuff for you. 🎀

---

# 🖱️ Long Press

Dragging starts after holding the interaction button for:

```gdscript
0.25
```

seconds by default.

In other words:

```text
Press
  ↓
Hold for 0.25s
  ↓
✨ Drag!
```

---

# 📡 Signals

## `HBoxContainerAnimationSP`

### `drag_slot`

Emitted when a slot starts being dragged.

```gdscript
signal drag_slot
```

---

### `put_slot`

Emitted when the dragged slot is released.

```gdscript
signal put_slot
```

---

### `move_slot`

Emitted when a slot actually changes its position.

```gdscript
signal move_slot(from: int, to: int)
```

For example:

```text
2 → 5
```

will emit:

```gdscript
move_slot.emit(2, 5)
```

This is useful when you need to synchronize the UI with your own data array:

```gdscript
func _on_move_slot(from: int, to: int) -> void:
    var item = items.pop_at(from)
    items.insert(to, item)
```

---

# 📡 `SlotAnimationSP` Signals

## `drag_state`

Tells you whether this slot is currently being dragged.

```gdscript
signal drag_state(type: bool)
```

When dragging starts:

```gdscript
drag_state.emit(true)
```

When dragging ends:

```gdscript
drag_state.emit(false)
```

This can be useful if you want to change the appearance of a slot while it's being dragged.

---

# 🔧 API

## `HBoxContainerAnimationSP`

### `slot_drag(slot, target_index)`

Starts dragging a slot.

```gdscript
container.slot_drag(slot, target_index)
```

| Parameter      | Type   | Description               |
| -------------- | ------ | ------------------------- |
| `slot`         | `Node` | The slot being dragged    |
| `target_index` | `int`  | Current index of the slot |

---

### `slot_put()`

Finishes the current drag operation.

It will:

1. Find the placeholder's current index
2. Reparent the dragged slot back to the container
3. Move it to the target index
4. Emit `put_slot`
5. Remove the placeholder

---

### `move_ph(target_index)`

Moves the placeholder to the specified index.

```gdscript
container.move_ph(target_index)
```

Normally this is handled automatically by `SlotAnimationSP`.

---

### `sort_position()`

Recalculates the target positions of all slots.

This is connected to the Container's:

```text
sort_children
```

signal.

---

# 🔧 `SlotAnimationSP`

### `sort_animation(...)`

Moves the slot to its target position using Tween.

```gdscript
slot.sort_animation(
    target,
    tween_trans,
    tween_ease,
    tween_duration
)
```

If the slot is already at the target position, no new Tween is created.

---

# 🧠 Design

The component intentionally does **not** try to replace Godot's Container layout system.

Instead, it works *with* it.

The basic idea is:

```text
        Godot Container
              │
              ▼
        Automatic Layout
              │
              ▼
       Target Slot Positions
              │
              ▼
             Tween
              │
              ▼
       ✨ Smooth Animation
```

During dragging:

```text
Real Slot
    │
    └──→ temporarily leaves Container

Placeholder
    │
    └──→ stays inside Container
```

This lets the Container continue doing what it does best:

**arranging things.**

Meanwhile, the dragged slot is free to follow the mouse.

Everybody wins. 🎉

---

# ⚠️ Current Limitations

The current version is mainly designed for:

```text
HBoxContainer
```

It is **not currently a universal solution for every Container type**.

For example, support for:

* `VBoxContainer`
* `GridContainer`
* `FlowContainer`

is not included by default.

Also, `SlotAnimationSP` is expected to be a direct child of `HBoxContainerAnimationSP`.

---

# 🗺️ Roadmap

Possible future improvements:

* [ ] `VBoxContainer` support
* [ ] `GridContainer` support
* [ ] Custom placeholder support
* [ ] More drag animations
* [ ] Scale animation while dragging
* [ ] Better type hints
* [ ] Example project
* [ ] Demo scene
* [ ] Godot Asset Library release

---

# 🌱 Why?

Godot's `BoxContainer` is great.

But sometimes you just want to say:

> "Hey, can you move over there nicely instead of teleporting?"

And the Container says:

> "No."

So this little project exists.

**Let the Container handle the layout.
Let the Slot handle the animation.
Let the Placeholder handle the trickery.**

Simple, lightweight, and hopefully a little bit fun. ✨

---

# 📄 License

This project is licensed under the **MIT License**.

See [`LICENSE`](LICENSE) for the full license text.

---

# 💬 Feedback & Contributions

Found a bug? Have an idea? Made something cool with it?

Feel free to open an **Issue** or submit a **Pull Request**!

And if this little component helped your project, a ⭐ would make it very happy. 🥹

---
