extends Node

var stage := 0
# 0 - beginning
# 1 - have to mine anemones
# 2 - have mined
# 3 - find the other fish
# 4 - fish found
# 5 - finished

func enter_the_fish_zone():
	match(stage):
		0:
			Dialog.trigger("fish_quest_intro")
			stage = 1
		2:
			Dialog.trigger("fish_quest_find_nemo")
			stage = 3
		4:
			Dialog.trigger("fish_quest_finished")
			Game.level.delete_no_drill()
			stage = 5

func forbidden_drill():
	Dialog.trigger("forbidden_drill")


var max_anemones := 3
var current_anemones := 0
func mined_anemone():
	Dialog.trigger("quest_anemone")
	current_anemones += 1
	if current_anemones >= max_anemones and stage == 1:
		Dialog.trigger("we_mined_the_anemones")
		stage = 2
