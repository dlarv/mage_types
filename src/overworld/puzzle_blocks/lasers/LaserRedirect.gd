@tool
extends PuzzleBlock
## Receives up to 2 lasers from the sides, mixes them, and emits them out the front.
## Lasers react with this puzzleblock, then with each other.
## If two lasers are received and neither react with each other, no laser is emitted.

var _laser_w: Laser
var _element_e := ElementManager.Blank
var _laser_e: Laser
var _element_w := ElementManager.Blank
# var _is_emitting := false


func _enter_tree() -> void:
	$SubEmitter.stop()


func _on_sub_receiver_e_laser_received(laser:Laser, point:Vector3) -> void:
	if in_stasis: return
	_laser_e = laser

	var res := ElementManager.get_matchup(laser.element, element)
	if not res:
		Logger.append_puzzle_log("LaserRedirect(%s) of Element(%s) + Laser(%s) => NULL => LaserElement(%s)."
				% [puzzle_name, element.name, laser.element.name, laser.element.name])
		_element_e = laser.element
	else:
		Logger.append_puzzle_log("LaserRedirect(%s) of Element(%s) + Laser(%s) => NewElement(%s)." 
				% [puzzle_name, element.name, laser.element.name, res.name])
		_element_e = res
	_react()


func _on_sub_receiver_w_laser_received(laser:Laser, point:Vector3) -> void:
	if in_stasis: return
	_laser_w = laser

	var res := ElementManager.get_matchup(laser.element, element)
	if not res:
		Logger.append_puzzle_log("LaserRedirect(%s) of Element(%s) + Laser(%s) => NULL => LaserElement(%s)."
				% [puzzle_name, element.name, laser.element.name, laser.element.name])
		_element_w = laser.element
	else:
		Logger.append_puzzle_log("LaserRedirect(%s) of Element(%s) + Laser(%s) => NewElement(%s)." 
				% [puzzle_name, element.name, laser.element.name, res.name])
		_element_w = res
	_react()


func _on_sub_receiver_e_laser_dropped() -> void:
	_laser_e = null
	_element_e = ElementManager.Blank
	_react()


func _on_sub_receiver_w_laser_dropped() -> void:
	_laser_w = null
	_element_w = ElementManager.Blank
	_react()


func _react() -> void:
	if not _laser_e and not _laser_w: 
		$SubEmitter.stop()
		return
	if in_stasis: return

	# Blank/null + Blank/null = Blank/null
	# Element + Blank/null = Element
	# Element1 + Element2 = NULL = no laser
	# Element1 + Element1 = Element1
	# Element1 + Element2 = Element3 = Element3
	var laserElementOutput: ElementalType 
	var isElement1Valid := _element_e and not _element_e.is_blank()
	var isElement2Valid := _element_w and not _element_w.is_blank()

	if not isElement1Valid and not isElement2Valid:
		laserElementOutput = ElementManager.Blank
		_element_e = ElementManager.Blank
		_element_w = ElementManager.Blank
	elif not isElement1Valid:
		laserElementOutput = _element_w
		_element_e = ElementManager.Blank
	elif not isElement2Valid:
		laserElementOutput = _element_e
		_element_w = ElementManager.Blank
	elif _element_e == _element_w:
		laserElementOutput = _element_e
	else:
		laserElementOutput = ElementManager.get_matchup(_element_e, _element_w)

	if not laserElementOutput:
		Logger.append_puzzle_log("LaserRedirect(%s) output = Element(%s) + Element(%s) = NULL."
			% [puzzle_name, _element_e.name, _element_w.name])
		$SubEmitter.stop()
		return

	Logger.append_puzzle_log("LaserRedirect(%s) output = Element(%s) + Element(%s) = Element(%s)." 
		% [puzzle_name, _element_e.name, _element_w.name, laserElementOutput.name])

	$SubEmitter.set_element(laserElementOutput)
	$SubEmitter.start()
