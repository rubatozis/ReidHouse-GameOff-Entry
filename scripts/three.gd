extends Node2D

var visible_characters = 0

var detail_selected = false

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
# FINAL CUTSCENE
	if $backgroundLeft.visible and Singleton.saw_veins and Singleton.mirror_anim and !detail_selected and !Singleton.bathroomnightmaresaw:
		$dialog.visible = true
		$dialog/close.visible = false
		detail_selected = true
		$dialog/label.text = "...Oh no."
		dialoganim()
		$move/toLR3.visible = false
		$backgroundLeft.visible = false
		$backgroundLeftNghtmr1.visible = true
		$finalTimer1.start()
		Arvostus.stop()
		BlastedHeath.stop()
		ItsInTheWalls.play()
		$veinsNoise.play()
func _on_final_timer_1_timeout() -> void:
	$backgroundLeftNghtmr1.visible = false
	$backgroundLeftNghtmr2.visible = true
	$dialog/label.text = "Oh no no no no no. Nope."
	dialoganim()
	$finalTimer2.start()
	Singleton.bathroomnightmaresaw = true
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
		if $backgroundLeft.visible and !$move/toLR3.visible:
			$move/toLR3.visible = true
		changecrsr_def()
		if $backgroundRight.visible and $inspect/right.visible:
			if !$inspect/right/bathtubArea.visible:
				$inspect/right/bathtubArea.visible = true
		if !Arvostus.playing and !Singleton.notice1read and !Singleton.tension:
			Arvostus.play()
		if !SafeForNow.playing and Singleton.notice1read and !Singleton.tension:
			SafeForNow.play()

# MOVE BACK TO LIVING ROOM
func _on_to_lr_3_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		get_tree().change_scene_to_file(target_level)

# LOOK RIGHT
func _on_right_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		$inspect/left.visible = false
		$inspect/right.visible = true
		$backgroundLeft.visible = false
		$backgroundRight.visible = true
		$move/right.visible = false
		$move/left.visible = true
		$move/toLR3.visible = false

# LOOK LEFT
func _on_left_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		$inspect/left.visible = true
		$inspect/right.visible = false
		$backgroundLeft.visible = true
		$backgroundRight.visible = false
		$move/right.visible = true
		$move/left.visible = false
		$move/toLR3.visible = true
		

# SCENE 3
func _ready() -> void:
	Input.set_custom_mouse_cursor(default_crsr)
	$fadein/AnimationPlayer.play("fadein")
	$walkNoise.play()
	$doorNoise.play()
	if !Singleton.Bstart_dialogue:
		$dialog.visible = true
		$dialog/label.text = "Ugh, what is this smell?"
		detail_selected = true
		dialoganim()
		Singleton.Bstart_dialogue = true
		$move/toLR3.visible = false
	if Singleton.tension:
		Singleton.tension = false
		if BlastedHeath.playing:
			BlastedHeath.stop()
		if !Arvostus.playing:
			Arvostus.play()


# OBJECTS - LEFT SIDE

#TOILET
func _on_toilet_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		$dialog.visible = true
		detail_selected = true
		$dialog/label.text = "I'm not opening that."
		dialoganim()
		$move/toLR3.visible = false

#TOILET PAPER
func _on_paper_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		$dialog.visible = true
		detail_selected = true
		$dialog/label.text = "It's cheap and old. It kind of looks like the paper absorbed the dust."
		dialoganim()
		$move/toLR3.visible = false

#CLOSET
func _on_closet_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		$dialog.visible = true
		detail_selected = true
		$dialog/label.text = "It's mostly empty, except for a toothbrush that looks disgusting, and few health products. They are all spoiled."
		dialoganim()
		$move/toLR3.visible = false

#TRASH
func _on_trash_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		$dialog.visible = true
		detail_selected = true
		$dialog/label.text = "It's full of... Hair. This entire place is covered in hair. Poor Reid..."
		dialoganim()
		$move/toLR3.visible = false

#SINK
func _on_sink_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		detail_selected = true
		$move/toLR3.visible = false
		if !Singleton.mirror_anim:
			$closeupsinkstatic.visible = true
			$closeupsinkstatic/sinkTimer.start()
		else:
			$dialog.visible = true
			$dialog/label.text = "There is so much hair, it's nightmarish."
			dialoganim()
func _on_sink_timer_timeout() -> void:
	$closeupsinkstatic.visible = false
	$closeupmirroranim.visible = true
	$closeupmirroranim.play("default")
	$closeupmirroranim/mirrorTimer.start()
	if Arvostus.playing:
		Arvostus.stop()
	BlastedHeath.play()
	Singleton.tension = true
func _on_mirror_timer_timeout() -> void:
	$closeupmirroranim.visible = false
	$dialog.visible = true
	$dialog/label.text = "?! ...This place is messing with my head..."
	dialoganim()
	Singleton.mirror_anim = true

#SINK PIPES
func _on_pipes_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		detail_selected = true
		$move/toLR3.visible = false
		if !Singleton.plumb_int:
			$dialog.visible = true
			$dialog/label.text = "It's leaking and appears to be rusty. It's also... Oddly warm...?"
			dialoganim()
		else:
			$dialog.visible = true
			$dialog/label.text = "I don't know if I want to touch any more plumbing today."
			dialoganim()

#BLACK LIQUID
func _on_goo_areas_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		$dialog.visible = true
		detail_selected = true
		$dialog/label.text = "An unknown black liquid flows from the plumbing. It smells like nothing I know."
		dialoganim()
		$move/toLR3.visible = false

#SINK FAUCET
func _on_faucet_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		$dialog.visible = true
		detail_selected = true
		$dialog/label.text = "I don't want to touch that."
		dialoganim()
		$move/toLR3.visible = false

#MIRROR
func _on_mirror_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		detail_selected = true
		$move/toLR3.visible = false
		if !Singleton.mirror_anim:
			$dialog.visible = true
			$dialog/label.text = "It's mostly broken. Bad luck."
			dialoganim()
		else:
			$dialog.visible = true
			$dialog/label.text = "It's me. It's just me. I am alone."
			dialoganim()

#TOWELS
func _on_towels_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		$dialog.visible = true
		detail_selected = true
		$dialog/label.text = "A little worn, but surprisingly soft. Only one appears to have been used often."
		dialoganim()
		$move/toLR3.visible = false

#TUB COVER
func _on_cover_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		$dialog.visible = true
		detail_selected = true
		$dialog/label.text = "There are a few holes here and there, from bugs. It's dragging on the floor and looks wet and disgusting."
		dialoganim()
		$move/toLR3.visible = false


# OBJECTS - RIGHT SIDE

#TUB COVER 2
func _on_cover_area_2_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		$dialog.visible = true
		detail_selected = true
		$dialog/label.text = "Looking closer, there's a little spider hiding here. It looks tired. It's not big enough to eat all the cockroaches, and it knows it."
		dialoganim()
		$move/toLR3.visible = false
		$inspect/right/bathtubArea.visible = false

#BATHTUB
func _on_bathtub_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		$dialog.visible = true
		detail_selected = true
		$dialog/label.text = "Many, many strands of hair cover the bottom. The tub is dirty and gross. Like it absorbed Reid's rot whenever he bathed in it."
		dialoganim()
		$move/toLR3.visible = false
		$inspect/right/bathtubArea.visible = false

#SOAP
func _on_soap_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		$dialog.visible = true
		detail_selected = true
		$dialog/label.text = "It's rotting and unusable."
		dialoganim()
		$move/toLR3.visible = false
		$inspect/right/bathtubArea.visible = false

#SHOWER
func _on_shower_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		$dialog.visible = true
		detail_selected = true
		$dialog/label.text = "Hair creeps through the holes like veins. Ugh. It appears to be malfunctioning."
		dialoganim()
		$move/toLR3.visible = false
		$inspect/right/bathtubArea.visible = false

#HAIRS ON FLOOR
func _on_hairs_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		$dialog.visible = true
		detail_selected = true
		$dialog/label.text = "What was happening to him?"
		dialoganim()
		$move/toLR3.visible = false
		$inspect/right/bathtubArea.visible = false

#VEINS BEHIND TUB
func _on_veins_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		$dialog.visible = true
		detail_selected = true
		$dialog/label.text = "...What in God's name are these?"
		dialoganim()
		$move/toLR3.visible = false
		$inspect/right/bathtubArea.visible = false
		Singleton.saw_veins = true
