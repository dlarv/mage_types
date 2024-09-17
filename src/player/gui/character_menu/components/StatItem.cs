using Godot;
using System;

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
	private Label numberLabel;
	[Export]
	private Button upButton;
	[Export]
	private Button downButton;


	private void IncrementStat(int direction) {
		_value += direction;
		numberLabel.Text = "" + _value;
		EmitSignal(SignalName.StatModified, Text.ToLower().Trim(), _value);
	}

	public void ChangeValue(BattleActor actor) {
		Value = actor.GetStat(Text.ToLower().Trim());
	}

	public void ChangeValue(int value) {
		this._value = value;
	}
}
