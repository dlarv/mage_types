@tool
extends _BaseEffectSlot
class_name ReaderSlot
## Slot that reads from battefield state and writes to DataBuffer.buffer.
## Does not actually apply any effects to the BattleActors.

#override
func apply_effect(data: ActorTurnData, target: BattleActor, effectiveness:=1.0) -> ActorTurnData:
	return data
