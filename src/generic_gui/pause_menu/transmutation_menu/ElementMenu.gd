extends Menu

const GRAPHIC_PATH := preload("res://assets/graphics/matchup_graph_v3.png")
const STENCIL_1_PATH := preload("res://assets/graphics/matchup_graphs/stencil_1.png")
const STENCIL_2_PATH := preload("res://assets/graphics/matchup_graphs/stencil_2.png")
const STENCIL_3_PATH := preload("res://assets/graphics/matchup_graphs/stencil_3.png")

@export_range(0, 3) var current_graphic := 0:
	set(val):
		current_graphic = val
		var graphic: CompressedTexture2D
		match current_graphic:
			1: graphic = STENCIL_1_PATH
			2: graphic = STENCIL_2_PATH
			3: graphic = STENCIL_3_PATH
			0,_: graphic = GRAPHIC_PATH

		flow_chart.texture = graphic

var flow_chart: TextureRect:
	get:
		return $"Flow Chart"


func _ready() -> void:
	Settings.use_graph_stencils_toggled.connect(func(val):
		if not val:
			current_graphic = 0)
