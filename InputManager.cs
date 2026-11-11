using Godot;

public partial class InputManager : Node
{
	private const bool DebugLogging = true;

	private GodotObject _macMouseFix;

	public override void _Ready()
	{
		InstallMacMouseFix();
	}

	public override void _Process(double delta)
	{
		DebugOverlay.Instance.Set("Right Mouse button", Input.IsMouseButtonPressed(MouseButton.Right));
		DebugOverlay.Instance.Set("Left Mouse button ", Input.IsMouseButtonPressed(MouseButton.Left));
	}

	public override void _Input(InputEvent @event)
	{
		if (!DebugLogging)
			return;

		if (@event is InputEventMouseButton mouseEvent && mouseEvent.Pressed)
		{
			long fixedCount = _macMouseFix != null ? _macMouseFix.Call("get_fixed_count").AsInt64() : -1;
			GD.Print($"[MouseDebug] button={mouseEvent.ButtonIndex} " +
			         $"ctrlKeyHeld={Input.IsKeyPressed(Key.Ctrl)} " +
			         $"event.CtrlPressed={mouseEvent.CtrlPressed} " +
			         $"hookFixedCount={fixedCount}");
		}
	}

	private void InstallMacMouseFix()
	{
		if (OS.GetName() != "macOS")
			return;

		if (!ClassDB.ClassExists("MacMouseFix"))
		{
			GD.PushWarning("[MacMouseFix] Extension niet geladen: Ctrl+linkerklik blijft een rechterklik.");
			return;
		}

		_macMouseFix = ClassDB.Instantiate("MacMouseFix").AsGodotObject();
		bool installed = _macMouseFix.Call("install").AsBool();
		GD.Print($"[MacMouseFix] installed: {installed}");
	}
}
