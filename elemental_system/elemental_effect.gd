extends Node
class_name ElementalEffect

enum Effect {
	NONE,
	DOT, 
	HOT, 
	DAMAGE_BOOST, 
	HEAL, 
	ATTACK_UP, 
	ATTACK_DOWN, 
	DEFENSE_UP, 
	DEFENSE_DOWN, 
	SPEED_UP, 
	SPEED_DOWN,
	SPLASH,
	}

static func get_icon(effect: Effect):
	match effect:
		Effect.NONE:
			return ""
		Effect.DOT:
			return "DOT"
		Effect.HOT:
			return "HOT"
		Effect.DAMAGE_BOOST:
			return "DMG"
		Effect.HEAL:
			return "H"
		Effect.ATTACK_UP:
			return "+A"
		Effect.ATTACK_DOWN:
			return "-A"
		Effect.DEFENSE_UP:
			return "+D"
		Effect.DEFENSE_DOWN:
			return "-D"
		Effect.SPEED_UP:
			return "+S"
		Effect.SPEED_DOWN:
			return "-S"
		Effect.SPLASH:
			return "SPL"
