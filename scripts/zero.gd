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

@export_file("*.tscn") var target_level1: String
@export_file("*.tscn") var target_level2: String
@export_file("*.tscn") var target_level3: String
@export_file("*.tscn") var target_level4: String

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
# NOTICECUTSCENE
	if Singleton.notice1 and !Singleton.notice1read and !detail_selected:
		$dialog.visible = true
		$dialog/label.text = "There is something definitely wrong. Was Reid doing some kind of necromantic spell? If so, what led him to try it? Maybe I should go upstairs-- it's probably where his bedroom is."
		dialoganim()
		detail_selected = true
		Singleton.notice1read = true
		SafeForNow.play()
		Arvostus.stop()
		if Singleton.tension:
			Singleton.tension = false
			BlastedHeath.stop()

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
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		$dialog.visible = false
		detail_selected = false
		changecrsr_def()
		if $label2.visible:
			$label2.visible = false
		if !$inventory.visible:
			$inventory.visible = true
		if !$move/left.visible:
			if $backgroundDark.visible || $backgroundLight.visible || $backgroundRightDark.visible || $backgroundRightDark2.visible || $backgroundRightLight.visible || $backgroundRightLight2.visible:
				$move/left.visible = true
		if !$move/right.visible:
			if $backgroundDark.visible || $backgroundLight.visible || $backgroundLeftDark.visible || $backgroundLeftLight.visible:
				$move/right.visible = true

# SCENE 0
func _ready() -> void:
	$fadein/AnimationPlayer.play("fadein")
	if !Singleton.hallnightmare || !Singleton.bedroomnightmaresaw:
		if !Singleton.start_dialogue:
			$label2.visible = true
			detail_selected = true
			$inventory.visible = false
			$move/left.visible = false
			$move/right.visible = false
			Singleton.start_dialogue = true
			Arvostus.play()
			$firsttimer.start()
		else:
			$walkNoise.play()
		if Singleton.lights_on:
			$backgroundDark.visible = false
			$backgroundLight.visible = true
		if Singleton.tension:
			if Arvostus.playing:
				Arvostus.stop()
			if !BlastedHeath.playing:
				BlastedHeath.play()
		if ItsInTheWalls.playing:
			ItsInTheWalls.stop()
	else: #FINAL CUTSCENE
		$backgroundDark.visible = false
		$backgroundLeftDark.visible = false
		$backgroundNghtmr.visible = true
		Singleton.lights_on = false
		if Arvostus.playing:
			Arvostus.stop()
		if !ItsInTheWalls.playing:
			ItsInTheWalls.play()
		$inspect.visible = false
		$thingNoise1.play()
		$thingNoise2.play()
		$dialog.visible = true
		detail_selected = true
		dialoganim()
		$dialog/close.visible = false
		$dialog/label.text = "Come on now..."
		$doorNoise.play()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	Input.set_custom_mouse_cursor(default_crsr)

func _on_door_noise_finished() -> void:
	dialoganim()
	$dialog/close.visible = true
	$dialog/label.text = "Of course it's fucking locked... I think the basement has an entrance from the outside. I can use it to leave."

# SCENE 0
func _on_firsttimer_timeout() -> void:
	$dialog.visible = true
	$dialog/label.text = "I must make sure I'm done with a room before I leave it. I must check everything."
	dialoganim()
	$label2.text = "Click the 'X' to close the dialogue."

# OBJECT INTERACTIONS

# PAINTING
func _on_painting_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		$dialog.visible = true
		detail_selected = true
		$dialog/label.text = "A medium, worn painting titled 'Hills and mountains'."
		dialoganim()

# LIGHT SWITCH
func _on_switch_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if !Singleton.hallnightmare || !Singleton.bedroomnightmaresaw:
			if $backgroundDark.visible:
				$backgroundDark.visible = false
				$backgroundLight.visible = true
				$inspect/middle/switchArea/switchOn.play()
				Singleton.lights_on = true
			else:
				$backgroundDark.visible = true
				$backgroundLight.visible = false
				$inspect/middle/switchArea/switchOff.play()
				Singleton.lights_on = false
		else:
			$dialog.visible = true
			detail_selected = true
			$dialog/label.text = "It's not working."
			dialoganim()

# INCENSE
func _on_incense_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		print("you clicked me")
		$dialog.visible = true
		detail_selected = true
		$dialog/label.text = "It's old incense. Its ashes are spread across a piece of tissue."
		dialoganim()

# COFFEE MUG
func _on_mug_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		$dialog.visible = true
		detail_selected = true
		dialoganim()
		if !Singleton.kitchennightmaresaw:
			$dialog/label.text = "An old, slightly cracked coffee mug. The liquid has completely evaporated, though some powder still lies at the bottom. A cockroach seems to have stolen some. It looks content."
		else:
			$dialog/label.text = "An old, slightly cracked coffee mug. The liquid has completely evaporated, though some powder still lies at the bottom."

# ASHTRAY
func _on_ashtray_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		$dialog.visible = true
		detail_selected = true
		$dialog/label.text = "An ashtray filled with pieces of cigarettes. Hopefully the clinic will help him recover from the vice, along with the rest."
		dialoganim()

# MOLD
func _on_mold_areas_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		$dialog.visible = true
		detail_selected = true
		$dialog/label.text = "It's mold. From the way it's growing, one day it might eat the walls."
		dialoganim()

# BOOKSHELF
#BOOKS 1
func _on_books_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if $backgroundDark.visible:
			$dialog.visible = true
			detail_selected = true
			$dialog/label.text = "Books populate the shelves. I can't read their titles. I should turn on the lights."
			dialoganim()
		else:
			$dialog.visible = true
			detail_selected = true
			$dialog/label.text = "Books populate the shelves. None of them appear to have been touched in a while. Let's see... Pseudoscience, self-help guide, philosophy, pseudoscience... Conspiracy theories... Hm."
			dialoganim()
#BOOKS 2
func _on_books_area_2_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if $backgroundDark.visible:
			$dialog.visible = true
			detail_selected = true
			$dialog/label.text = "Books populate the shelves. I can't read their titles. I should turn on the lights."
			dialoganim()
		else:
			$dialog.visible = true
			detail_selected = true
			$dialog/label.text = "Books populate the shelves. None of them appear to have been touched in a while. These are all biographies, but none of the names ring a bell. Some have subtitles: 'the greatest alchemist of history', 'the man who uncovered Earth's secrets'... Interesting."
			dialoganim()
#BOOKS 3
func _on_books_area_3_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if $backgroundDark.visible:
			$dialog.visible = true
			detail_selected = true
			$dialog/label.text = "Books populate the shelves. I can't read their titles. I should turn on the lights."
			dialoganim()
		else:
			$dialog.visible = true
			detail_selected = true
			$dialog/label.text = "Books populate the shelves. None of them appear to have been touched in a while. They appear to be about herbology, traditional medicine, and spirituality. Oh, there's one about psychology......... Which sems a little questionable. I've never heard of this author before."
			dialoganim()
#BOOKS 4
func _on_books_area_4_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if $backgroundDark.visible:
			$dialog.visible = true
			detail_selected = true
			$dialog/label.text = "Books populate the shelves. I can't read their titles. I should turn on the lights."
			dialoganim()
		else:
			$dialog.visible = true
			detail_selected = true
			$dialog/label.text = "Books populate the shelves. None of them appear to have been touched in a while. These are just normal history and anthropology books. It does look like this shelf was emptied; he must have taken some of the books with him to the clinic when the team came here."
			dialoganim()

# PICTURE
func _on_picture_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		$dialog.visible = true
		detail_selected = true
		$dialog/label.text = "It's Reid beside a lady I haven't seen. He did tell me he had a wife. They're smiling, but it doesn't reach their eyes."
		dialoganim()

#TISSUE
func _on_tissue_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if $backgroundDark.visible:
			$dialog.visible = true
			detail_selected = true
			$dialog/label.text = "A piece of tissue, stained by ashes."
			dialoganim()
		else:
			$dialog.visible = true
			detail_selected = true
			$dialog/label.text = "A piece of tissue, stained by ashes. Looking closely, there appears to be blood as well, likely from coughing."
			dialoganim()

#DRAWER
func _on_drawer_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if $backgroundDark.visible:
			$dialog.visible = true
			detail_selected = true
			$dialog/label.text = "A drawer with what appears to be notebooks. I can't see very well. I should turn on the lights."
			dialoganim()
		else:
			$dialog.visible = true
			detail_selected = true
			$dialog/label.text = "A drawer with used notebooks. One of them is filled with food recipes, while the others appear to be random, filled with quick annotations. They are all old; it seems he probably just stored them here with no intent to use them."
			dialoganim()

#SPIDER WEBS
func _on_web_areas_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		$dialog.visible = true
		detail_selected = true
		$dialog/label.text = "It's a spiderweb. It appears to be abandoned, as its silk is covered in dust."
		dialoganim()

#PHOTO ALBUM
func _on_album_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		$dialog.visible = true
		detail_selected = true
		$dialog/label.text = "This heavy book appears to be a photo album, but it is mostly empty. The few pictures depict the landscape, and were likely taken not far from here. They're dated back a few months ago. He must have started to do photography."
		dialoganim()

#COCKROACHES
#ROACH 1
func _on_roach_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		$dialog.visible = true
		detail_selected = true
		dialoganim()
		if !Singleton.kitchennightmaresaw:
			$dialog/label.text = "It waves its antennas at me."
		else:
			$dialog/label.text = "..."
# ROACH 2
func _on_roach_area_2_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		$dialog.visible = true
		detail_selected = true
		dialoganim()
		if !Singleton.kitchennightmaresaw:
			$dialog/label.text = "Roaches have been taking over the place ever since he left, though they were already here prior to that."
		else:
			$dialog/label.text = "..."

#OUTLET
func _on_outlet_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		$dialog.visible = true
		detail_selected = true
		$dialog/label.text = "The holes are slightly burnt. I'm surprised the lights even work. It looks like a sad face."
		dialoganim()

#CARPET
func _on_carpet_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if $backgroundDark.visible:
			$dialog.visible = true
			detail_selected = true
			$dialog/label.text = "The carpet is very ragged and flawed."
			dialoganim()
		else:
			$dialog.visible = true
			detail_selected = true
			$dialog/label.text = "The carpet is very ragged and flawed. There are some footprints; he must have forgotten to clean his shoes before going in... Several times, at that."
			dialoganim()




# GO TO THE SIDES

#GO LEFT
func _on_left_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		#FROM MIDDLE TO LEFT
		if $backgroundLight.visible || $backgroundDark.visible || $backgroundNghtmr.visible:
			if !Singleton.bedroomnightmaresaw || !Singleton.hallnightmare:
				if Singleton.lights_on:
					$backgroundLight.visible = false
					$inspect/middle.visible = false
					$backgroundLeftLight.visible = true
				else: 
					$backgroundDark.visible = false
					$inspect/middle.visible = false
					$backgroundLeftDark.visible = true			
				$inspect/left_side.visible = true
			else:
				$backgroundNghtmr.visible = false
				$backgroundLeftNghtmr.visible = true
				$dialog.visible = true
				dialoganim()
				detail_selected = true
				$dialog/label.text = "Fucking hell."
				
			$move/left.visible = false
			$move/toKitchen.visible = false
			$move/toHall.visible = false
		
		#FROM RIGHT TO MIDDLE
		if $backgroundRightLight.visible || $backgroundRightDark.visible || $backgroundRightLight2.visible || $backgroundRightDark2.visible || $backgroundRightNghtmr.visible:
			if !Singleton.bedroomnightmaresaw || !Singleton.hallnightmare:
				if !Singleton.stylet_used:
					if Singleton.lights_on:
						$backgroundLight.visible = true
						$inspect/middle.visible = true
						$backgroundRightLight.visible = false
						if !Singleton.stylet_picked:
							$stylet/sprite_worldL.visible = false
							$stylet/styletArea.visible = false
					else:
						$backgroundDark.visible = true
						$inspect/middle.visible = true
						$backgroundRightDark.visible = false
						if !Singleton.stylet_picked:
							$stylet/sprite_worldD.visible = false
							$stylet/styletArea.visible = false
				else:
					if Singleton.lights_on:
						$backgroundLight.visible = true
						$inspect/middle.visible = true
						$backgroundRightLight2.visible = false
					else:
						$backgroundDark.visible = true
						$inspect/middle.visible = true
						$backgroundRightDark2.visible = false
				$inspect/right_side.visible = false
			else:
				$backgroundRightNghtmr.visible = false
				$backgroundNghtmr.visible = true
			$move/right.visible = true
			$move/toKitchen.visible = true
			$move/toHall.visible = true
			$move/toBathroom.visible = false
			$move/toBasement.visible = false

#GO RIGHT
func _on_right_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		# FROM MIDDLE TO RIGHT
		if $backgroundLight.visible || $backgroundDark.visible || $backgroundNghtmr.visible:
			if !Singleton.bedroomnightmaresaw || !Singleton.hallnightmare:
				if !Singleton.stylet_used:
					if Singleton.lights_on:
						$backgroundLight.visible = false
						$inspect/middle.visible = false
						$backgroundRightLight.visible = true
						if !Singleton.stylet_picked || !slot1_filled:
							$stylet/sprite_worldL.visible = true
							$stylet/styletArea.visible = true
					else:
						$backgroundDark.visible = false
						$inspect/middle.visible = false
						$backgroundRightDark.visible = true
						if !Singleton.stylet_picked || !slot1_filled:
							$stylet/sprite_worldD.visible = true
							$stylet/styletArea.visible = true
				else: 
					if Singleton.lights_on:
						$backgroundLight.visible = false
						$inspect/middle.visible = false
						$backgroundRightLight2.visible = true
					else:
						$backgroundDark.visible = false
						$inspect/middle.visible = false
						$backgroundRightDark2.visible = true
				$inspect/right_side.visible = true
			else:
				$backgroundNghtmr.visible = false
				$backgroundRightNghtmr.visible = true
			$move/right.visible = false
			$move/toKitchen.visible = false
			$move/toHall.visible = false
			$move/toBathroom.visible = true
			$move/toBasement.visible = true
		
		# FROM LEFT TO MIDDLE
		if $backgroundLeftLight.visible || $backgroundLeftDark.visible || $backgroundLeftNghtmr.visible:
			if !Singleton.bedroomnightmaresaw || !Singleton.hallnightmare:
				if Singleton.lights_on:
					$backgroundLight.visible = true
					$inspect/middle.visible = true
					$backgroundLeftLight.visible = false
				else:
					$backgroundDark.visible = true
					$inspect/middle.visible = true
					$backgroundLeftDark.visible = false
				$inspect/left_side.visible = false
			else:
				$backgroundLeftNghtmr.visible = false
				$backgroundNghtmr.visible = true
			$move/left.visible = true
			$move/toKitchen.visible = true
			$move/toHall.visible = true



#  GO TO OTHER ROOMS

# TO KITCHEN
func _on_to_kitchen_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if !Singleton.kitchennightmaresaw:
			get_tree().change_scene_to_file(target_level1)
		else:
			$dialog.visible = true
			detail_selected = true
			$dialog/label.text = "Nope. Nope nope nope. Not going back in there. Ugh."
			dialoganim()

# TO HALL
func _on_to_hall_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if !Singleton.hallnightmare:
			get_tree().change_scene_to_file(target_level2)
		else:
			$dialog.visible = true
			detail_selected = true
			$dialog/label.text = "I need to leave."
			dialoganim()




# LEFT SIDE

#OBJECTS

#TV
func _on_tv_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		$dialog.visible = true
		detail_selected = true
		$dialog/label.text = "An old, dusty TV. Its screen is very cracked, and the buttons don't work."
		dialoganim()

#TV DRAWERS
func _on_tvdrawers_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if !Singleton.lights_on:
			$dialog.visible = true
			detail_selected = true
			$dialog/label.text = "The drawer is filled with cables and old hardware. It seems he stored those here."
			dialoganim()
		else:
			$dialog.visible = true
			detail_selected = true
			$dialog/label.text = "The drawer is filled with cables and old hardware. It seems he stored those here... There are also some movie discs, let's see. A lot of war movies, historical documentaries, and... Uh... Nope. I won't judge my patient's tastes. Especially not for... Certain types of media."
			dialoganim()

#CIRCULAR CARPET
func _on_circlecarpet_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if !Singleton.lights_on:
			$dialog.visible = true
			detail_selected = true
			$dialog/label.text = "The carpet is very ragged and flawed."
			dialoganim()
		else:
			$dialog.visible = true
			detail_selected = true
			$dialog/label.text = "The carpet is very ragged and flawed. There are some footprints and... That's gross. I don't even know what that is."
			dialoganim()

#COUCH
func _on_couch_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		$dialog.visible = true
		detail_selected = true
		$dialog/label.text = "An old couch. It is ragged and has a lot of holes and torn parts. There's stuffing coming out of some places."
		dialoganim()

#COUCH COCKROACH
func _on_couchroach_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		$dialog.visible = true
		detail_selected = true
		dialoganim()
		if !Singleton.kitchennightmaresaw:
			$dialog/label.text = "It's sitting rather comfortably on the couch."
		else:
			$dialog/label.text = "..."

#WALL COCKROACH
func _on_wallroach_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		$dialog.visible = true
		detail_selected = true
		dialoganim()
		if !Singleton.kitchennightmaresaw:
			$dialog/label.text = "Thank God I didn't bring my wife with me. She would be freaking out with just how many roaches are in this place. They also give me goosebumps."
		else:
			$dialog/label.text = "..."

#SPIDERWEBS
func _on_webs_areas_2_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		$dialog.visible = true
		detail_selected = true
		$dialog/label.text = "It's a spiderweb. It appears to be abandoned, as its silk is covered in dust."
		dialoganim()

#BIG MOLD
func _on_bigmold_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		$dialog.visible = true
		detail_selected = true
		$dialog/label.text = "The mold has grown and become particularly advanced in this part of the wall."
		dialoganim()

#RAT POOP
func _on_poop_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		$dialog.visible = true
		detail_selected = true
		$dialog/label.text = "...Now, that's disgusting."
		dialoganim()

#LARGE DRAWER
func _on_bigdrawer_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		$dialog.visible = true
		detail_selected = true
		$dialog/label.text = "Both drawers are filled with notebooks, with annotations I don't understand. The dates seem very precise; Reid did appear to be a rather punctual man. There are also blank papers and writing material. He must have written letters here. There are also all kinds of documents, mostly medical."
		dialoganim()

#LETTER
func _on_letter_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		$letter1timer.start()
		$dialog.visible = true
		detail_selected = true
		$dialog/label.text = "It's a letter Reid wrote. I wonder why he didn't send it."
		dialoganim()
		$dialog/close.visible = false

func _on_letter_1_timer_timeout() -> void:
	$letter1.visible = true
	$dialog.visible = false
	detail_selected = true
	$dialog/close.visible = true

func _on_clspclose_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		$letter1.visible = false
		detail_selected = false
		changecrsr_def()
		Singleton.read_letter = true

#PENCIL
func _on_pencil_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		$dialog.visible = true
		detail_selected = true
		$dialog/label.text = "A pencil inside a cup. It's filled with marks from chewing. Looks like someone was feeling uneasy..."
		dialoganim()

#WINDOW
func _on_window_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		$dialog.visible = true
		detail_selected = true
		$dialog/label.text = "The forest surrounds the house. I can't stare out into the darkness for very long."
		dialoganim()

#LITTLE ROACH
func _on_roachy_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		$dialog.visible = true
		detail_selected = true
		dialoganim()
		if !Singleton.kitchennightmaresaw:
			$dialog/label.text = "It's hiding and thinks it can't be seen."
		else:
			$dialog/label.text = "..."





# RIGHT SIDE

#BOX
func _on_box_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if !Singleton.stylet_used:
			$dialog.visible = true
			$dialog/label.text = "A cardboard box. Reid was about to open it when the team came in, I believe."
			dialoganim()
		else:
			$dialog.visible = true
			$dialog/label.text = "There's nothing interesting in here anymore."
			dialoganim()

func _on_box_area_area_entered(area: Area2D) -> void:
	if !detail_selected and area.is_in_group("item"):
		if area.get_parent().item_id == 1:
			Singleton.stylet_used = true
			empty_slot(area.get_parent().drop_location_id)
			area.get_parent().queue_free()
			Input.set_custom_mouse_cursor(default_crsr)
			$dialog.visible = true
			$dialog/label.text = "I used the stylet to open the box. It is filled with books about what appears to be witchcraft. They look like expensive volumes. There is also a letter."
			dialoganim()
			$dialog/close.visible = false
			$inspect/right_side/boxArea/boxSound.play()
			$bookstimer.start()
			detail_selected = true
			if !Singleton.lights_on:
				$backgroundRightDark.visible = false
				$backgroundRightDark2.visible = true
			else:
				$backgroundRightLight.visible = false
				$backgroundRightLight2.visible = true

func _on_bookstimer_timeout() -> void:
	$dialog.visible = false
	detail_selected = true
	$closeupbooks.visible = true
	$letter2timer.start()

func _on_letter_2_timer_timeout() -> void:
	$closeupbooks.visible = false
	$letter2.visible = true
	$dialog/close.visible = true

func _on_clspclose_2_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		$letter2.visible = false
		detail_selected = false
		changecrsr_def()

#STYLET DIALOG POPUP
func _on_stylet_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and !Singleton.stylet_picked and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		$dialog.visible = true
		$dialog/label.text = "I found a stylet."
		dialoganim()
		$stylet/shuim.play()
		detail_selected = true

#MEDIUM MOLD
func _on_medmold_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		$dialog.visible = true
		detail_selected = true
		$dialog/label.text = "The mold appears to be thriving within the house's walls."
		dialoganim()

#WALL
func _on_wall_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if !Singleton.lights_on:
			$dialog.visible = true
			detail_selected = true
			$dialog/label.text = "The wall has some strange markings I can't see clearly in this darkness."
			dialoganim()
		else:
			$dialog.visible = true
			detail_selected = true
			$dialog/label.text = "The markings in the wall indicate that it used to have paintings hanging from it, but they were removed."
			dialoganim()

#WINDOW
func _on_window_area_2_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		$dialog.visible = true
		detail_selected = true
		$dialog/label.text = "It's weird how the house appears to be towering over the forest despite how average the hill's height is..."
		dialoganim()

#PAINTINGS
func _on_paintings_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		$dialog.visible = true
		detail_selected = true
		$dialog/label.text = "A nice painting of a pine forest titled 'Evergreen'."
		dialoganim()

#SPIDER WEB
func _on_web_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		$dialog.visible = true
		detail_selected = true
		$dialog/label.text = "I can see a tiny spider standing close to the wall. It's not moving."
		dialoganim()

#ROACHES
func _on_roaches_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		$dialog.visible = true
		detail_selected = true
		dialoganim()
		if !Singleton.kitchennightmaresaw:
			$dialog/label.text = "They appear to be having some kind of conversation."
		else:
			$dialog/label.text = "..."

#DEAD ROACH
func _on_deadroach_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		$dialog.visible = true
		detail_selected = true
		dialoganim()
		if !Singleton.kitchennightmaresaw:
			$dialog/label.text = "It's in an advanced stage of decomposition."
		else:
			$dialog/label.text = "..."

#WALL ROACH
func _on_wallroach_area_2_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		$dialog.visible = true
		detail_selected = true
		dialoganim()
		if !Singleton.kitchennightmaresaw:
			$dialog/label.text = "It seems unbothered by the corpse next to it."
		else:
			$dialog/label.text = "..."

#WINDOW ROACH
func _on_windowroach_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		$dialog.visible = true
		detail_selected = true
		dialoganim()
		if !Singleton.kitchennightmaresaw:
			$dialog/label.text = "It doesn't appear to be interested in enjoying the view from the window."
		else:
			$dialog/label.text = "..."

#STAIRCASE
func _on_stairs_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		$dialog.visible = true
		detail_selected = true
		$dialog/label.text = "The stairs descend into a complete abyss. I don't want to stare at it for too long."
		dialoganim()


# TO OTHER ROOMS (RIGHT)

#TO BATHROOM
func _on_to_bathroom_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if !Singleton.bathroomnightmaresaw:
			get_tree().change_scene_to_file(target_level3)
		else:
			$dialog.visible = true
			detail_selected = true
			$dialog/label.text = "I can hear the things moving..."
			dialoganim()

#TO BASEMENT
func _on_to_basement_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !detail_selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if !Singleton.bedroomnightmaresaw || !Singleton.hallnightmare:
			$dialog.visible = true
			detail_selected = true
			$dialog/label.text = "I don't want to go down there yet."
			dialoganim()
		else:
			$fadeout.visible = true
			$fadeout/AnimationPlayer.play("fadeout")
			$stairsnoiseRun.play()
			Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

func _on_stairsnoise_run_finished() -> void:
	get_tree().change_scene_to_file(target_level4)
