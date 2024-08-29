using Godot;
using System;

[GlobalClass]
public partial class Element : Resource
{
	[Export]
	public string Name;
	[Export]
	public Color MainColor;
	[Export]
	public Color[] ColorPalette;
}
