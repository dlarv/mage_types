using Godot;
using System;

[Tool]
[GlobalClass]
public partial class PlayerActor : Resource {
	[Export]
	public string Name { 
		get => _name;
		set {
			_name = value;
			if(BattleActor != null) {
				BattleActor.ActorName = value;
			}
		}
	}
	private string _name;
	[Export]
	public BattleActor BattleActor;
	private BattleActor _battleActor;
	[Export]
	public StoryActor StoryActor;
}
