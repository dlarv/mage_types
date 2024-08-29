using Godot;
using System;

public partial class BattleGUI: Node
{
	[Signal]
	public delegate void ActionsSelectedEventHandler(BattleAction actions);

	[Export]
	private Label messageBox;
	[Export]
	private Control allyDisplayParent;
	[Export]
	private Control enemyDisplayParent;
	[Export]
	private Button clearMessageButton;

	protected BattleActor[] allies;
	protected BattleActor[] enemies;
	private BattleActorDisplay[] allyDisplays;
	private BattleActorDisplay[] enemyDisplays;

	public BattleGUI(BattleActor[] allies, BattleActor[] enemies) {
		InitAllies(allies);
		InitEnemies(enemies);
	}

	public void InitAllies(BattleActor[] allies) {
		this.allies = allies;
		allyDisplays = new BattleActorDisplay[allies.Length];
		int i = 0;

		foreach (BattleActor actor in allies)
		{
			BattleActorDisplay display = new BattleActorDisplay(actor);
			allyDisplays[i++] = display;
			allyDisplayParent.AddChild(display);
		}
	}

	public void InitEnemies(BattleActor[] enemies) {
		this.enemies = enemies;
		enemyDisplays = new BattleActorDisplay[enemies.Length];
		int i = 0;

		foreach (BattleActor actor in enemies)
		{
			BattleActorDisplay display = new BattleActorDisplay(actor);
			enemyDisplays[i++] = display;
			enemyDisplayParent.AddChild(display);
		}
	}

	public void PlayAnimation(PackedScene animation, Vector2 start, Vector2 end) {
	}

	public async void DisplayMessage(string msg) {
		messageBox.Text = msg;
		await ToSignal(clearMessageButton, "Pressed");
		messageBox.Text = "";
	}

	public void AddStatusEffect(StatusEffect effect, BattleActor target) {
	}

	public void RemoveStatusEffect(StatusEffect effect, BattleActor target) {
	}

	public void ChangeHealth(int newHealth, BattleActor target) {
	}

	public void RemoveActor(BattleActor target) {
	}
}
