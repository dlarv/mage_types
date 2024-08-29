using Godot;
using System;

public partial class AnimationTester : Node2D
{
	[Export]
	public PackedScene animation;

	public /*async */override void _Ready()
	{
		var obj = animation.Instantiate();

		obj.Call("set_elemental_tint", new Color(1, 0, 0));
		obj.Call("_play", new Vector2(100, 100), new Vector2(0, 0));
		AddChild(obj);

		/*GD.Print("Timeout test");*/
		/*GodotObject res = (GodotObject)obj.Call("long_play");*/
		/*await ToSignal(res, "completed");*/
		/*GD.Print("Here in C#");*/
	}
}
