using Godot;
using System;

[GlobalClass]
public partial class ElementalEffect : StatusEffect {
	[Export]
	public ElementalType Element { get; set; }

    public override Node InstantiateIcon()
    {
        Node output = base.InstantiateIcon();
		((ColorRect)output).Color = Element.MainColor;
		return output;
    }
}
