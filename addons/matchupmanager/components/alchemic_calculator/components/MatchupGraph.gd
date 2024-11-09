extends Control

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


func draw_graph(graph: Dictionary, elements: Array) -> void:
	clear()
	remove_islands(elements)

	for key in _edges.keys():
		if not key in graph.keys() and not _edges[key].is_empty:
			_edges[key].override_to_dash()


func remove_islands(elements: Array) -> void:
	if not ElementManager.Blue in elements:
		b.override_to_empty()
		b_p.override_to_empty()
		b_m.override_to_empty()
		b_c.override_to_empty()
		p_b.override_to_empty()
		m_b.override_to_empty()
		c_b.override_to_empty()
	if not ElementManager.Purple in elements:
		p.override_to_empty()
		p_b.override_to_empty()
		p_m.override_to_empty()
		o_p.override_to_empty()
		b_p.override_to_empty()
		m_p.override_to_empty()
	if not ElementManager.Magenta in elements:
		m.override_to_empty()
		m_p.override_to_empty()
		m_r.override_to_empty()
		m_b.override_to_empty()
		o_m.override_to_empty()
		r_m.override_to_empty()
		p_m.override_to_empty()
		b_m.override_to_empty()
	if not ElementManager.Red in elements:
		r.override_to_empty()
		r_m.override_to_empty()
		r_o.override_to_empty()
		r_y.override_to_empty()
		o_r.override_to_empty()
		m_r.override_to_empty()
		y_r.override_to_empty()
	if not ElementManager.Orange in elements:
		o.override_to_empty()
		o_r.override_to_empty()
		o_m.override_to_empty()
		o_p.override_to_empty()
		o_y.override_to_empty()
		y_o.override_to_empty()
		y_r.override_to_empty()
	if not ElementManager.Yellow in elements:
		y.override_to_empty()
		y_o.override_to_empty()
		y_r.override_to_empty()
		y_g.override_to_empty()
		r_y.override_to_empty()
		g_y.override_to_empty()
		o_y.override_to_empty()
	if not ElementManager.Green in elements:
		g.override_to_empty()
		g_y.override_to_empty()
		g_c.override_to_empty()
		c_g.override_to_empty()
		y_g.override_to_empty()
	if not ElementManager.Cyan in elements:
		c.override_to_empty()
		c_b.override_to_empty()
		c_g.override_to_empty()
		g_c.override_to_empty()
		b_c.override_to_empty()
		p_c.override_to_empty()

func clear() -> void:
	for child in get_child(0).get_children():
		if child.is_empty: continue
		child.clear_override()
