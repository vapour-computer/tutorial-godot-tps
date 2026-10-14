# Vapour tutorial branch

This branch of the Godot [TPS demo](https://github.com/godotengine/tps-demo) is the sample project for the
**Godot tutorial** in the [Vapour handbook](https://vapour-computer.github.io/vapour-dev-docs/). What was added on top of upstream:

| File | What it is |
| --- | --- |
| `export_presets.cfg` | A **Web** export preset: Compatibility-friendly, threads off |
| `project.godot` | Keyboard bindings added for `shoot` (F), `aim` (Q) and `view_*` (I J K L), so touch controls can drive them |
| `vapour.toml` | Game manifest and the phone `[controller]` layout (two sticks, three buttons) |
| `.github/workflows/vapour.yml` | Exports the Web build on every push; publishes to Vapour on `v*` tags |

Upstream's license (MIT) and credits are unchanged; see `LICENSE.md`.

```sh
godot --headless --export-release "Web" build/web/index.html
vapour test            # run it locally with the FPS overlay and profiler
vapour controller preview --html
```
