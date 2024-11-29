extends Node2D

var visible_characters = 0

var detail_selected = false
var lights_on = false

var slot1_filled = false
var slot2_filled = false
var slot3_filled = false

var default_crsr = preload("res://assets/art/cursors1.png")
var inspect_crsr = preload("res://assets/art/cursors2.png")
var hand_crsr = preload("res://assets/art/cursors3.png")
var walk_crsr = preload("res://assets/art/cursors4.png")

@export_file("*.tscn") var target_level: String

# MOUSE STUFF
func changecrsr_insp():
	if !detail_selected:
		Input.set_custom_mouse_cursor(inspect_crsr)

func changecrsr_def():
	if !detail_selected:
		Input.set_custom_mouse_cursor(default_crsr)

func changecrsr_hand():
	if !detail_selected:
		Input.set_custom_mouse_cursor(hand_crsr)

func changecrsr_walk():
	if !detail_selected:
		Input.set_custom_mouse_cursor(walk_crsr)

# DIALOG ANIMATION
func dialoganim():
	$dialog/dialoganim.play("typewriter2")

# DIALOG TYPE NOISE
func _process(delta: float) -> void:
	if visible_characters != $dialog/label.visible_characters:
		visible_characters = $dialog/label.visible_characters
		$typenoise.play()
# KITCHEN LAST CUTSCENE
	if !detail_selected and Singleton.plumb_int and Singleton.rat_anim and Singleton.fridgestart and !Singleton.kitchennightmaresaw:
		$dialog.visible = true
		$dialog/close.visible = false
		detail_selected = true
		$dialog/label.text = "...What the fuck?"
		dialoganim()
		$background.visible = false
		$backgroundNghtmr1.visible = true
		$finalTimer1.start()
		$move/toLR1.visible = false
		$bugsNoise.play()
		BlastedHeath.stop()
		ItsInTheWalls.play()
func _on_final_timer_1_timeout() -> void:
	$backgroundNghtmr1.visible = false
	$backgroundNghtmr2.visible = true
	$dialog/label.text = "I'm out of here."
	dialoganim()
	$finalTimer2.start()
	Singleton.kitchennightmaresaw = true
func _on_final_timer_2_timeout() -> void:
	get_tree().change_scene_to_file(target_level)

# Inventory things
func fill_slot(slot):
	match slot:
		1:	slot1_filled = true
		2:	slot2_filled = true
		3:	slot3_filled = true

func empty_slot(slot):
	match slot:
		1:	slot1_filled = false
		2:	slot2_filled = false
		3:	slot3_filled = false

func choose_slot(item):
	var chosen_slot = 1
	if !slot1_filled:
		chosen_slot = $inventory/slot1.global_position
		slot1_filled = true
		item.drop_location_id = 1
	elif !slot2_filled:
		chosen_slot = $inventory/slot2.global_position
		slot1_filled = true
		item.drop_location_id = 2
	elif !slot3_filled:
		chosen_slot = $inventory/slot3.global_position
		slot1_filled = true
		item.drop_location_id = 3
	return chosen_slot

func set_drop_location(item):
	var drop_location
	match item.drop_location_id:
		0: drop_location = item.global_position
		1: drop_location = $inventory/slot1.global_position
		2: drop_location = $inventory/slot2.global_position
		3: drop_location = $inventory/slot3.global_position
	return drop_location


func _on_slot_1_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("item") and !slot1_filled:
		empty_slot(area.get_parent().drop_location_id)
		area.get_parent().drop_location_id = 1
		fill_slot(area.get_parent().drop_location_id)


func _on_slot_2_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("item") and !slot2_filled:
		empty_slot(area.get_parent().drop_location_id)
		area.get_parent().drop_location_id = 2
		fill_slot(area.get_parent().drop_location_id)


func _on_slot_3_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("item") and !slot3_filled:
		empty_slot(area.get_parent().drop_location_id)
		area.get_parent().drop_location_id = 3
		fill_slot(area.get_parent().drop_location_id)

# DIALOG CLOSE BUTTON
func _on_close_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		$dialog.visible = false
		detail_selected = false
		$move/toLR1.visible = true
		changecrsr_def()
		if !Arvostus.playing and !Singleton.notice1read and !Singleton.tension:
			Arvostus.play()
		if !$inspect/stoveArea.visible:
			$inspect/stoveArea.visible = true

# SCENE 1
func _ready() -> void:
	Input.set_custom_mouse_cursor(default_crsr)
	$fadein/AnimationPlayer.play("fadein")
	$walkNoise.play()
	if !Singleton.Kstart_dialogue:
		$dialog.visible = true
		$dialog/label.text = "The lights are not working here..."
		dialoganim()
		Singleton.Kstart_dialogue = true
		$move/toLR1.visible = false
		$inspect/stoveArea.visible = false
		detail_selected = true
	if Singleton.tension:
		Singleton.tension = false
		if BlastedHeath.playing:
			BlastedHeath.stop()
		if !Arvostus.playing:
			Arvostus.play()


# MOVE BACK TO LIVING ROOM

func _on_to_lr_1_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		get_tree().change_scene_to_file(target_level)


#INSPECT

#INFESTATION
func _on_infest_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		$dialog.visible = true
		detail_selected = true
		$dialog/label.text = "Oh, what the fuck, no wonder they're all here... There's this weird black goo on the floor too. No idea what it is. I'm not touching that."
		dialoganim()
		$move/toLR1.visible = false
		$inspect/stoveArea.visible = false

#DEAD RAT
func _on_rat_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		detail_selected = true
		$move/toLR1.visible = false
		$inspect/stoveArea.visible = false
		if !Singleton.rat_anim:
			$closeupratstatic1.visible = true
			$closeupratstatic1/ratTimer1.start()
		else:
			$closeupratstatic2.visible = true

func _on_rat_timer_1_timeout() -> void:
	$closeupratstatic1.visible = false
	$closeupratanim.visible = true
	$closeupratanim.play("default")
	$closeupratanim/ratTimer2.start()
	$closeupratanim/ratAudio.play()
	if Arvostus.playing:
		Arvostus.stop()
	if !BlastedHeath.playing:
		BlastedHeath.play()
	Singleton.tension = true
func _on_rat_timer_2_timeout() -> void:
	$closeupratanim.visible = false
	Singleton.rat_anim = true
	$dialog.visible = true
	$dialog/label.text = "...What the actual fuck? I think I'm gonna puke..."
	dialoganim()

func _on_clspclose_1_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		$closeupratstatic2.visible = false
		detail_selected = false
		$move/toLR1.visible = true
		changecrsr_def()
		if !Arvostus.playing and !Singleton.notice1read and !Singleton.tension:
			Arvostus.play()
		if !$inspect/stoveArea.visible:
			$inspect/stoveArea.visible = true


#SINK COUNTER
func _on_countercloset_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		$dialog.visible = true
		detail_selected = true
		dialoganim()
		$move/toLR1.visible = false
		$inspect/stoveArea.visible = false
		if !Singleton.faucet_int:
			$dialog/label.text = "It's filled with poorly cleaned pans and pots. And some roaches who decided to live in them."
		else:
			if !Singleton.plumb_int:
				$dialog/label.text = "There are pipes behind all the pans. But there doesn't seem to be anything wrong with them... ?!"
				$inspect/counterclosetArea/pulse.play()
				$inspect/counterclosetArea/pulsetimer.start()
				$dialog/close.visible = false
				if Arvostus.playing and !Singleton.tension:
					Arvostus.stop()
				if !BlastedHeath.playing:
					BlastedHeath.play()
				Singleton.tension = true
			else:
				$dialog/label.text = "I don't want to look there again."

func _on_pulsetimer_timeout() -> void:
	$inspect/counterclosetArea/pulse.stop()
	$dialog/label.text = "...For a moment it felt like they were pulsating. It must have been my imagination."
	dialoganim()
	$dialog/close.visible = true
	Singleton.plumb_int = true

#DRAWERS
func _on_drawers_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		$dialog.visible = true
		detail_selected = true
		$dialog/label.text = "Slightly dirty cutlery and cooking tools. Not many, though-- the drawers are mostly empty."
		dialoganim()
		$move/toLR1.visible = false
		$inspect/stoveArea.visible = false

#FALLEN MUG
func _on_mug_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		$dialog.visible = true
		detail_selected = true
		$dialog/label.text = "A fallen mug, with what appears to be now dried coffee flowing out of it. It has a drawing that says 'best husband in the world'."
		dialoganim()
		$move/toLR1.visible = false
		$inspect/stoveArea.visible = false

#KNIFE
func _on_knife_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		$dialog.visible = true
		detail_selected = true
		$dialog/label.text = "A knife. Its blade is dirty with something I can't quite recognize. It smells like dirt and metal."
		dialoganim()
		$move/toLR1.visible = false
		$inspect/stoveArea.visible = false

#MUG ROACH
func _on_thirstyroach_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		$dialog.visible = true
		detail_selected = true
		$dialog/label.text = "It's trying to drink whatever remains of the coffee. It is not succeeding."
		dialoganim()
		$move/toLR1.visible = false
		$inspect/stoveArea.visible = false

#COOKING POT
func _on_pot_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		$dialog.visible = true
		detail_selected = true
		$dialog/label.text = "A notably large cooking pot. It appears to be burnt in several areas. It is unclean."
		dialoganim()
		$move/toLR1.visible = false
		$inspect/stoveArea.visible = false

#MOLD
func _on_mold_areas_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		$dialog.visible = true
		detail_selected = true
		$dialog/label.text = "Mold clings to the walls, forming repulsive dark spots."
		dialoganim()
		$move/toLR1.visible = false
		$inspect/stoveArea.visible = false

#SINK
func _on_sink_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		$dialog.visible = true
		detail_selected = true
		$dialog/label.text = "Looks like someone was struggling to do the dishes...... It's even started to smell."
		dialoganim()
		$move/toLR1.visible = false
		$inspect/stoveArea.visible = false

#SINK FAUCET
func _on_faucet_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		$dialog.visible = true
		detail_selected = true
		dialoganim()
		$move/toLR1.visible = false
		$inspect/stoveArea.visible = false
		if !Singleton.faucet_int:
			$dialog/label.text = "It's not working. There must be something wrong with the plumbing. Maybe I should check under the sink."
			Singleton.faucet_int = true
		else:
			$dialog/label.text = "I should check under the sink to see why there's no water."
		if Singleton.plumb_int:
			$dialog/label.text = "Maybe this just isn't my field..."
			

#WINDOW
func _on_window_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		$dialog.visible = true
		detail_selected = true
		$dialog/label.text = "Nothing but the infinite expanse of the forest outside."
		dialoganim()
		$move/toLR1.visible = false
		$inspect/stoveArea.visible = false

#BLENDER
func _on_blender_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		$dialog.visible = true
		detail_selected = true
		$dialog/label.text = "A blender. It appears to be the most intact object in here."
		dialoganim()
		$move/toLR1.visible = false
		$inspect/stoveArea.visible = false

#STOVE
func _on_stove_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		$dialog.visible = true
		detail_selected = true
		$dialog/label.text = "The stove is covered in grease and dust. There are some marks of burning too."
		dialoganim()
		$move/toLR1.visible = false
		$inspect/stoveArea.visible = false

#FRIDGE
func _on_fridge_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		$dialog.visible = true
		detail_selected = true
		dialoganim()
		$move/toLR1.visible = false
		$inspect/stoveArea.visible = false
		if !Singleton.fridgestart:
			$dialog/label.text = "It's mostly empty, except for canned beans, moldy bread and... What the hell are those jars?"
			$dialog/close.visible = false
			$fridgeTimer1.start()
		else:
			$dialog/label.text = "I don't want to think about what he was doing with those. Should I notify the police?... Probably once he's more stable."
func _on_fridge_timer_1_timeout() -> void:
	$dialog.visible = false
	$closeupfridge.visible = true
	$fridgeTimer2.start()
	if Arvostus.playing and !Singleton.tension:
		Arvostus.stop()
	if !BlastedHeath.playing:
		BlastedHeath.play()
	Singleton.tension = true
func _on_fridge_timer_2_timeout() -> void:
	$closeupfridge.visible = false
	$dialog.visible = true
	$dialog/close.visible = true
	dialoganim()
	$dialog/label.text = "I can't recognize the... Organs. They look rotten, as though they were stolen from a corpse. The bones appear human. This can't be good."
	Singleton.fridgestart = true
