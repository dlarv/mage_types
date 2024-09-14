using Godot;
using Godot.Collections;
using System;
/*
 * Shows information about a battle actor.
 * Name, Sprite, Health
 */

public partial class BattleActorDisplay : Control {
	[Signal]
	public delegate void SelectedEventHandler(BattleActor actor);
	[Signal]
	public delegate void StatusEffectIconPressedEventHandler(StatusEffect effect);

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
	private Dictionary<string, Node> icons = new();

	public void Setup(BattleActor actor) {
		nameLabel.Text = actor.ActorName;
		healthBar.Value = (actor.CurrentHp / actor.Hp) * 100;
		hpLabel.Text = $"{actor.CurrentHp}/{actor.Hp}";
		totalHp = actor.Hp;

		if(actor.Sprite == null) {
			actor.UseGradientSprite();
		}
		spriteDisplay.Texture = actor.Sprite.Texture;
		sprite = actor.Sprite;

		selectorButton.Connect(Button.SignalName.Pressed, Callable.From(() => EmitSignal(SignalName.Selected, actor)));

		Actor = actor;
		actor.Connect(BattleActor.SignalName.WasDefeated, Callable.From(() => defeatedPanel.Show()));

		actor.Connect(BattleActor.SignalName.DamageApplied, new Callable(this, MethodName.SetHealth));

		actor.Connect(BattleActor.SignalName.StatusEffectAdded, new Callable(this, MethodName.AddStatusEffect));
		actor.Connect(BattleActor.SignalName.StatusEffectsRemoved, new Callable(this, MethodName.RemoveStatusEffects));
		actor.Connect(BattleActor.SignalName.ElementChanged, new Callable(this, MethodName.SetElement));
	}
	public override void _ExitTree() {
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
		if(icons.ContainsKey(effect.Name)) return;

		var icon = effect.InstantiateIcon();
		statusEffectIcons.AddChild(icon);
		Button button = icon.GetNode<Button>("Button");
		button.Connect(Button.SignalName.Pressed, Callable.From(() => EmitSignal(SignalName.StatusEffectIconPressed, effect))); 
		icons.Add(effect.Name, icon);
	}

	private void RemoveStatusEffects(StatusEffect[] effects) {
		foreach(StatusEffect effect in effects) {
			if(!icons.ContainsKey(effect.Name)) continue;
			var icon = icons[effect.Name];
			statusEffectIcons.RemoveChild(icon);
			icons.Remove(effect.Name);
		}
	}
	public void SetDefeated() {
		defeatedPanel.Show();

		foreach(string key in icons.Keys) {
			var icon = icons[key];
			statusEffectIcons.RemoveChild(icon);
		}
		icons.Clear();
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
	public void _OnStatusIconPressed(StatusEffect status) {
	}
}
