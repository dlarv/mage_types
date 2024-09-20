@tool
extends Damage 
class_name RecoilDamage 

# override
func ApplyEffect(user, target=null, action=null):
	var dmg = CalculateDamage(user.GetAttackStat(action), user.GetDefenseStat(action), action)
	dmg = user.ApplyDamage(dmg)
	return "%s was hurt by recoil (%d damage)." % [ target.ActorName, dmg ]
