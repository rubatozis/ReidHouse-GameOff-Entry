extends Node2D
var visible_characters = 0

func _ready() -> void:
	TimeWhistle.volume_db = 10
	if Arvostus.playing:
		Arvostus.stop()
	if !TimeWhistle.playing:
		TimeWhistle.play()
	$runSound.play()
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

func animplay():
	$label/AnimationPlayer.play("typewriter")

func _process(delta: float) -> void:
	if visible_characters != $label.visible_characters:
		visible_characters = $label.visible_characters
		$typenoise.play()

func _on_initial_timeout() -> void:
	$label.visible = true
	animplay()
	$ambience.play()
	$one.start()
	TimeWhistle.volume_db = 8

func _on_one_timeout() -> void:
	$label.text = "The cold air of the hill seemed unreal compared to the warmth of the house."
	animplay()
	TimeWhistle.volume_db = 6
	$two.start()

func _on_two_timeout() -> void:
	$label.text = "He didn't know if the heartbeat in his ears was his own or the house's, didn't know if the wind was just that, or the house's breathing."
	animplay()
	TimeWhistle.volume_db = 4
	$three.start()

func _on_three_timeout() -> void:
	$label.text = "He only looked back once; the Thing inside the house was nowhere to be seen, but it watched him. He knew."
	animplay()
	TimeWhistle.volume_db = 2
	$four.start()

func _on_four_timeout() -> void:
	$label.text = "He reached his car, got in, and drove away. The house watched him leave from up in the hill."
	animplay()
	$runSound.stop()
	$cardoor1.play()
	TimeWhistle.volume_db = 0
	$five.start()

func _on_cardoor_1_finished() -> void:
	$cardoor2.play()
	$ambience.stop()

func _on_five_timeout() -> void:
	$label.visible = false
	$longBreak.start()
	TimeWhistle.stop()


func _on_long_break_timeout() -> void:
	$label.visible = true
	$label.text = "Few were the people Gardner told of his experiences within the house. Most people, sensibly so, suggested black mold as the culprit for what were clearly hallucinations."
	animplay()
	$six.start()

func _on_six_timeout() -> void:
	$label.text = "Francis Reid, of course, was not one of those people. He knew. He knew it all."
	animplay()
	$seven.start()

func _on_seven_timeout() -> void:
	$label.visible = false
	$breakOne.start()

func _on_break_one_timeout() -> void:
	$label.visible = true
	$label.text = "Over the years, the man made significant progress with his therapy. Gardner did not give up on him, despite it all."
	animplay()
	$eight.start()

func _on_eight_timeout() -> void:
	$label.visible = false
	$breakTwo.start()

func _on_break_two_timeout() -> void:
	$label.visible = true
	$label.text = "Reid returned his wife's belongings to her family, and seemed to be coping well with his grief."
	animplay()
	$nine.start()

func _on_nine_timeout() -> void:
	$label.text = "Still, he didn't want to return home, and was denied his wish for the house to be demolished. He moved out."
	animplay()
	$ten.start()

func _on_ten_timeout() -> void:
	$label.text = "But the house remains there, sitting up in that hill, watching whoever passes by. It waits, and it will wait forever."
	animplay()
	$eleven.start()
	
func _on_eleven_timeout() -> void:
	$lastBreak.start()
	$label.visible = false

func _on_last_break_timeout() -> void:
	$Quiet.play()
	$Label.visible = true
	$Label2.visible = true
	$twelve.start()

func _on_twelve_timeout() -> void:
	$Label2.text = "An entry for Github Game Off 2024"
	$thirteen.start()

func _on_thirteen_timeout() -> void:
	$Label.text = "Art"
	$Label2.text = "Rubatozis, Camusvast"
	$fourteen.start()

func _on_fourteen_timeout() -> void:
	$Label.text = "Story"
	$Label2.text = "Rubatozis"
	$fifteen.start()

func _on_fifteen_timeout() -> void:
	$Label.text = "Music"
	$Label2.text = "Crow Shade, Jeremy Blake"
	$sixteen.start()

func _on_sixteen_timeout() -> void:
	$Label.text = "Sounds"
	$Label2.text = "FilmCow, ADsounds, many people from Freesound.org"
	$seventeen.start()

func _on_seventeen_timeout() -> void:
	$Label.text = "Thank you for playing! <3"
	$Label2.visible = false
