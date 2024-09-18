using Godot;
using Godot.Collections;
using System;

[Tool]
[GlobalClass]
public partial class ElementalType : Resource
{
	[Export]
	public string Name;
	[Export]
	public Color MainColor;
	[Export]
	public Color TextColor;
	[Export]
	public Color[] ColorPalette;

	public ElementalType() {
		Name = "Blank";
		MainColor = new Color(.5f, .5f, .5f);
		ColorPalette = new Color[0];
		TextColor = Colors.Black;
	}

	public Color GetTextColor() {
		return (Color)TextColor;
	}
}
