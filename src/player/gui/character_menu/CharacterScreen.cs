using Godot;
using System;

public partial class CharacterScreen : Control {
	[Export]
	public BattleActor Actor { 
		get => _actor; 
		set { 
			_actor = value;

			if(statItemsScroller == null) return;
			foreach(StatItem item in statItemsScroller.GetChildren()) {
				item.ChangeValue(value);
			}
		} 
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
	private VBoxContainer statItemsScroller;

	public void OnStatModified(string name, int amount) {
		Actor.SetStat(name, amount);
	}
}
