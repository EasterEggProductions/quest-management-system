extends Node
## This script is to be set as an autoload named "QMS", and extensions proceed with that in mind.
## This was developed in VS code with the 'Comment Anchors' extension, which highlights certain comments

var player_quest_journal = {} # A dictionary of quests by quest_name. More advanced system may be needed
var moi_quest : Quest # a reference to a single quest, like a 'currently tracked' quest

var all_quests = {} #prototypes I guess. I have no fucking clue
# Signals for quest related events
signal location_entered(location_details : Array[String]) #GOTO
signal creature_killed(obituary : Array[String]) #KILL
signal special_event(whatMakesItSpecial : Array[String]) #SPECIAL -default if verb not found



# Called when the node enters the scene tree for the first time.
func _ready():
	load_quests()

	# SECTION EEP Game console registration
	# disabled, EGC is a system I use elsewhere, but didn't include to keep this package focused
	# register_with_console() 


func register_with_console():	
	# disabled, EGC is a system I use elsewhere, but didn't include to keep this package focused
	console.get_node("EEP_GameConsole").registerCommand("questGive", Callable(self, "console_giveQuest"))
	console.get_node("EEP_GameConsole").registerCommand("questDrop", Callable(self, "console_abandonQuest"))
	console.get_node("EEP_GameConsole").registerCommand("questTurnIn", Callable(self, "console_turninQuest"))



func load_quests():
	var quest_dir = "res://Quest Management System/Quests/"
	var dir = DirAccess.open(quest_dir)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				print("Found directory: " + file_name)
			elif file_name.ends_with(".quest"):
				print("Found file: " + file_name)
				var temp_q = quest_parse(FileAccess.open(quest_dir + file_name, FileAccess.READ).get_as_text())
				all_quests[temp_q.quest_name] = temp_q
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")

func something_died(obituary : Array[String]):
	print("QMS: " + str(obituary))
	creature_killed.emit(obituary)

func goto_event(travel_guide):
	print("QMS GOTO " + str(travel_guide))
	location_entered.emit(travel_guide)

func special_channel(whatMakesItSpecial):
	print("Special :3" + str(whatMakesItSpecial))
	special_event.emit(whatMakesItSpecial)

func random_quest() -> Quest:
	var keys = all_quests.keys()
	return all_quests[keys[randi_range(0, len(keys)-1)]]

func restart_quest(quest_journal : Dictionary, quest_key : String):
	## FIXME not complete, currently abandons quest and starts random one
	if quest_key in quest_journal.keys():
		abandon_quest(player_quest_journal, quest_key)
	give_quest(player_quest_journal, random_quest().quest_name)
	print(quest_journal[quest_key].objective_groups[0])

	if(is_instance_valid( moi_quest)):
		abandon_quest(player_quest_journal, moi_quest.quest_name)


func console_giveQuest(new_tokens : PackedStringArray) -> String:
	## This is a command made to be linked to the EEP game console. It is not integral.
	return give_quest(player_quest_journal, new_tokens[0])

func give_quest(quest_journal : Dictionary, quest_key : String) -> String:
	if quest_key in quest_journal.keys():
		return "Quest already started: " + quest_key
	elif quest_key in all_quests.keys():
		var new_quest : Quest = all_quests[quest_key].duplicate(true)
		new_quest.ready_quest()
		quest_journal[new_quest.quest_name] = new_quest
		moi_quest = new_quest
		return "Qeust granted: " + quest_key
	else:
		return "Idk, how did I get here?"

func console_abandonQuest(new_tokens : PackedStringArray) -> String:
	## This is a command made to be linked to the EEP game console. It is not integral.
	if new_tokens[0] in player_quest_journal.keys():
		abandon_quest(player_quest_journal, new_tokens[0])
		return "Quest abandoned: " + new_tokens[0]
	return "Quest not in player journal"

func abandon_quest(quest_journal : Dictionary, quest_key : String): # better name possible?
	if quest_key in quest_journal.keys():
		quest_journal[quest_key].end_q()


func console_turninQuest(new_tokens : PackedStringArray) -> String:
	## This is a command made to be linked to the EEP game console. It is not integral.
	if new_tokens[0] in player_quest_journal.keys():
		turnIn_quest(player_quest_journal, new_tokens[0])
		if player_quest_journal[new_tokens[0]].complete == true:
			return "Quest turned in: " + new_tokens[0]
		else:
			return "Quest failed turn in: " + new_tokens[0]
	return "Quest not in player journal"

func turnIn_quest(quest_journal : Dictionary, quest_key : String):
	if quest_key in quest_journal.keys():
		var q = quest_journal[quest_key]
		q.quest_turn_in()

func quest_parse(data : String) -> Quest:
	## This is a basic parser for the quest file format. 
	## It is not done, this only parses one quest. 
	## TODO more robust system that loads a file with multiple quests
	var returnable = Quest.new()
	var lines = data.split("\n")
	var keywords = ["QUEST","checkout","turn_in","ObjectiveGroup"]
	var ogGrp_keywords = ["objectives","rewards","hidden","threshold"]
	# read until first keyword
	var current_line = 0
	while current_line < len(lines):
		var line = lines[current_line].strip_edges()
		var tok1 = line.substr(0,line.find(":"))
		match tok1:
			"QUEST": 
				returnable.quest_name = line.split(":")[1].strip_edges()
			"checkout":
				returnable.checkout = line.split(":")[1].strip_edges()
			"turn_in":
				returnable.turnIn = line.split(":")[1].strip_edges()
			"ObjectiveGroup":
				var obGrp = ObjectiveGroup.new()
				returnable.objective_groups.append(obGrp)
				obGrp.name = line.split(":")[1].strip_edges()
				current_line += 1
				var og_line = lines[current_line].strip_edges()
				var tok2 = og_line.substr(0,og_line.find(":"))
				while tok2 not in keywords:
					match tok2:
						"hidden":
							if og_line.split(":")[1].strip_edges().to_lower() == 'true':
								obGrp.hidden = true 
						"threshold":
							obGrp.threshold = int(og_line.split(":")[1].strip_edges())
						"objectives":
							current_line += 1
							var objectiveLine = lines[current_line].strip_edges()
							while ":" not in objectiveLine: 
								var objective = Objective.new()
								objective.command = objectiveLine
								obGrp.objectives.append(objective)
								current_line += 1
								if current_line >= len(lines):
									break
								objectiveLine = lines[current_line].strip_edges()
							current_line -= 1 # FIXME bad parser design
						"rewards":
							current_line += 1
							var reward = lines[current_line].strip_edges()
							while ":" not in reward: 
								#print("   Reward: " + reward)
								obGrp.rewards.append(reward)
								current_line += 1
								if current_line >= len(lines):
									break
								reward = lines[current_line].strip_edges()
							current_line -= 1 # FIXME bad parser design
						_:
							pass 
					current_line += 1
					if current_line >= len(lines):
						break
					og_line = lines[current_line].strip_edges()
					tok2 = og_line.substr(0,og_line.find(":"))
				current_line -= 1 # FIXME bad parser design
			_:
				pass
		current_line += 1
	
	return returnable
