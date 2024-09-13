using Godot;
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
	public Color[] ColorPalette;
}
