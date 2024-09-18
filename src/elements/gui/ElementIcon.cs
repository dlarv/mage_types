using Godot;
using System;

[Tool]
public partial class ElementIcon : ColorRect {
	[Export]
	private RichTextLabel label;
	[Export]
	public ElementalType Element {
		get => _element;
		set {
			if(label == null) return;

			if(value == null) { _element = ElementManager.Blank; }
			else { _element = value; }
			label.Text = $"[center][color={_element.GetTextColor().ToHtml()}]{_element.Name}[/color][/center]";
			Color = _element.MainColor;
		}
	}
	private ElementalType _element;
}
