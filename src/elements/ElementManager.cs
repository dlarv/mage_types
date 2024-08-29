using Godot;
using System;

/*[GlobalClass]*/
public partial class ElementManager : Node
{
	[Export]
	public Element[] Elements { get; set; }

	public Element GetElementFromName(string name) 
	{
		// Ensure basic typos won't interfere.
		name = name.ToLower().Trim();
		foreach(Element el in Elements) {
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
