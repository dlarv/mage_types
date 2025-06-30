@tool
extends Item 
class_name KeyItem 

enum UniqueId { STASIS, CATALYST, DESTROY, GOLEM, SET_PORTAL, USE_PORTAL }

@export var unique_id: UniqueId
