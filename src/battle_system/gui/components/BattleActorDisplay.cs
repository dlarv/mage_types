using Godot;
using System;
/*
 * Shows information about a battle actor.
 * Name, Sprite, Health
 */

public partial class BattleActorDisplay : Control
{
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
	}

	public void SetElement(int id, ElementalType element) {
		// Update sprite's colors.
		sprite.SetElement(id, element);
		// Update sprite.
		spriteDisplay.Texture = sprite.Texture;
	}

	public void SetHealth(int hp) {
		healthBar.Value = (hp / totalHp) * 100;
		hpLabel.Text = $"{hp}/{totalHp}";
	}

	public Vector2 GetPosition() {
		return Vector2.Zero;
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
	public void AddStatusCondition(StatusEffect effect) {
	}

	public void RemoveStatusCondition(StatusEffect effect) {
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
