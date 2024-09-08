using Godot;
using System;
/*
 * Shows information about a battle actor.
 * Name, Sprite, Health
 */

public partial class BattleActorDisplay : Control {
	[Signal]
	public delegate void SelectedEventHandler(BattleActor actor);
	[Export]
	private TextureRect highlightDisplay;
	[Export]
	private Label nameLabel;
	[Export]
	private HSlider healthBar;
	[Export]
	private Label hpLabel;
	[Export]
	private TextureRect spriteDisplay;
	[Export]
	private Control statusEffectIcons;
	[Export]
	private Button selectorButton;
	[Export]
	private Panel defeatedPanel;

	public BattleActor Actor { get; set; }

	private Color tint = Colors.White;
	private Sprite sprite;
	private int totalHp;

	public void Setup(BattleActor actor) {
		nameLabel.Text = actor.ActorName;
		healthBar.Value = (actor.CurrentHp / actor.Hp) * 100;
		hpLabel.Text = $"{actor.CurrentHp}/{actor.Hp}";
		totalHp = actor.Hp;

		spriteDisplay.Texture = actor.Sprite.Texture;

		selectorButton.Pressed += () => EmitSignal(SignalName.Selected, actor);

		Actor = actor;
		actor.WasDefeated += () => {
			defeatedPanel.Show();
		};
		actor.ElementChanged += SetElement;
		actor.DamageApplied += SetHealth;
		actor.StatusEffectAdded += AddStatusEffect;
		actor.StatusEffectsRemoved += RemoveStatusEffects;
	}

	private void SetElement(int id, ElementalType element) {
		// Update sprite's colors.
		sprite.SetElement(id, element);
		// Update sprite.
		spriteDisplay.Texture = sprite.Texture;
	}

	private void SetHealth(int hp) {
		healthBar.Value = ((double)hp / (double)totalHp) * 100.0;
		hpLabel.Text = $"{hp}/{totalHp}";
	}

	public Vector2 GetPosition() {
		Vector2 position = GlobalPosition;
		position.X += Size.X / 2;
		position.Y += Size.Y / 2;

		return position;
	}

	/// Disallow selection
	public void DisableSelection() {
		selectorButton.Hide();
		tint = Colors.White;
		SetHighlight(false);
	}
	public void EnableSelection(Color color) {
		selectorButton.Show();
		tint = color;
	}
	private void AddStatusEffect(StatusEffect effect) {
	}

	private void RemoveStatusEffects(StatusEffect[] effect) {
	}
	public void SetDefeated() {
		// TODO: Remove status effect icons.
		defeatedPanel.Show();
	}
	public void SetHighlight(bool isHighlighted) {
		highlightDisplay.SelfModulate = new Color(tint.R, tint.G, tint.B, isHighlighted ? 1 : 0);
	}
	public void _on_mouse_entered() {
		if(selectorButton.Visible)
			SetHighlight(true);
	}
	public void _on_mouse_exited() {
		if(selectorButton.Visible)
			SetHighlight(false);
	}
}
