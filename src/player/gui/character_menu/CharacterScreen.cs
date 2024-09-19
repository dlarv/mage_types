using Godot;
using System;

[Tool]
public partial class CharacterScreen : Control {
	[Export]
	public BattleActor Actor { 
		get => _actor; 
		set => SetActor(value); 
	}
	private BattleActor _actor;
	[Export]
	public bool AllowStatEditing {
		get => _allowStatEditing;
		set {
			_allowStatEditing = value;
			if(statItemsScroller == null) return;
			foreach(StatItem item in statItemsScroller.GetChildren()) {
				item.Editable = value;
			}
		}
	}
	private bool _allowStatEditing = true;
	[Export]
	private Label nameLabel;
	[Export]
	private ElementIcon elementIcon1;
	[Export]
	private ElementIcon elementIcon2;
	[Export]
	private ElementIcon biasIcon;

	[Export]
	private VBoxContainer statItemsScroller;

	public override void _Ready() {
		SetActor(Actor);
		if(!Engine.IsEditorHint()) {
			Actor.Connect(
				BattleActor.SignalName.ElementChanged, 
				Callable.From((int id, ElementalType element) => {
					if(id == 0) { elementIcon1.Element = element; }
					else { elementIcon2.Element = element; }
				})
			);
		}
	}

	public void SetActor(BattleActor actor) {
		_actor = actor;

		if(statItemsScroller != null) { 
			foreach(StatItem item in statItemsScroller.GetChildren()) {
				item.ChangeValue(actor);

			}
		}
		if(nameLabel != null) {
			nameLabel.Text = actor.ActorName;
		}
		if(elementIcon1 != null) {
			elementIcon1.Element = actor.Element1;
		}
		if(elementIcon2 != null) {
			elementIcon2.Element = actor.Element2;
		}
		if(biasIcon != null) {
			biasIcon.Element = actor.ElementalBias;
		}
	}

	public void OnStatModified(string name, int amount) {
		Actor.SetStat(name, amount);
	}
}
