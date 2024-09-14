using Godot;
using System;

public partial class ThreeStateButton : Control{
	[Signal]
	public delegate void StateChangedEventHandler(int state);

	public const int UNSELECTED_STATE = 0;
	public const int FIRST_SELECTED_STATE = 1;
	public const int SECOND_SELECTED_STATE = 2;

	[Export]
	private Color unselectedModulateColor;
	[Export]
	private Color selected1ModulateColor;
	[Export]
	private Color selected2ModulateColor;
	[Export]
	private Color lockedModulateColor;

	[Export]
	public Button Button { get; set; }
	public string Text {
		get => Button.Text;
		set => Button.Text = value;
	}
	public ButtonGroup ButtonGroup {
		get => Button.ButtonGroup;
		set => Button.ButtonGroup = value;
	}

	// Prevents button from entering 3rd state.
	public bool IsLocked { 
		get => _isLocked; 
		set {
			_isLocked = value;
			state = UNSELECTED_STATE;
			Modulate = value ? lockedModulateColor : unselectedModulateColor;
		}
	}
	private bool _isLocked = false;
	private int state = UNSELECTED_STATE;

	public void OnPressed(bool toggled) {
		if(!toggled) {
			state = UNSELECTED_STATE;
			Modulate = IsLocked ? lockedModulateColor : unselectedModulateColor;
			return;
		}
		if(!IsLocked && state == FIRST_SELECTED_STATE) {
			state = SECOND_SELECTED_STATE;
			Modulate = selected2ModulateColor;
		} else {
			state = FIRST_SELECTED_STATE;
			Modulate = selected1ModulateColor;
		}
		EmitSignal(SignalName.StateChanged, state);
	}

	public void Reset() {
		Modulate = unselectedModulateColor;
		state = UNSELECTED_STATE;
		Button.SetPressedNoSignal(false);
	}
}
