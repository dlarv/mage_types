using Godot;
using System;

[GlobalClass]
public partial class ItemRequirements : Resource {
	public virtual bool Check(BaseCompanion companion) {
		return true;
	}
	public virtual bool Check(Player player) {
		return true;
	}
}
