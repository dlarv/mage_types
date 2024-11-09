@tool
extends Control

@export var label: Label
@export var grid: GridContainer
@export var b: Control
@export var p: Control
@export var m: Control
@export var r: Control
@export var o: Control
@export var y: Control
@export var g: Control
@export var c: Control

@export var b_p: Control
@export var b_m: Control
@export var b_c: Control

@export var p_b: Control
@export var p_m: Control
@export var p_c: Control

@export var m_b: Control
@export var m_p: Control
@export var m_r: Control

@export var r_o: Control
@export var r_m: Control
@export var r_y: Control

@export var o_r: Control
@export var o_p: Control
@export var o_m: Control
@export var o_y: Control

@export var y_r: Control
@export var y_g: Control
@export var y_o: Control

@export var g_y: Control
@export var g_c: Control

@export var c_b: Control
@export var c_g: Control

var _b_edges: Array
var _p_edges: Array
var _m_edges: Array
var _r_edges: Array
var _o_edges: Array
var _y_edges: Array
var _g_edges: Array
var _c_edges: Array

var _edges = {}

func _ready() -> void:
	var B := ElementManager.Blue
	var P := ElementManager.Purple
	var M := ElementManager.Magenta
	var R := ElementManager.Red
	var O := ElementManager.Orange
	var Y := ElementManager.Yellow
	var G := ElementManager.Green
	var C := ElementManager.Cyan
	_edges[[B,P]] = b_p
	_edges[[B,M]] = b_m
	_edges[[B,C]] = b_c
	_edges[[P,B]] = p_b
	_edges[[P,M]] = p_m
	_edges[[P,C]] = p_c
	_edges[[M,B]] = m_b
	_edges[[M,P]] = m_p
	_edges[[M,R]] = m_r
	_edges[[R,O]] = r_o
	_edges[[R,M]] = r_m
	_edges[[R,Y]] = r_y
	_edges[[O,R]] = o_r
	_edges[[O,P]] = o_p
	_edges[[O,M]] = o_m
	_edges[[O,Y]] = o_y
	_edges[[Y,R]] = y_r
	_edges[[Y,G]] = y_g
	_edges[[Y,O]] = y_o
	_edges[[G,Y]] = g_y
	_edges[[G,C]] = g_c
	_edges[[C,B]] = c_b
	_edges[[C,G]] = c_g

	_b_edges = [ b_p, b_m, b_c, p_b, m_b, c_b ]
	_p_edges = [ p_b, p_m, o_p, b_p, m_p ]
	_m_edges = [ m_p, m_r, m_b, o_m, r_m, p_m, b_m ]
	_r_edges = [ r_m, r_o, r_y, o_r, m_r, y_r ]
	_o_edges = [ o_r, o_m, o_p, o_y, y_o, y_r ]
	_y_edges = [ y_o, y_r, y_g, r_y, g_y, o_y ]
	_g_edges = [ g_y, g_c, c_g, y_g ]
	_c_edges = [ c_b, c_g, g_c, b_c, p_c ]


func draw_graph(graph: Dictionary, elements: Array) -> void:
	clear()
	remove_islands(elements)
	var startNodes := []
	var endNodes := []

	for key in _edges.keys():
		if not key in graph.keys() and not _edges[key].is_empty:
			_edges[key].override_to_dash()
	for key in graph.keys():
		if not key[0] in startNodes:
			startNodes.append(key[0])
		if not key[1] in endNodes:
			endNodes.append(key[1])

	var counter := 0
	for end in endNodes:
		if not end in startNodes:
			counter += 1
			match end:
				ElementManager.Blue:
					b.mark_as_softlock()
				ElementManager.Purple:
					p.mark_as_softlock()
				ElementManager.Magenta:
					m.mark_as_softlock()
				ElementManager.Red:
					r.mark_as_softlock()
				ElementManager.Orange:
					o.mark_as_softlock()
				ElementManager.Yellow:
					y.mark_as_softlock()
				ElementManager.Green:
					g.mark_as_softlock()
				ElementManager.Cyan:
					c.mark_as_softlock()

	label.text = "%d softlock(s) detected." % counter


func remove_islands(elements: Array) -> void:
	if not ElementManager.Blue in elements:
		b.override_to_empty()
		for edge in _b_edges:
			edge.override_to_empty()
	else:
		b.clear_override()
		for edge in _b_edges:
			edge.clear_override()
	if not ElementManager.Purple in elements:
		p.override_to_empty()
		for edge in _p_edges:
			edge.override_to_empty()
	else:
		p.clear_override()
		for edge in _p_edges:
			edge.clear_override()
	if not ElementManager.Magenta in elements:
		m.override_to_empty()
		for edge in _m_edges:
			edge.override_to_empty()
	else:
		m.clear_override()
		for edge in _m_edges:
			edge.clear_override()
	if not ElementManager.Red in elements:
		r.override_to_empty()
		for edge in _r_edges:
			edge.override_to_empty()
	else:
		r.clear_override()
		for edge in _r_edges:
			edge.clear_override()
	if not ElementManager.Orange in elements:
		o.override_to_empty()
		for edge in _o_edges:
			edge.override_to_empty()
	else:
		o.clear_override()
		for edge in _o_edges:
			edge.clear_override()
	if not ElementManager.Yellow in elements:
		y.override_to_empty()
		for edge in _y_edges:
			edge.override_to_empty()
	else:
		y.clear_override()
		for edge in _y_edges:
			edge.clear_override()
	if not ElementManager.Green in elements:
		g.override_to_empty()
		for edge in _g_edges:
			edge.override_to_empty()
	else:
		g.clear_override()
		for edge in _g_edges:
			edge.clear_override()
	if not ElementManager.Cyan in elements:
		c.override_to_empty()
		for edge in _c_edges:
			edge.override_to_empty()
	else:
		c.clear_override()
		for edge in _c_edges:
			edge.clear_override()


func clear() -> void:
	for child in grid.get_children():
		if child.is_empty: continue
		child.clear_override()
