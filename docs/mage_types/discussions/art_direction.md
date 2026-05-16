# Claymation
I want the game as a whole to have an arts-and-crafts aesthetics. The assets should look like they were gathered to make a stop motion animation.

[Clay Doh](https://blendermarket.com/products/claydoh) by DoubleGum is a procedural shader pack that gives objects a clay-like material. It cost $30 and contains 13 different materials presets, which I personally think is a great deal. It has a royalty-free license as well.

Since using claymation textures has a bit more of an indepth workflow, requiring a normal and diffuse map for every surface, which in turn must be baked every time they are updated, I only plan to use these for more important assets. 
- Characters
- Large environmental set pieces

For small decorative assets, a more plasticky texture should be used. Blender's `Principled BSDF` will transfer automatically to Godot, but most other nodes will not. So the workflow for these assets will be as follows:
- Set albedo color inside Blender using `Principled BSDF`.
- After texturing and modeling is done, add roughness map inside of Godot.
	- Make mesh and material unique.
	- Add NoiseTexture to `roughness_texture`.
	- Add noise value to texture.
- ~~If model and/or material is changed in Blender, the object in Godot must be deleted and added back.~~ Changing the model/material will revert the mesh to its original state. To manually reset it, press the reset button next to mesh in inspector.
# General Setting Guidelines
- Clay clothing *roughness*: 0.45-0.5
- Clay skin *roughness*: 0.35-0.4