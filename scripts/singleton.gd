extends Node

var start_dialogue = false
var Kstart_dialogue = false
var Bstart_dialogue = false

var stylet_picked = false
var stylet_used = false
var read_letter = false

var roach_int = false
var roach_picked = false
var roach_used = false
var hole_anim = false

var faucet_int = false
var plumb_int = false
var rat_anim = false
var fridgestart = false

var mirror_anim = false
var saw_veins = false

var read_diary = false
var crowbar_picked = false

var tension = false
var lights_on = false

var kitchennightmaresaw = false
var bathroomnightmaresaw = false
var bedroomnightmaresaw = false
var hallnightmare = false

var notice1 = false
var notice1read = false

func _process(delta: float) -> void:
	if kitchennightmaresaw and bathroomnightmaresaw and stylet_used and read_letter:
		notice1 = true
