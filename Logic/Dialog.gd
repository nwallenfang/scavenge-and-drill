extends Node

func _ready():
	create_all_dialogs()

enum SPEAKERS {DRILL, ROLLER, MERCHANT, FISH, FISH_BUDDY, HOOK}

var names = {
	SPEAKERS.DRILL: "Robot",
	SPEAKERS.ROLLER: "Human",
	SPEAKERS.MERCHANT: "Merchant",
	SPEAKERS.FISH: "Fish",
	SPEAKERS.FISH_BUDDY: "Fish",
	SPEAKERS.HOOK: "Hook",
}

var colors = {
	SPEAKERS.DRILL: Color.steelblue,
	SPEAKERS.ROLLER: Color.orange,
	SPEAKERS.MERCHANT: Color.coral,
	SPEAKERS.FISH: Color.white,
	SPEAKERS.FISH_BUDDY: Color.white,
	SPEAKERS.HOOK: Color.gray,
}

var icons = {
	SPEAKERS.DRILL: preload("res://Assets/Sprites/characters/drill_transparent.png"),
	SPEAKERS.ROLLER: preload("res://Assets/Sprites/characters/roller_transparent.png"),
	SPEAKERS.MERCHANT: preload("res://Assets/Sprites/characters/human_PLACEHOLDER.png"),
	SPEAKERS.FISH: preload("res://Assets/Sprites/characters/fish.png"),
	SPEAKERS.FISH_BUDDY: preload("res://Assets/Sprites/characters/fish_buddy.png"),
	SPEAKERS.HOOK: preload("res://Assets/Sprites/characters/hook.png"),
}

class DialogLine:
	var speaker_id: int
	var text: String
	var duration: float
	
	func _init(sid, t, d := 3.0):
		speaker_id = sid
		text = t
		duration = d * 1.15
	
	func to_dict() -> Dictionary:
		return {
			"speaker_id": speaker_id, "text": text, "duration": duration
		}

class DialogSequence:
	var lines := []
	var played := false
	
	func _init(l):
		lines = l
		
	func to_basic_data() -> Array:  # array of dictionaries for rpc calls
		var ret = []
		for line in lines:
			ret.append(line.to_dict())
		return ret

enum SELECTION_MODES {ORDER, RANDOM}
enum TRIGGER_MODES {
	ONCE,
	COUNT_EXACT,
	COUNT_GREATER_EQ,  
	VALUE_EXACT,
	VALUE_GREATER_EQ,
	CHANCE
}

class DialogTrigger:
	var trigger_key: String
	var selection_mode : int = SELECTION_MODES.ORDER
	var trigger_mode : int = TRIGGER_MODES.ONCE
	var condition_value
	var importance: int = 1
	var queue := false
	var always := false
	var trigger_count := 0
	var max_triggers := 0
	var can_trigger := true
	var sequences := []
	
	func _init(t):
		trigger_key = t
	
	func is_all_played():
		for s in sequences:
			if not s.played:
				return false
		return true

var currently_dialoging := false
var current_dialog_trigger : DialogTrigger
var current_dialog_sequence : DialogSequence
var trigger_counts := {}

var all_dialogs := []
var dialog_queue := []

class ImportanceSorter:
	static func sort(a, b):
		if a.importance > b.importance:
			return true
		return false


func trigger(trigger_key: String, value = null):
	if trigger_key in trigger_counts:
		trigger_counts[trigger_key] = trigger_counts[trigger_key] + 1
	else:
		trigger_counts[trigger_key] = 1
	
	var found_dialogs := []
	for dialog_trigger in all_dialogs:
		dialog_trigger = dialog_trigger as DialogTrigger
#		dialog_trigger.index = index
		if dialog_trigger.trigger_key == trigger_key and dialog_trigger.can_trigger:
			match(dialog_trigger.trigger_mode):
				TRIGGER_MODES.ONCE:
					found_dialogs.append(dialog_trigger)
				TRIGGER_MODES.COUNT_EXACT:
					if trigger_counts[trigger_key] == dialog_trigger.condition_value:
						found_dialogs.append(dialog_trigger)
				TRIGGER_MODES.COUNT_GREATER_EQ:
					if trigger_counts[trigger_key] >= dialog_trigger.condition_value:
						found_dialogs.append(dialog_trigger)
				TRIGGER_MODES.VALUE_EXACT:
					if value != null:
						if value == dialog_trigger.condition_value:
							found_dialogs.append(dialog_trigger)
				TRIGGER_MODES.VALUE_GREATER_EQ:
					if value != null:
						if value >= dialog_trigger.condition_value:
							found_dialogs.append(dialog_trigger)
				TRIGGER_MODES.CHANCE:
					if randf() <= dialog_trigger.condition_value:
						found_dialogs.append(dialog_trigger)
	
	if not found_dialogs.empty():
		found_dialogs.sort_custom(ImportanceSorter, "sort")
		var best_match := current_dialog_trigger
		var best_match_index := 0
		for dialog_trigger in found_dialogs:
			if best_match == null:
				best_match = dialog_trigger
			elif dialog_trigger.importance > best_match.importance:
				best_match = dialog_trigger
			elif dialog_trigger.queue:
				for i in range(len(dialog_queue)):
					if dialog_queue[i].importance < dialog_trigger.importance:
						dialog_queue.insert(i, dialog_trigger)
					elif i == len(dialog_queue) - 1:
						dialog_queue.append(dialog_trigger)
		
		if best_match != current_dialog_trigger:
			execute_dialog(best_match)
	else:
		Game.log("unknown dialog trigger: " + trigger_key)

signal dialog_started

func execute_dialog(dialog_trigger: DialogTrigger):
	var seq = null
	if dialog_trigger.selection_mode == SELECTION_MODES.ORDER:
		if dialog_trigger.always:
			seq = dialog_trigger.sequences[dialog_trigger.trigger_count % len(dialog_trigger.sequences)]
		else:
			for s in dialog_trigger.sequences:
				s = s as DialogSequence
				if not s.played:
					seq = s
					break
	elif dialog_trigger.selection_mode == SELECTION_MODES.RANDOM:
		for i in range(50):
			dialog_trigger.sequences.shuffle()
			var s = dialog_trigger.sequences[0] as DialogTrigger
			if (not s.played) or dialog_trigger.always:
				seq = s
				break
	if seq != null:
		currently_dialoging = true
		current_dialog_trigger = dialog_trigger
		current_dialog_sequence = seq
		current_dialog_sequence.played = true
		dialog_trigger.trigger_count += 1
		if dialog_trigger.max_triggers != 0:
			if dialog_trigger.trigger_count >= dialog_trigger.max_triggers:
				dialog_trigger.can_trigger = false
		if not dialog_trigger.always and dialog_trigger.is_all_played():
			dialog_trigger.can_trigger = false
		emit_signal("dialog_started")

var queue_cooldown_time := 4.0
signal dialog_ended
func on_dialog_ended():
	emit_signal("dialog_ended")
	currently_dialoging = false
	current_dialog_trigger = null
	yield(get_tree().create_timer(queue_cooldown_time),"timeout")
	if not currently_dialoging:
		if not dialog_queue.empty():
			execute_dialog(dialog_queue.pop_front())
			
			
func add_dialog():
	# TODO connect to signal automatically
	pass

func create_all_dialogs():
	var d
	
	
	d = DialogTrigger.new("power_low")
	d.sequences.append(DialogSequence.new([
		DialogLine.new(SPEAKERS.ROLLER, "We'll go home once our power is out.."),
		DialogLine.new(SPEAKERS.DRILL, "So soon.. but at least going home means shopping time!"),
		DialogLine.new(SPEAKERS.ROLLER, "Right! Let's find some treasures then."),
	]))
	d.sequences.append(DialogSequence.new([
		DialogLine.new(SPEAKERS.DRILL, "The power levels are halfway down again..."),
		DialogLine.new(SPEAKERS.ROLLER, "Too bad we can't charge the battery down here"),
	]))
	all_dialogs.append(d)

	d = DialogTrigger.new("treasure_drill")
	d.trigger_mode = TRIGGER_MODES.COUNT_EXACT
	d.condition_value = 6
	d.sequences.append(DialogSequence.new([
		DialogLine.new(SPEAKERS.ROLLER, "Can't you hurry up with your drilling? You're taking your time."),
		DialogLine.new(SPEAKERS.DRILL, "Hey, these treasures have to be drilled with utmost care!"),
	]))
	all_dialogs.append(d)
	
	d = DialogTrigger.new("getting_hit")
	d.trigger_mode = TRIGGER_MODES.COUNT_GREATER_EQ
	d.condition_value = 4
	d.sequences.append(DialogSequence.new([
		DialogLine.new(SPEAKERS.ROLLER, "Those eels always steal our power."),
		DialogLine.new(SPEAKERS.DRILL, "I hope your battery doesn't get damaged."),
	]))
	all_dialogs.append(d)
	
	d = DialogTrigger.new("treasure_found")
	d.trigger_mode = TRIGGER_MODES.COUNT_EXACT
	d.condition_value = 5
	d.sequences.append(DialogSequence.new([
		DialogLine.new(SPEAKERS.DRILL, "This is our fifth treasure finding!"),
		DialogLine.new(SPEAKERS.DRILL, "Yeee!"),
	]))
	all_dialogs.append(d)
	
#	d = DialogTrigger.new("gold_earned")
#	d.trigger_mode = TRIGGER_MODES.VALUE_GREATER_EQ
#	d.condition_value = 100
#	d.sequences.append(DialogSequence.new([
#		DialogLine.new(SPEAKERS.ROLLER, "Amazing, now we can afford the Bomb!"),
#		DialogLine.new(SPEAKERS.DRILL, "I would love to use it."),
#	]))
#	all_dialogs.append(d)
	
	
#	d = DialogTrigger.new("see_a_fish")
#	d.trigger_mode = TRIGGER_MODES.CHANCE
#	d.condition_value = .5
#	d.selection_mode = SELECTION_MODES.RANDOM
#	d.sequences.append(DialogSequence.new([
#		DialogLine.new(SPEAKERS.ROLLER, "There is a fish!"),
#	]))
#	d.sequences.append(DialogSequence.new([
#		DialogLine.new(SPEAKERS.DRILL, "Another fish over there."),
#	]))
#	d.sequences.append(DialogSequence.new([
#		DialogLine.new(SPEAKERS.ROLLER, "I like fishes."),
#	]))
#	all_dialogs.append(d)

	d = DialogTrigger.new("eel_middle")
	d.sequences.append(DialogSequence.new([
		DialogLine.new(SPEAKERS.ROLLER, "This eel looks really icky..", 2.0),
		DialogLine.new(SPEAKERS.DRILL, "It wants to drain our power levels!"),
		DialogLine.new(SPEAKERS.ROLLER, "I'd like to shoot it.", 2.0),
	]))
	all_dialogs.append(d)
	
	d = DialogTrigger.new("close_to_eel")
	d.sequences.append(DialogSequence.new([
		DialogLine.new(SPEAKERS.ROLLER, "These eels look really icky..", 2.0),
		DialogLine.new(SPEAKERS.DRILL, "I've seen them before. They drain our power levels!"),
		DialogLine.new(SPEAKERS.ROLLER, "Sounds scary.", 1.5),
	]))
	d.sequences.append(DialogSequence.new([
		DialogLine.new(SPEAKERS.DRILL, "There has to be a way to fend the eels off!"),
		DialogLine.new(SPEAKERS.ROLLER, "You know that's what I'm built for, right?"),
		DialogLine.new(SPEAKERS.ROLLER, "I just need crystals to power my gun."),
		DialogLine.new(SPEAKERS.DRILL, "Those shiny purple ones, right.."),
	]))
	all_dialogs.append(d)

	d = DialogTrigger.new("drill_too_weak")
	d.sequences.append(DialogSequence.new([
		DialogLine.new(SPEAKERS.DRILL, "Damn!", 1.2),
		DialogLine.new(SPEAKERS.DRILL, "My Drill power is too low.", 2.4),
		DialogLine.new(SPEAKERS.ROLLER, "You're really useless without your upgrades.", 2.4),
	]))
	d.sequences.append(DialogSequence.new([
		DialogLine.new(SPEAKERS.DRILL, "Damn!", 1.2),
		DialogLine.new(SPEAKERS.DRILL, "My Drill power is too low.", 2.4),
		DialogLine.new(SPEAKERS.ROLLER, "You're really useless without your upgrades.", 2.4),
	]))
	d.sequences.append(DialogSequence.new([
		DialogLine.new(SPEAKERS.DRILL, "Damn!", 1.2),
		DialogLine.new(SPEAKERS.DRILL, "My Drill power is too low.", 2.4),
		DialogLine.new(SPEAKERS.ROLLER, "You're really useless without your upgrades.", 2.4),
	]))
	d.sequences.append(DialogSequence.new([
		DialogLine.new(SPEAKERS.DRILL, "Damn!", 1.2),
		DialogLine.new(SPEAKERS.DRILL, "My Drill power is too low.", 2.4),
		DialogLine.new(SPEAKERS.ROLLER, "You're really useless without your upgrades.", 2.4),
	]))
	d.sequences.append(DialogSequence.new([
		DialogLine.new(SPEAKERS.DRILL, "Damn!", 1.2),
		DialogLine.new(SPEAKERS.DRILL, "My Drill power is too low.", 2.4),
		DialogLine.new(SPEAKERS.ROLLER, "You're really useless without your upgrades.", 2.4),
	]))
	all_dialogs.append(d)
	
	d = DialogTrigger.new("see_wall")
	d.sequences.append(DialogSequence.new([
		DialogLine.new(SPEAKERS.DRILL, "DRILL! DRILL! DRILL!", 1.2),
		DialogLine.new(SPEAKERS.DRILL, "Drive next to that wall!", 2.4),
		DialogLine.new(SPEAKERS.DRILL, "I will drill it to dust.", 2.4),
	]))
	all_dialogs.append(d)
	
	d = DialogTrigger.new("other_side")
	d.sequences.append(DialogSequence.new([
		DialogLine.new(SPEAKERS.DRILL, "I see that shiny diamond.", 2.4),
		DialogLine.new(SPEAKERS.DRILL, "Get me over there!", 2.2),
		DialogLine.new(SPEAKERS.ROLLER, "I can't.", 1.4),
		DialogLine.new(SPEAKERS.ROLLER, "We'd both sink to the ground.", 1.4),
	]))
	all_dialogs.append(d)
	
	d = DialogTrigger.new("wall_destroyed")
	d.sequences.append(DialogSequence.new([
		DialogLine.new(SPEAKERS.DRILL, "Yes!", 1.4),
		DialogLine.new(SPEAKERS.DRILL, "I told you, I would drill that wall.", 2.0),
		DialogLine.new(SPEAKERS.DRILL, "All hail the drill!", 2.2),
		DialogLine.new(SPEAKERS.ROLLER, "-.-", 1.4),
	]))
	all_dialogs.append(d)
	
	d = DialogTrigger.new("anemone_drill")
	d.sequences.append(DialogSequence.new([
		DialogLine.new(SPEAKERS.ROLLER, "?", 1.4),
		DialogLine.new(SPEAKERS.ROLLER, "Why are you drilling that sea anemone?", 3.0),
		DialogLine.new(SPEAKERS.DRILL, "I'm a drill", 1.9),
		DialogLine.new(SPEAKERS.DRILL, "That's what I do...", 2.4),
	]))
	all_dialogs.append(d)
	
	
	d = DialogTrigger.new("we_could_teleport")
	d.sequences.append(DialogSequence.new([
		DialogLine.new(SPEAKERS.DRILL, "I see that shiny diamond.", 2.4),
		DialogLine.new(SPEAKERS.ROLLER, "We could use that teleport ability", 3.0),
	]))
	all_dialogs.append(d)
	
	d = DialogTrigger.new("anemone_drill")
	d.trigger_mode = TRIGGER_MODES.COUNT_GREATER_EQ
	d.condition_value = 4
	d.sequences.append(DialogSequence.new([
		DialogLine.new(SPEAKERS.ROLLER, "Could you stop drilling those useless anemones?"),
		DialogLine.new(SPEAKERS.DRILL, "I could but I won't."),
	]))
	all_dialogs.append(d)
	
	d = DialogTrigger.new("hook")
	d.trigger_mode = TRIGGER_MODES.COUNT_GREATER_EQ
	d.condition_value = 3
	d.sequences.append(DialogSequence.new([
		DialogLine.new(SPEAKERS.ROLLER, "Oh all mighty hook, get us out of here!"),
		DialogLine.new(SPEAKERS.HOOK, "I got you.", 2.0),
	]))
	all_dialogs.append(d)
	
	d = DialogTrigger.new("intro_sequence")
	d.sequences.append(DialogSequence.new([
		DialogLine.new(SPEAKERS.ROLLER, "Finally, the first treasure hunt on our own!", 2.5),
		DialogLine.new(SPEAKERS.DRILL, "So exciting, which treasure will I drill first?", 3.0),
		DialogLine.new(SPEAKERS.ROLLER, "The ocean is so different compared to the academy pool..", 3.4),
		DialogLine.new(SPEAKERS.DRILL, "This is what we've been training for!", 2.3),
		DialogLine.new(SPEAKERS.DRILL, "Drilling Scrap metal, rocks and gold...", 2.6),
		DialogLine.new(SPEAKERS.ROLLER, "Well... let's touch some seaweed first.", 2.5),
	]))
	d.sequences.append(DialogSequence.new([
		DialogLine.new(SPEAKERS.ROLLER, "Here we go again!", 2.5),
	]))
	all_dialogs.append(d)
	
	d = DialogTrigger.new("intro_sequence_later")
	d.sequences.append(DialogSequence.new([
		DialogLine.new(SPEAKERS.ROLLER, "Did you know, we're sold labeled as T.R.U.S.D. unit?", 2.8),
		DialogLine.new(SPEAKERS.DRILL, "I did not, what does it mean?", 2.0),
		DialogLine.new(SPEAKERS.ROLLER, "Treasure Receiving Unit: Scavenge & Drill", 3.0),
	]))
	all_dialogs.append(d)

	d = DialogTrigger.new("diamond_drilled")
	d.sequences.append(DialogSequence.new([
		DialogLine.new(SPEAKERS.ROLLER, "We finally got that shiny diamond!"),
		DialogLine.new(SPEAKERS.ROLLER, "That will get us a special reward. I'm sure."),
		DialogLine.new(SPEAKERS.ROLLER, "At least I hope...", 2.0),
		DialogLine.new(SPEAKERS.ROLLER, "Would be nice.", 1.5),
	]))
	all_dialogs.append(d)

	d = DialogTrigger.new("fish_quest_intro")
	d.sequences.append(DialogSequence.new([
		DialogLine.new(SPEAKERS.FISH, "Yo, robot!", 1.5),
		DialogLine.new(SPEAKERS.ROLLER, "Yo, fish!", 1.5),
		DialogLine.new(SPEAKERS.FISH, "Don't get your pointy thing near my crystals!", 2.9),
		DialogLine.new(SPEAKERS.FISH, "There are not many crystals around here", 2.9),
		DialogLine.new(SPEAKERS.FISH, "If you want them, you have to do me a favor:", 2.9),
		DialogLine.new(SPEAKERS.FISH, "Destroy those ugly blue anemones behind me!", 2.9),
	]))
	all_dialogs.append(d)

	d = DialogTrigger.new("fish_quest_find_nemo")
	d.sequences.append(DialogSequence.new([
		DialogLine.new(SPEAKERS.FISH, "Good job but no drilling yet!", 2.6),
		DialogLine.new(SPEAKERS.DRILL, "D:", 2.0),
		DialogLine.new(SPEAKERS.FISH, "Now I'd like you to find my friend!", 2.6),
		DialogLine.new(SPEAKERS.FISH, "We lost each other a while ago...", 2.3),
		DialogLine.new(SPEAKERS.FISH, "Tell him where I am!", 2.1),
	]))
	all_dialogs.append(d)

	d = DialogTrigger.new("fish_quest_finished")
	d.sequences.append(DialogSequence.new([
		DialogLine.new(SPEAKERS.FISH, "You did it! You found him!", 2.0),
		DialogLine.new(SPEAKERS.FISH_BUDDY, "Yes they are very nice robots.", 2.3),
		DialogLine.new(SPEAKERS.FISH, "I always thought it's just one robot.", 2.3),
		DialogLine.new(SPEAKERS.FISH_BUDDY, "Yeah, I'm not quite sure...", 2.3),
		DialogLine.new(SPEAKERS.FISH, "You can have those crystals now.", 2.3),
		DialogLine.new(SPEAKERS.DRILL, "Finally..."),
	]))
	all_dialogs.append(d)
	
	d = DialogTrigger.new("buddy_pre_quest")
	d.sequences.append(DialogSequence.new([
		DialogLine.new(SPEAKERS.FISH_BUDDY, "Hello, nice Robots!", 1.8),
		DialogLine.new(SPEAKERS.ROLLER, "Hello, Mister Fish!", 1.8),
		DialogLine.new(SPEAKERS.FISH_BUDDY, "I saw you getting fished by a hook a while ago."),
		DialogLine.new(SPEAKERS.FISH_BUDDY, "You must've been lucky to escape."),
	]))
	d.sequences.append(DialogSequence.new([
		DialogLine.new(SPEAKERS.FISH_BUDDY, "I gathered a few crystals!", 1.8),
		DialogLine.new(SPEAKERS.FISH_BUDDY, "You can mine them if you want to."),
	]))
	all_dialogs.append(d)
	
	d = DialogTrigger.new("buddy_quest")
	d.sequences.append(DialogSequence.new([
		DialogLine.new(SPEAKERS.DRILL, "Hey, we know where your friend is.", 2.3),
		DialogLine.new(SPEAKERS.FISH_BUDDY, "That's great. I lost him days ago.", 2.0),
		DialogLine.new(SPEAKERS.FISH_BUDDY, "I bet he's in the deep sea.", 1.7),
		DialogLine.new(SPEAKERS.DRILL, "That's right.", 1.2),
		DialogLine.new(SPEAKERS.DRILL, "Why did we even come here, if you know it already?"),
		DialogLine.new(SPEAKERS.FISH_BUDDY, "Thank you very much!"),
	]))
	all_dialogs.append(d)
	
	
	d = DialogTrigger.new("quest_anemone")
	d.sequences.append(DialogSequence.new([
		DialogLine.new(SPEAKERS.ROLLER, "We got one of his anemones."),
	]))
	all_dialogs.append(d)
	
	d = DialogTrigger.new("we_mined_the_anemones")
	d.sequences.append(DialogSequence.new([
		DialogLine.new(SPEAKERS.DRILL, "That should be all!"),
		DialogLine.new(SPEAKERS.DRILL, "Now imma drill his crystals!"),
	]))
	all_dialogs.append(d)
	
	d = DialogTrigger.new("forbidden_drill")
	d.importance = 0
	d.sequences.append(DialogSequence.new([
		DialogLine.new(SPEAKERS.FISH, "Hey stop it!"),
	]))
	d.sequences.append(DialogSequence.new([
		DialogLine.new(SPEAKERS.FISH, "No drilling allowed!"),
	]))
	d.sequences.append(DialogSequence.new([
		DialogLine.new(SPEAKERS.FISH, "How dare you?"),
	]))
	d.sequences.append(DialogSequence.new([
		DialogLine.new(SPEAKERS.FISH, "You're kinda fishy as well, aye?"),
	]))
	d.sequences.append(DialogSequence.new([
		DialogLine.new(SPEAKERS.FISH, "Could you please stop already?!"),
	]))
	d.sequences.append(DialogSequence.new([
		DialogLine.new(SPEAKERS.FISH, "I bet your mother was a vacuum cleaner..."),
	]))
	d.sequences.append(DialogSequence.new([
		DialogLine.new(SPEAKERS.FISH, "..."),
	]))
	d.sequences.append(DialogSequence.new([
		DialogLine.new(SPEAKERS.FISH, "..."),
	]))
	d.sequences.append(DialogSequence.new([
		DialogLine.new(SPEAKERS.FISH, "..."),
	]))
	d.sequences.append(DialogSequence.new([
		DialogLine.new(SPEAKERS.FISH, "Lorem ipsum dolor sit amet, consetetur sadipscing elitr....."),
	]))
	all_dialogs.append(d)

	d = DialogTrigger.new("game_won")
	d.sequences.append(DialogSequence.new([
		DialogLine.new(SPEAKERS.ROLLER, "Yes. Nice. We beat the game..."),
	]))
	all_dialogs.append(d)
	
	d = DialogTrigger.new("ofcourse_chest")
	d.sequences.append(DialogSequence.new([
		DialogLine.new(SPEAKERS.ROLLER, "Ofcourse you would drill that chest..."),
	]))
	all_dialogs.append(d)
