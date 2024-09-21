@tool
extends Resource 
class_name BattleActor 

enum Stats { HP, MELEE_ATTACK, RANGED_ATTACK, MELEE_DEFENSE, RANGED_DEFENSE, SPEED, EVASION, MANA, }

const MAX_STAT: int = 1000;

signal WasDefeated();
signal StatusEffectAdded(effect);
signal StatusEffectsRemoved(effect);
signal DamageApplied(hp);
signal ElementChanged(id, element);

@export
var ActorName : String = "Guy"; 

@export_category("Stats")
var statuses = StatusEffectManager.new();
var _hp: int
@export
var Hp : int : 
	get: return _hp 
	set(value):
		_hp = value;
		CurrentHp = value;

var CurrentHp : int 
@export
var MeleeAttack : int: 
	get: return _meleeAttack * statuses.MeleeAttackMod
	set(value): _meleeAttack = value; 
var _meleeAttack;

@export
var RangedAttack : int: 
	get: return _rangedAttack * statuses.RangedAttackMod
	set(value): _rangedAttack = value
var _rangedAttack;
@export
var MeleeDefense : int: 
	get: return _meleeDefense * statuses.MeleeDefenseMod
	set(value): _meleeDefense = value; 
var _meleeDefense;
@export
var RangedDefense : int:
	get: return _rangedDefense* statuses.RangedDefenseMod
	set(value): _rangedDefense = value; 
var _rangedDefense;
@export
var Speed : int: 
	get: return _speed * statuses.SpeedMod
	set(value): _speed = value; 
var _speed;
@export
var Evasion : int:
	get: return _evasion * statuses.EvasionMod
	set(value): _evasion = value; 
var _evasion;
@export
var Mana : int 

@export_category("General")
@export
var Element1 : ElementalType:
	get:
		if _e1 == null:
			return ElementManager.Blank;
		return _e1;
	set(value): _e1 = value 
var _e1: ElementalType = ElementManager.Blank;
@export
var Element2: ElementalType :
	get:
		if _e2 == null:
			return ElementManager.Blank;
		return _e2;
	set(value): 
		_e2 = value 

var _e2: ElementalType = ElementManager.Blank;
@export
var ElementalBias : ElementalType = ElementManager.Blank;
@export
# Attack[]
var Attacks: Array[Attack] = []
@export
var sprite_path: PackedScene;
var sprite : Sprite = null;

var Dissonant: 
	get: statuses.IsDissonant()
var Flinching: 
	get: statuses.IsFlinching()
var InStasis: 
	get: statuses.InStasis()
var Defeated: bool: 
	get: return CurrentHp <= 0
var prevElement1 : ElementalType = ElementManager.Blank;
var elementCounter1 : int = 0;
var prevElement2 : ElementalType = ElementManager.Blank;
var elementCounter2 : int = 0;

var aleadyDefeated : bool = false;

func SetElement(id: int, element: ElementalType) -> String:
	var msg = "";
	if id == 0:
		Element1 = element;
	else:
		Element2 = element;
	
	sprite.SetElement(id, element);
	ElementChanged.emit(id, element)

	var mod;
	var dmg;
	# if statuses.IsPhobic(element, mod):
	# 	dmg = (int)((double)Hp * mod.Strength);
	# 	CurrentHp -= dmg;
	# 	msg += $"{ActorName} was hurt by its phobia! ({dmg} damage)";
	# }
	# elif statuses.IsPhilic(element, out mod):
	# 	dmg = (int)((double)Hp * mod.Strength);
	# 	CurrentHp += dmg;
	# 	msg += $"{ActorName} was healed by its philia! ({dmg} damage)";
	# }
	return msg;

func UseGradientSprite()-> void:
	sprite = Sprite.new();
	sprite.SetGradientSprite(Element1, Element2);

static func GetMaxStat()-> int:
	return 100000

# public Dictionary<string, int> GetStats() {
# 	return new Dictionary<string, int>() {
# 		{ "hp", Hp },
# 		{ "attack", MeleeAttack },
# 		{ "defense", MeleeDefense },
# 		{ "speed", MeleeDefense },
# 	};
# }
func GetStatFromString(name: String) -> int:
	match name.to_lower().strip_edges():
		"hp","health","max_health","max health": return Hp;
		"attack","melee_attack","melee attack": return MeleeAttack;
		"defense","melee_defense","melee defense": return MeleeDefense;
		"ranged_attack","ranged attack": return RangedAttack;
		"ranged_defense","ranged defense": return RangedDefense;
		"speed": return Speed;
		"evasion": return Evasion;
		"mana": return Mana;
		_: return -1;

func GetStat(stat) -> int:
	if stat is String:
		return GetStatFromString(stat)

	match stat:
		Stats.MELEE_ATTACK:
			return MeleeAttack;
		Stats.MELEE_DEFENSE:
			return MeleeDefense;
		Stats.RANGED_ATTACK:
			return RangedAttack;
		Stats.RANGED_DEFENSE:
			return RangedDefense;
		Stats.SPEED:
			return Speed;
		Stats.EVASION:
			return Evasion;
		Stats.MANA:
			return Mana;
		_:
			return -1;

func SetStatFromString(name: String, value: int) -> void:
	# name = Regex.Replace(name, "[-_ ]", "").ToLower().Trim();
	match name:
		"hp","health","maxhealth","maxhp":
			Hp = value;
			CurrentHp = value;
			
		"attack","meleeattack","mattack":
			MeleeAttack = value;
			
		"defense","meleedefense","mdefense":
			MeleeDefense = value;
			
		"rangedattack","rattack":
			RangedAttack = value;
			
		"rangeddefense","rdefense": 
			RangedDefense = value;
			
		"speed":
			Speed = value;
			
		"evasion":
			Evasion = value;
			
		"mana":
			Mana = value;
			
func SetStat(stat, value: int) -> void:
	if(stat is String):
		SetStatFromString(stat, value)
		return

	match stat:
		Stats.MELEE_ATTACK:
			MeleeAttack = value;
			
		Stats.MELEE_DEFENSE:
			MeleeDefense = value;
			
		Stats.RANGED_ATTACK:
			RangedAttack = value;
			
		Stats.RANGED_DEFENSE:
			RangedDefense = value;
			
		Stats.SPEED:
			Speed = value;
			
		Stats.EVASION:
			Evasion = value;
			
		Stats.MANA:
			Mana = value;
			
func GetAttackStat(action: BattleAction) -> int:
	if action.attack_range == BattleAction.AttackRange.Melee:
		return MeleeAttack;
	return RangedAttack;

func GetDefenseStat(action: BattleAction) -> int:
	if action.attack_range == BattleAction.AttackRange.Melee:
		return MeleeDefense;
	return RangedDefense;

# Returns actual amount of damage applied, after accounting for status conditions.
func ApplyDamage(dmg: int, allowBlocking: bool=true) -> int:
	if not (statuses.IsBlocking() and allowBlocking):
		CurrentHp -= dmg;
		DamageApplied.emit(CurrentHp)
		if CurrentHp <= 0 and not aleadyDefeated:
			aleadyDefeated = true;
			WasDefeated.emit()
		return dmg;
	return 0;

func AddStatusEffect(effect: StatusEffect) -> void:
	statuses.Add(effect);
	StatusEffectAdded.emit(statuses.Get(effect))

func RemoveStatusEffect(effect: StatusEffect) -> void:
	statuses.Remove(effect);
	StatusEffectsRemoved.emit([ effect ])

func HasStatusEffect(effect: StatusEffect) -> bool:
	return statuses.Get(effect) != null;

func UpdateElementalState()-> void:
	if(prevElement1 == Element1): elementCounter1 += 1;
	else: elementCounter1 = 0;

	if(prevElement2 == Element2): elementCounter2 += 1;
	else: elementCounter2 = 0;

	prevElement1 = Element1;
	prevElement2 = Element2;

func TryRevertToBias()-> bool:
	return false;

func ListStatusEffects():
	return statuses.List();

func ResolveEndOfTurn()-> String:
	# Calc poison and healing.
	var msg = "";
	var mod = 0;
	var poison = statuses.Poison;
	var healing = statuses.Healing;

	if poison > 0:
		mod += poison;
		msg += "{ActorName} was hurt by poison ({Hp * poison})";
	if healing > 0:
		mod -= healing;
		msg += "{ActorName} recovered {Hp * healing} health";
	CurrentHp -= Hp * mod;
	DamageApplied.emit(CurrentHp)

	var effects = statuses.CalculateExpirations();
	StatusEffectsRemoved.emit(effects)
	return msg;
