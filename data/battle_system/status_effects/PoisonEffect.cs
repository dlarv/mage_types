using Godot;
using System;

[GlobalClass]
public partial class PoisonEffect : StatusEffect
{
    public override string Apply(BattleActor actor)
    {
		return $"{actor.ActorName} was hurt by poison";
    }
}
