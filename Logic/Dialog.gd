extends Node

func _ready():
	create_all_dialogs()

enum SPEAKERS {DRILL, ROLLER, MERCHANT, FISH}

var names = {
	SPEAKERS.DRILL: "Robot",
	SPEAKERS.ROLLER: "Human",
	SPEAKERS.MERCHANT: "Merchant",
	SPEAKERS.FISH: "Fish",
}

var colors = {
	SPEAKERS.DRILL: Color.steelblue,
	SPEAKERS.ROLLER: Color.orange,
	SPEAKERS.MERCHANT: Color.coral,
	SPEAKERS.FISH: Color.white,
}

var icons = {
	SPEAKERS.DRILL: preload("res://Assets/Sprites/characters/drill.png"),
	SPEAKERS.ROLLER: preload("res://Assets/Sprites/characters/roller.png"),
	SPEAKERS.MERCHANT: preload("res://Assets/Sprites/characters/human_PLACEHOLDER.png"),
	SPEAKERS.FISH: preload("res://Assets/Sprites/characters/human_PLACEHOLDER.png"),
}

class DialogLine:
	var speaker_id: int
	var text: String
	var duration: float
	
	func _init(sid, t, d := 3.0):
		speaker_id = sid
		text = t
		duration = d
	
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
		DialogLine.new(SPEAKERS.DRILL, "The oxygen levels are going down..."),
		DialogLine.new(SPEAKERS.DRILL, "Soon we must swim to the surface!"),
		DialogLine.new(SPEAKERS.ROLLER, "Then we better hurry."),
	]))
	d.sequences.append(DialogSequence.new([
		DialogLine.new(SPEAKERS.DRILL, "The oxygen levels are going down again..."),
		DialogLine.new(SPEAKERS.ROLLER, "It always happens so fast"),
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
	
	d = DialogTrigger.new("gold_earned")
	d.trigger_mode = TRIGGER_MODES.VALUE_GREATER_EQ
	d.condition_value = 100
	d.sequences.append(DialogSequence.new([
		DialogLine.new(SPEAKERS.ROLLER, "Amazing, now we can afford the Bomb!"),
		DialogLine.new(SPEAKERS.DRILL, "I would love to use it."),
	]))
	all_dialogs.append(d)
	
	
	d = DialogTrigger.new("see_a_fish")
	d.trigger_mode = TRIGGER_MODES.CHANCE
	d.condition_value = .5
	d.selection_mode = SELECTION_MODES.RANDOM
	d.sequences.append(DialogSequence.new([
		DialogLine.new(SPEAKERS.ROLLER, "There is a fish!"),
	]))
	d.sequences.append(DialogSequence.new([
		DialogLine.new(SPEAKERS.DRILL, "Another fish over there."),
	]))
	d.sequences.append(DialogSequence.new([
		DialogLine.new(SPEAKERS.ROLLER, "I like fishes."),
	]))
	all_dialogs.append(d)
	
	
	d = DialogTrigger.new("close_to_eel")
	d.sequences.append(DialogSequence.new([
		DialogLine.new(SPEAKERS.ROLLER, "There are eels, eww!", 2.0),
		DialogLine.new(SPEAKERS.DRILL, "Disgusting!", .8),
		DialogLine.new(SPEAKERS.ROLLER, "Disgusting!", .8),
		DialogLine.new(SPEAKERS.DRILL, "Attack!", 1.8),
	]))
	d.sequences.append(DialogSequence.new([
		DialogLine.new(SPEAKERS.ROLLER, "These eels look really scary..", 2.0),
		DialogLine.new(SPEAKERS.DRILL, "I've seen them before. They drain our power levels!"),
		DialogLine.new(SPEAKERS.ROLLER, "Sounds scary.", 1.5),
	]))
	d.sequences.append(DialogSequence.new([
		DialogLine.new(SPEAKERS.DRILL, "There has to be a way to fend the eels off!"),
		DialogLine.new(SPEAKERS.ROLLER, "You know that's what I'm built for, right? I just need energy crystals."),
		DialogLine.new(SPEAKERS.DRILL, "Those shiny purple ones, right.."),
	]))
	all_dialogs.append(d)


