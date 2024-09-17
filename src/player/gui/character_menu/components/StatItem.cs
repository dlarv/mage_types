using Godot;
using System;
using System.Text.RegularExpressions;

[Tool]
public partial class StatItem : Control {
	[Signal]
	public delegate void StatModifiedEventHandler(string name, int amount);

	[Export]
	public string Text {
		get {
			if(nameLabel == null) return "";
			return nameLabel.Text;
		}
		set {
			if(nameLabel == null) return;
			nameLabel.Text = value;
		}
	}
	[Export]
	public bool Editable {
		get {
			return _editable;
		}
		set {
			_editable = value;
			if(upButton == null || downButton == null) return;
			upButton.Visible = value;
			downButton.Visible = value;
		}
	}
	private bool _editable = true;
	[Export]
	public bool DebugMode {
		get => _debugMode;
		set {
			_debugMode = value;
			if(numberLabel == null) return;
			numberLabel.Editable = value;
			Editable = Editable || value;
		}
	}
	private bool _debugMode = true;

	[Export]
	public int Value {
		get => _value;
		set {
			_value = value;
			if(numberLabel == null) return;
			numberLabel.Text = "" + value;
		}
	}
	private int _value = 0;


	[Export]
	public int MinValue = 0;
	[Export]
	public int MaxValue = 1000;

	[Export]
	private Label nameLabel;
	[Export]
	private LineEdit numberLabel;
	[Export]
	private Button upButton;
	[Export]
	private Button downButton;

	public override void _Ready() {
		Settings.Singleton.Connect(Settings.SignalName.DebugModeToggled, Callable.From((bool val) => {
			GD.Print("Val changed");
			DebugMode = val;
		}));
	}

	private void IncrementStat(int direction) {
		_value += direction;
		numberLabel.Text = "" + _value;
		EmitSignal(SignalName.StatModified, Text.ToLower().Trim(), Value);
	}

	public void ChangeValue(BattleActor actor) {
		Value = actor.GetStat(Text.ToLower().Trim());
	}

	public void ChangeValue(int value) {
		Value = value;
	}

	public void OnTextChanged(string newText) {
		// From what I can tell, this should remove non-numeric symbols from string,
		// but it doesn't seem to do that.
		// Value = newText.ToInt();
		Value = Regex.Replace(newText, "[^0-9]", "").ToInt();
		EmitSignal(SignalName.StatModified, Text.ToLower().Trim(), Value);
	}
}
