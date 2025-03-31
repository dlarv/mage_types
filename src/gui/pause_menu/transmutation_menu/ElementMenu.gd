extends Menu

const GRAPHIC_PATH := preload("res://assets/graphics/matchup_graph_v3.png")
const STENCIL_1_PATH := preload("res://assets/graphics/matchup_graphs/stencil_1.png")
const STENCIL_2_PATH := preload("res://assets/graphics/matchup_graphs/stencil_2.png")
const STENCIL_3_PATH := preload("res://assets/graphics/matchup_graphs/stencil_3.png")

var flow_chart: TextureRect:
	get:
		return $"Flow Chart"
