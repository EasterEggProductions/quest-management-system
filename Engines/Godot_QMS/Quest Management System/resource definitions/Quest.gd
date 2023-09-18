extends Resource
class_name Quest 

@export var quest_name : String
var checkout = "No one"
var turnIn = "None"
@export var objective_groups : Array[ObjectiveGroup]
var complete : bool

func ready_quest():
	var new_hacky_array : Array[ObjectiveGroup] = []
	for og in objective_groups:
		var neu = og.duplicate()
		neu.ready_group()
		new_hacky_array.append(neu)
	objective_groups = new_hacky_array

func quest_complete() -> bool:
	return objective_groups[0].objectives_complete()

func quest_turn_in():
	if not quest_complete():
		return
	for og in objective_groups:
		print(og.objectives_over_threshold())
		if og.objectives_over_threshold():
			print("yo")
			# fake cash in objectives
			for rew in og.rewards:
				print("REWARD: " + rew)
	complete = true 
	end_q()

func end_q():
	for og in objective_groups:
		og.end_q()

# TODO my own .quest parser
#func to_json():
#	var returnable = {}
