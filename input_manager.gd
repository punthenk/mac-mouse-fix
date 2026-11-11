extends Node

# Set to false when you are done testing.
const DEBUG_LOGGING := true

const BUTTON_NAMES := {
	MOUSE_BUTTON_LEFT: "Left",
	MOUSE_BUTTON_RIGHT: "Right",
	MOUSE_BUTTON_MIDDLE: "Middle",
}

# Keeps a reference to the extension's "remote control". The hook itself lives inside
# the extension, so it keeps running even if this reference is dropped.
var _mac_mouse_fix: Object = null


func _ready() -> void:
	_install_mac_mouse_fix()


# For testing only: shows what arrives and how often the hook has stepped in.
func _input(event: InputEvent) -> void:
	if not DEBUG_LOGGING:
		return

	if event is InputEventMouseButton and event.pressed:
		var fixed_count := -1
		if _mac_mouse_fix != null:
			fixed_count = _mac_mouse_fix.call("get_fixed_count")

		print("[MouseDebug] button=%s ctrlKeyHeld=%s event.ctrl_pressed=%s hookFixedCount=%s" % [
			BUTTON_NAMES.get(event.button_index, str(event.button_index)),
			Input.is_key_pressed(KEY_CTRL),
			event.ctrl_pressed,
			fixed_count,
		])


func _install_mac_mouse_fix() -> void:
	if OS.get_name() != "macOS":
		return

	# Look the class up by name instead of using MacMouseFix directly. That way this
	# script still parses on platforms where the extension is not loaded.
	if not ClassDB.class_exists("MacMouseFix"):
		push_warning("[MacMouseFix] Extension not loaded: Ctrl + Left click will stay a Right click.")
		return

	_mac_mouse_fix = ClassDB.instantiate("MacMouseFix")
	var installed: bool = _mac_mouse_fix.call("install")
	print("[MacMouseFix] installed: ", installed)
