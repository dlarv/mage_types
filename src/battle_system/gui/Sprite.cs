using Godot;
using System;

public partial class Sprite : Sprite2D
{
	[Export]
	private Sprite2D sprite = null;
	private bool use_gradient_sprite = false;

	public void SetGradientSprite(ElementalType element1, ElementalType element2) {
		Gradient grad = new Gradient();
		use_gradient_sprite = true;

		if(element1 != null) {
			grad.SetColor(0, element1.MainColor);
		}
		if(element2 != null) {
			grad.SetColor(1, element2.MainColor);
		}
		
		GradientTexture2D tex = new GradientTexture2D();
		tex.Gradient = grad;
		Texture = tex;
	}

	public void SetElement(int id, ElementalType element) {
		if(use_gradient_sprite) {
			((GradientTexture2D)Texture).Gradient.SetColor(id, element.MainColor);
		}
	}

}
