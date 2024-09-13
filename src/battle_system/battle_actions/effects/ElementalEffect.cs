using Godot;
using System;

[GlobalClass]
public partial class ElementalEffect : StatusEffect {
	[Export]
	public ElementalType Element { get; set; }

	public override string ApplyEffect(BattleActor user, BattleActor target, BattleAction action) {
		string output = base.ApplyEffect(user, target, action);
		return output.Replace("{element}", Element.Name);
	}
    public override Node InstantiateIcon() {
        Node output = base.InstantiateIcon();
		((ColorRect)output).Color = Element.MainColor;
		return output;
    }
}
