using Godot;
using System;

/*[GlobalClass]*/
public partial class ElementManager : Node
{
	public static ElementalType Blank { get; private set; } = null;
	[Export]
	public ElementalType[] Elements { get; set; }

	public override void _Ready() {
		Blank = Elements[0];
	}
	public ElementalType GetElementFromName(string name) 
	{
		// Ensure basic typos won't interfere.
		name = name.ToLower().Trim();
		foreach(ElementalType el in Elements) {
			if(el.Name.ToLower() == name) {
				return el;
			}
		}
		return null;
	}
	public int GetIndexFromName(string name) {
		name = name.ToLower().Trim();
		for(int i = 0; i < Elements.Length; i++) {
			if(Elements[i].Name.ToLower() == name) {
				return i;
			}
		}
		return -1;
	}
}
