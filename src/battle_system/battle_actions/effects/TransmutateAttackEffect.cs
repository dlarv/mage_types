using Godot;
using System;

[GlobalClass]
public partial class TransmutateAttackEffect : AttackEffect {
	[Export]
	private ElementalType Element;
	[Export(PropertyHint.Range, "0, 1")]
	private int ElementId { get; set; }

    public override string ApplyEffect(BattleActor user, BattleActor target, BattleAction action) {
        /*string output = base.ApplyEffect(user, target, action);
		 * return output;*/
		return target.SetElement(ElementId, Element);
    }
}
