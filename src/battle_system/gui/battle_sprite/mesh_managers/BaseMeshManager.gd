@abstract
extends Node
class_name MeshManager

@export var mesh: MeshInstance3D

@abstract func setup(actor: BattleActor) -> void
@abstract func set_element(id: int, element: ElementalType) -> void
@abstract func set_defeated() -> void
