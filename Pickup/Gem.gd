extends Pickups
class_name Gem

@export var XP : float

func activate():
	super.activate()
	prints("+" + str(XP) + " XP")

	if player_reference:	
		player_reference.gain_XP(XP)
	else:
		push_error("Gem.activate(): player_reference is NULL")
