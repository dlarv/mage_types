using Godot;
using Godot.Collections;
using System;

[GlobalClass]
public partial class BattleActor : Node
{
	public const int MAX_STAT = 1000;

	[Export]
	public string ActorName; 

	[ExportCategory("Stats")]
	[Export]
	public int Hp { get; set; }
	[Export]
	public int CurrentHp { get; set; }
	[Export]
	public int MeleeAttack { get; set; }
	[Export]
	public int RangedAttack { get; set; }
	[Export]
	public int MeleeDefense { get; set; }
	[Export]
	public int RangedDefense { get; set; }
	[Export]
	public int Speed { get; set; }
	[Export]
	public int Evasion { get; set; }

	[ExportCategory("General")]
	[Export]
	public Element Element1 { get; private set; }
	[Export]
	public Element Element2 { get; private set; }
	[Export]
	public Attack[] Attacks { get; set; }
	[Export]
	public Sprite2D Sprite = null;
	protected bool use_gradient_sprite = false;

    public override void _Ready() {
        base._Ready();

		use_gradient_sprite = Sprite == null;
		if(use_gradient_sprite) {
			SetGradientSprite();
		} 

		var elementManager = GetNode<ElementManager>("/root/ElementManager");
		// If only one element is blank, it should be the second one.
		if(Element1 == null && Element2 != null) {
			Element1 = Element2;
			Element2 = elementManager.GetElementFromName("blank");
		}
		// The Blank Element should be used for empty types instead of null.
		if(Element1 == null) {
			Element1 = elementManager.GetElementFromName("blank");
		}
		if(Element2 == null) {
			Element2 = elementManager.GetElementFromName("blank");
		}

		/*AddChild(Sprite);*/
	}
    
	public void SetGradientSprite() {
		Gradient grad = new Gradient();
		if(Element1 != null) {
			grad.SetColor(0, Element1.MainColor);
		}
		if(Element2 != null) {
			grad.SetColor(1, Element2.MainColor);
		}
		
		GradientTexture2D tex = new GradientTexture2D();
		tex.Gradient = grad;
		Sprite = new Sprite2D();
		Sprite.Texture = tex;
	}

	public void SetElement(int id, Element element) {
		if(id == 0) {
			Element1 = element;
		} else {
			Element2 = element;
		}

		if(use_gradient_sprite) {
			((GradientTexture2D)Sprite.Texture).Gradient.SetColor(id, element.MainColor);
		}
	}
	
	public static BattleActor Create(string actorName, Element element1, Element element2, Attack[] attacks, Dictionary<string, int> stats) {
		BattleActor actor = new BattleActor();
		actor.ActorName = actorName;
		actor.Element1 = element1;
		actor.Element2 = element2;
		actor.Attacks = attacks;

		foreach(var stat in stats) {
			switch(stat.Key) {
				case "hp":
					actor.Hp = stat.Value;
					actor.CurrentHp = actor.Hp;
					break;
				case "attack":
					actor.MeleeAttack = stat.Value;
					actor.RangedAttack = stat.Value;
					break;
				case "defense":
					actor.MeleeDefense = stat.Value;
					actor.RangedDefense = stat.Value;
					break;
				case "melee_attack":
					actor.MeleeAttack = stat.Value;
					break;
				case "ranged_attack":
					actor.RangedAttack = stat.Value;
					break;
				case "melee_defense":
					actor.MeleeDefense = stat.Value;
					break;
				case "ranged_defense":
					actor.RangedDefense = stat.Value;
					break;
				case "speed":
					actor.Speed = stat.Value;
					break;
			}
		}

		return actor;
	}

	public static int GetMaxStat()
	{
		return MAX_STAT;
	}
	public Dictionary<string, int> GetStats()
	{
		return new Dictionary<string, int>() {
			{ "hp", Hp },
			{ "attack", MeleeAttack },
			{ "defense", MeleeDefense },
			{ "speed", MeleeDefense },
		};
	}
}
