using Godot;
using System;
using System.Collections.Generic;

[Tool]
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
	[Export]
	public StatusEffect[] BuffEffects { get; set; }
	[Export]
	public StatusEffect[] DebuffEffects { get; set; }

	protected static Dictionary<string, Node> matchups = new();

	public override void _Ready() { 
		GD.Print("On ready: Blue = " + matchups.ContainsKey("Blue"));
	}
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
		GD.Print("Entered tree: Blue = " + matchups.ContainsKey("Blue"));
		ForceLoad();
	}
	public void ForceLoad() {
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
		if(element1 == Blank || element2 == Blank) return null;

		Node node = matchups[element1.Name];
		ElementalType res = node.GetResult(element2);
		return res;
	}
	public static (StatusEffect, StatusEffect) GetSideEffect(ElementalType a, ElementalType b) {
		if(a == Blank || b == Blank) return (null, null);
		return matchups[a.Name].GetEffect(b);
	}
	public Godot.Collections.Array<Godot.Collections.Array<Variant>> GetAllMatchups() {
		Godot.Collections.Array<Godot.Collections.Array<Variant>> output = new();
		foreach(Node node in matchups.Values) {
			foreach((ElementalType el, Edge edge) in node.Edges) {
				Godot.Collections.Array<Variant> item = new();
				item.Add(node.Element);
				item.Add(el);
				item.Add(edge.Result.Element);
				item.Add(SideEffectToIndex(edge.BuffEffect, true));
				item.Add(SideEffectToIndex(edge.DebuffEffect, false));

				output.Add(item);
			}
		}
		return output;
	}
	public void SetSideEffectFor(ElementalType a, ElementalType b, int index, bool isBuff) {
		StatusEffect effect;
		if(index == -1) {
			effect = null;
		} else {
			effect = isBuff ? BuffEffects[index] : DebuffEffects[index];
		}
		matchups[a.Name].SetEffect(b, effect, isBuff);

		var effects = matchups[a.Name].GetEffect(b);
		var msg1 = effects.Item1 != null ? effects.Item1.Name : "null";
		var msg2 = effects.Item2 != null ? effects.Item2.Name : "null";
		GD.Print($"Set side effect: {a.Name} & {b.Name} = {msg1}, {msg2}");
	}
	public int SideEffectToIndex(StatusEffect effect, bool isBuff) {
		if(effect == null) return -1;
		StatusEffect[] effects = isBuff ? BuffEffects : DebuffEffects;

		for(int i = 0; i < effects.Length; i++) {
			if(effect == effects[i]) {
				return i;
			}
		}
		return -1;
	}

	public string SaveAsCSV() {
		List<string> output = new();
		foreach(Node node in matchups.Values) {
			foreach((ElementalType el, Edge edge) in node.Edges) {
				string line = $"{node.Element.Name},{el.Name},{edge.Result.Element.Name},{SideEffectToIndex(edge.BuffEffect, true)},{SideEffectToIndex(edge.DebuffEffect, false)}";
				output.Add(line);
			}
		}
		return String.Join("\n", output);
	}
	public void LoadFromCSV(string data) {
		string[] lines = data.Split("\n");

		foreach(string line in lines) {
			string[] values = line.Split(",");
			ElementalType a = GetElementFromName(values[0]); 
			ElementalType b = GetElementFromName(values[1]);
			int buffIndex = int.Parse(values[3]);
			SetSideEffectFor(a, b, buffIndex, true);
			int debuffIndex = int.Parse(values[4]);
			SetSideEffectFor(a, b, buffIndex, false);
		}
	}

	protected class Node {
		public ElementalType Element { get; set; } = Blank;
		public Dictionary<ElementalType, Edge> Edges { get; set; } = new();

		public Node(ElementalType element) {
			Element = element;
		}
		public void AddConnection(ElementalType element, Node result) {
			Edges.Add(element, new Edge(null, null, result));
		}
		public void AddConnection(ElementalType element, StatusEffect buffEffect, StatusEffect debuffEffect, Node result) {
			Edges.Add(element, new Edge(buffEffect, debuffEffect, result));
		}
		public ElementalType GetResult(ElementalType other) {
			Edge edge = Edges.GetValueOrDefault(other, null);
			if(edge == null) return null;
			return edge.Result.Element;
		}
		public (StatusEffect, StatusEffect) GetEffect(ElementalType other) {
			Edge edge = Edges.GetValueOrDefault(other, null);
			if(edge == null) return (null, null);
			return (edge.BuffEffect, edge.DebuffEffect);
		}
		public void SetEffect(ElementalType other, StatusEffect effect, bool isBuff) {
			if(isBuff) Edges[other].BuffEffect = effect;
			else Edges[other].DebuffEffect = effect;

		}
		/// Find the edge connecting this and end, then return its effect.
		public StatusEffect FindEffectFor(ElementalType end) {
			foreach(Edge edge in Edges.Values) {
				if(edge.Result.Element == end) return edge.BuffEffect;
			}
			return null;
		}
	}
	protected class Edge {
		public StatusEffect	BuffEffect { get; set; }  
		public StatusEffect DebuffEffect { get; set; }
		public Node Result { get; set; }

		public Edge(StatusEffect buffEffect, StatusEffect debuffEffect, Node end) { 
			BuffEffect = buffEffect;
			DebuffEffect = debuffEffect;
			Result = end;
		}
	}
}
