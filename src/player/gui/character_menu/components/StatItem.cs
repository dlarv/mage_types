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

	private int value = 0;

	private void IncrementStat(int direction) {
		value += direction;
		numberLabel.Text = "" + value;
		EmitSignal(SignalName.StatModified, Text, value);
	}
}
