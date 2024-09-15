using Godot;
using System;
using System.Collections.Generic;

[Tool]
/*[GlobalClass]*/
public partial class ElementManager : Node {
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
	private static Dictionary<string, Node> matchups = new();

	public override void _Ready() { }
	private void Test() {
		ElementalType[,] actualResults = {
			// Red
			{ null, Yellow, Magenta, Orange, null, null, null, Magenta },
			// Green
			{ Yellow, null, Cyan, null, null, null, Yellow, Cyan },
			// Blue
			{ Magenta, Cyan, null, null, null, Purple, Purple, null },
			// Yellow
			{ Orange, null, null, null, Green, Red, Red, null },
			// Cyan
			{ null, null, null, Green, null, Blue, null, Blue },
			// Magenta
			{ null, null, Purple, Red, Blue, null, Red, Blue },
			// Orange 
			{ null, Yellow, Purple, Red, null, Red, null, Magenta },
			// Purple
			{ Magenta, Cyan, null, null, Blue, Blue, Magenta, null }
		};
		ElementalType[] headers = { Red, Green, Blue, Yellow, Cyan, Magenta, Orange, Purple };
		bool total = true;
		for(int i = 0; i < 8; i++) {
			for(int j = 0; j < 8; j++) {
				var res = GetMatchup(headers[i], headers[j]) == actualResults[i, j];
				if(!res) GD.PushWarning($"{headers[i]} + {headers[j]} != {actualResults[i,j]}");
				total &= res;
			}
		}
		GD.Print($"Final result: {total}");
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

		matchups = new();
		Node blue = new(Blue);
		matchups.Add(Blue.Name, blue);
		Node purple = new(Purple);
		matchups.Add(Purple.Name, purple);
		Node magenta = new(Magenta);
		matchups.Add(Magenta.Name, magenta);
		Node red = new(Red);
		matchups.Add(Red.Name, red);
		Node orange = new(Orange);
		matchups.Add(Orange.Name, orange);
		Node yellow= new(Yellow);
		matchups.Add(Yellow.Name, yellow);
		Node green = new(Green);
		matchups.Add(Green.Name, green);
		Node cyan = new(Cyan);
		matchups.Add(Cyan.Name, cyan);

		blue.AddConnection(Red, magenta);
		blue.AddConnection(Green, cyan);
		blue.AddConnection(Magenta, purple);
		blue.AddConnection(Orange, purple);

		purple.AddConnection(Red, magenta);
		purple.AddConnection(Green, cyan);
		purple.AddConnection(Cyan, blue);
		purple.AddConnection(Magenta, blue);
		purple.AddConnection(Orange, magenta);

		magenta.AddConnection(Blue, purple);
		magenta.AddConnection(Yellow, red);
		magenta.AddConnection(Cyan, blue);
		magenta.AddConnection(Orange, red);
		magenta.AddConnection(Purple, blue);

		red.AddConnection(Green, yellow);
		red.AddConnection(Blue, magenta);
		red.AddConnection(Yellow, orange);
		red.AddConnection(Purple, magenta);

		orange.AddConnection(Green, yellow);
		orange.AddConnection(Blue, purple);
		orange.AddConnection(Yellow, red);
		orange.AddConnection(Magenta, red);
		orange.AddConnection(Purple, magenta);

		yellow.AddConnection(Red, orange);
		yellow.AddConnection(Cyan, green);
		yellow.AddConnection(Magenta, red);
		yellow.AddConnection(Orange, red);

		green.AddConnection(Red, yellow);
		green.AddConnection(Blue, cyan);
		green.AddConnection(Orange, yellow);
		green.AddConnection(Purple, cyan);

		cyan.AddConnection(Yellow, green);
		cyan.AddConnection(Magenta, blue);
		cyan.AddConnection(Purple, blue);
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
		Node node = matchups[element1.Name];
		ElementalType res = node.GetResult(element2);
		return res;
	}

	private class Node {
		public ElementalType Element { get; set; } = Blank;
		public Dictionary<ElementalType, Edge> Edges { get; set; } = new();

		public Node(ElementalType element) {
			Element = element;
		}
		public void AddConnection(ElementalType element, Node result) {
			Edges.Add(element, new Edge(null, result));
		}
		public void AddConnection(ElementalType element, StatusEffect effect, Node result) {
			Edges.Add(element, new Edge(effect, result));
		}
		public ElementalType GetResult(ElementalType other) {
			Edge edge = Edges.GetValueOrDefault(other, null);
			if(edge == null) return null;
			return edge.Result.Element;
		}
		public StatusEffect GetEffect(ElementalType other) {
			Edge edge = Edges.GetValueOrDefault(other, null);
			if(edge == null) return null;
			return edge.Effect;
		}
	}
	private class Edge {
		public StatusEffect Effect { get; set; }  
		public Node Result { get; set; }

		public Edge(StatusEffect effect, Node end) { 
			Effect = effect;
			Result = end;
		}
	}
}
