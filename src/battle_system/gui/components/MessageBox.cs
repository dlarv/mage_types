using Godot;
using System;
using System.Threading.Tasks;

public partial class MessageBox : RichTextLabel
{
	[Signal]
	public delegate void MessageClearedEventHandler();

	[Export]
	private Button button;

	public override void _Ready() {
		button.Pressed += ClearMessage;
	}

	public async Task DisplayMessageBlocking(string msg) {
		ClearMessage();
		Text = msg;
		await ToSignal(button, "pressed");
	}
	public void DisplayMessageNonBlocking(string msg, GodotObject obj=null) {
		ClearMessage();
		if(obj == null) {
			Text = msg;
		}
		else if(obj is Attack) {
			FormatAttack((Attack)obj);
		} 
		else if(obj is BattleItem) {
			FormatItem((BattleItem)obj);
		}
		else if(obj is StatusEffect) {
			FormatStatusEffect((StatusEffect)obj);
		}
		else if(obj is BattleActor) {
			FormatBattleActor((BattleActor)obj);
		}
	}

	private void FormatAttack(Attack attack) {
		AppendTitle(attack.Name);
		AppendElementalType(attack.Element);

		AppendHeader("Power");
		AppendText("" + attack.Power);
		Newline();
		AppendHeader("Range");
		AppendText("" + attack.Range);
		Newline();

		if(attack.Details.Length > 0) {
			AppendHeader("Description");
			Newline();
			AppendText(attack.Details);
		}
	}
	private void FormatItem(BattleItem item) {
		AppendTitle(item.Name);

		/*if(item.Element != ElementManager.Blank) {
			AppendElementalType(item.Element);
		}*/
		
		if(item.Details.Length > 0) {
			AppendHeader("Description");
			Newline();
			AppendText(item.Details);
		}
	}
	private void FormatStatusEffect(StatusEffect effect) {
	}
	private void FormatBattleActor(BattleActor actor) {
		AppendTitle(actor.ActorName);
		AppendElementalType(actor.Element1, "Primary Element");
		AppendElementalType(actor.Element2, "Secondary Element");

		Newline();
		AppendHeader("Stats");
		Newline();
		AppendHeader("Hp");
		AppendText($"{actor.CurrentHp}/{actor.Hp}");
		Newline();

		AppendHeader("Melee Attack");
		AppendText($"{actor.MeleeAttack}");
		Newline();

		AppendHeader("Ranged Attack");
		AppendText($"{actor.RangedAttack}");
		Newline();

		AppendHeader("Melee Defense");
		AppendText($"{actor.MeleeAttack}");
		Newline();

		AppendHeader("Ranged Defense");
		AppendText($"{actor.RangedDefense}");
		Newline();

		AppendHeader("Speed");
		AppendText($"{actor.Speed}");
		Newline();

		Newline();
		AppendHeader("Attacks");
		Newline();
		foreach(Attack attack in actor.Attacks) {
			FormatAttack(attack);
		}
	}

	// [underline]<title>[/underline]\n
	public void AppendTitle(string title) {
		PushUnderline();
		AppendText(title);
		Pop();
		Newline();
	}
	// [bold]<val>[/bold]: 
	public void AppendHeader(string val) {
		PushBold();
		AppendText(val);
		Pop(); // End bold 
		AppendText(": ");
	}
	// [color]<element.Name>[/color]\n
	public void AppendElementalType(ElementalType element, string msg="Element") {
		AppendHeader(msg);
		PushColor(element.MainColor);
		AppendText(element.Name);
		Pop(); // End color
		Newline();
	}

	public void ClearMessage() {
		Text = "";
		Clear();
	}
}
