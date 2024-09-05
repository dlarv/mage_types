using Godot;
using System;
using System.Collections.Generic;

/*[GlobalClass]*/
public partial class ElementManager : Node
{
	public static ElementalType Blank { get; private set; }
	public static ElementalType Blue { get; private set; }
	public static ElementalType Purple { get; private set; }
	public static ElementalType Magenta { get; private set; }
	public static ElementalType Red { get; private set; }
	public static ElementalType Orange { get; private set; }
	public static ElementalType Yellow { get; private set; }
	public static ElementalType Green { get; private set; }
	public static ElementalType Cyan { get; private set; }

	[Export]
	public ElementalType[] Elements { get; set; }

	private static Dictionary<(ElementalType, ElementalType), ElementalType> Matchups;

    public override void _Ready() {
		/*GD.Print("True: " + (GetMatchup(Blank, Red) == null));*/
		/*GD.Print("True: " + (GetMatchup(Blue, Blank) == null));*/
		/*GD.Print("True: " + (GetMatchup(Blue, Blue) == null));*/
		/*GD.Print("True: " + (GetMatchup(Red, Yellow) == Orange));*/
		/*GD.Print("True: " + (GetMatchup(Yellow, Red) == Orange));*/
    }

	public override void _EnterTree() {
		Blank = Elements[0];
		foreach(ElementalType element in Elements) {
			switch(element.Name.ToLower()) {
				case "blank": 
					Blank = element;
					break;
				case "blue": 
					Blue = element;
					break;
				case "purple": 
					Purple = element;
					break;
				case "magenta": 
					Magenta = element;
					break;
				case "red": 
					Red = element;
					break;
				case "orange": 
					Orange = element;
					break;
				case "yellow": 
					Yellow = element;
					break;
				case "green": 
					Green = element;
					break;
				case "cyan": 
					Cyan = element;
					break;
			}
		}
		Matchups = new Dictionary<(ElementalType, ElementalType), ElementalType> {
			// Blue, Cyan, Green, Magenta, Orange, Purple, Red, Yellow
			{ (Blue, Magenta), Purple },
			{ (Blue, Red), Magenta },
			{ (Blue, Green), Cyan },
			{ (Blue, Orange), Purple },
			{ (Cyan, Yellow), Green },
			{ (Cyan, Magenta), Blue },
			{ (Cyan, Purple), Blue },
			{ (Green, Red), Yellow },
			{ (Green, Orange), Yellow },
			{ (Green, Purple), Cyan },
			{ (Magenta, Yellow), Red },
			{ (Magenta, Orange), Red },
			{ (Magenta, Purple), Blue },
			{ (Orange, Yellow), Red },
			{ (Orange, Purple), Magenta },
			{ (Purple, Red), Magenta },
			{ (Red, Yellow), Orange },
		};
	}

	public ElementalType GetElementFromName(string name) {
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

	public static ElementalType GetMatchup(ElementalType element1, ElementalType element2) {
		if(element1 == element2 || element1 == Blank || element2 == Blank) {
			return null;
		}

		ElementalType key1;
		ElementalType key2;
		if(element1.Name.CompareTo(element2.Name) < 0) {
			key1 = element1;
			key2 = element2;
		} else {
			key1 = element2;
			key2 = element1;
		}

		return Matchups.GetValueOrDefault((key1, key2), null);
	}
}
