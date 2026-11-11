# MacMouseFix

Keep **Ctrl + Left click** a **Left click** in Godot on macOS.

A small GDExtension (macOS only) that works around Godot turning Ctrl + LMB click into a RMB click on macOS. It works with both C# and GDScript projects.

> **Status:** I tested this only on Godot 4.7.2 stable. Feedback is always welcome.

## The problem

On macOS, pressing the left mouse button while holding Ctrl reaches a Godot game as `MOUSE_BUTTON_RIGHT`. Your code cannot tell it apart from a real right click.

This is not only something the operating system does. From what I could find Godot does the conversion itself. See [godotengine/godot#9744](https://github.com/godotengine/godot/issues/9744) This change makes sense in the editor but not in the game.

## What this does

The extension installs an `NSEvent` _local monitor_ in your game process. It sees the raw macOS mouse event before Godot does. For a left mouse button press or release with Control held, it hands Godot a copy of the event without the Control flag. Godot then sees a plain left click.

A real right mouse button is a different event type for macOS, so the monitor never touches it. This also means Ctrl + Left and Ctrl + Right can finally be told apart.

A local monitor only receives events meant for your own app, so no Accessibility or Input Monitoring permission is needed.

## Requirements

- macOS with the Xcode Command Line Tools (`xcode-select --install`)
- [SCons](https://scons.org) (`brew install scons`)
- Git
- Godot 4.2 or newer (see the compatibility note in step 3 of [Build](#build))

## Build

```bash
# 1. Get the code, including the godot-cpp submodule
git clone --recurse-submodules https://github.com/punthenk/mac-mouse-fix.git
cd mac-mouse-fix

# 2. (Optional) use a godot-cpp version that matches your Godot
git -C godot-cpp fetch --tags
git -C godot-cpp tag --sort=-v:refname | grep stable | head
git -C godot-cpp checkout godot-4.X-stable # same version as your Godot, otherwise the newest version possible.

# 3. Build
scons platform=macos arch=universal target=template_debug
scons platform=macos arch=universal target=template_release # only needed for exports
```

The finished libraries end up in `addons/mac_mouse_fix/bin/macos/`.

**Version note.** Build with the same godot-cpp version as your Godot, or an older one. A library built for an older Godot also loads in newer versions, but not the other way around.

`arch=universal` builds for both Apple Silicon and Intel. If it fails, use `arch=arm64` (or `x86_64`). In that case the file name gets an architecture suffix (for example `...template_debug.arm64.dylib`), and you need to update the paths in the `.gdextension` file to match.

## Add it to your project

1. Copy the whole `addons/mac_mouse_fix/` folder into your Godot project's `addons/` folder.
2. Open `addons/mac_mouse_fix/mac_mouse_fix.gdextension` and set `compatibility_minimum` to the godot-cpp version you built with (for example `"4.5"`). Check that the file names under `[libraries]` match what is in `bin/macos/`.
3. Restart the Godot editor once, then check the Output panel for GDExtension errors.

If you only want the hook and no logging, this is all you need.

GDScript:

```gdscript
func _ready() -> void:
	if OS.get_name() == "macOS" and ClassDB.class_exists("MacMouseFix"):
		var fix: Object = ClassDB.instantiate("MacMouseFix")
		fix.call("install")
```

C#:

```csharp
public override void _Ready()
{
	if (OS.GetName() == "macOS" && ClassDB.ClassExists("MacMouseFix"))
	{
		var fix = ClassDB.Instantiate("MacMouseFix").AsGodotObject();
		fix.Call("install");
	}
}
```

The class is looked up by name on purpose: the extension has no C# bindings, and scripts keep working on platforms where it is not loaded.

## Important: turn off game embedding in the editor

When you press Play with game embedding enabled (the default in recent Godot versions), mouse input is handled by the editor instead of by the game process, and in testing the hook did not take effect. To test from the editor:

1. Open the **Game** tab.
2. Open the three-dot menu in its toolbar.
3. Turn off **Embed Game on Next Play**.

## Verify that it works

Run the example autoload and click:

```
[MacMouseFix] installed: True
[MouseDebug] button=Left  ctrlKeyHeld=False event.ctrl_pressed=False hookFixedCount=0
[MouseDebug] button=Left  ctrlKeyHeld=True  event.ctrl_pressed=False hookFixedCount=1   <- Ctrl + Left click
[MouseDebug] button=Right ctrlKeyHeld=True  event.ctrl_pressed=True  hookFixedCount=2   <- Ctrl + real Right click
```

`hookFixedCount` goes up by two for each Ctrl + Left click (press and release), so the number you see when pressing is odd: 1, 3, 5, and so on.


## Tested with

I tested this on macOS Golden Gate 27.0.1. I used Godot 4.7.2 stable. I used godot-cpp 4.5 because that was the latest version possible. I only tested this with the C# code, but the GDScript version should work exactly the same.

## AI Disclosure

The code in this project was almost entirely written by AI, under my vision. I tested this as much I could in my godot project.
