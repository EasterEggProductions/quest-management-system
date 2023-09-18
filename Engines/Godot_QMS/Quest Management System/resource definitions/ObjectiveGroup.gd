extends Resource
class_name ObjectiveGroup

@export var name : String
@export var threshold : int
@export var hidden : bool
@export var objectives : Array[Objective]
@export var rewards : Array[String]

func ready_group():
	var new_hacky_array : Array[Objective ] = []
	for objective in objectives:
		var neu = objective.duplicate()
		neu.ready_objective()
		new_hacky_array.append(neu)
	objectives = new_hacky_array

func objectives_complete() -> bool:
	for ob in objectives:
		if ob.complete == false:
			return false
	return true

func objectives_over_threshold():
	if threshold == 0: ## special case, 0 means all
		print("threshold 0")
		print(objectives_complete())
		return objectives_complete()
	var count = 0
	for ob in objectives:
		if ob.complete:
			count += 1
	return count >= threshold

func end_q():
	for o in objectives:
		o.end_q()

func _to_string():
	return name
