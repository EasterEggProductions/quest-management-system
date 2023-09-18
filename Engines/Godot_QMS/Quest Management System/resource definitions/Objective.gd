extends Resource
class_name Objective

@export var text_brief : String
@export var complete : bool
@export var command : String

# internal 
var event_tags : Array[String]
var num_required : int
var num_done : int

func ready_objective():
	setup_listeners()
	if text_brief == "":
		text_brief = command

func end_q():
	remove_listeners()

func setup_listeners():
	var chopped = command.split(" ")
	if chopped[0] == 'KILL':
		event_tags = []
		num_required = 1
		num_done = 0
		for i in range(1, len(chopped)):
			if chopped[i][0] in "0123456789": #Quick easy if num check
				num_required = int(chopped[i])
			else:
				event_tags.append(chopped[i])
		#connect(QMS.something_died
		QMS.creature_killed.connect(_on_kill_event)
	elif chopped[0] == "GOTO":

		event_tags = []
		num_required = 1
		num_done = 0
		for i in range(1, len(chopped)):
			if chopped[i][0] in "0123456789": #Quick easy if num check
				num_required = int(chopped[i])
			else:
				event_tags.append(chopped[i])
		QMS.location_entered.connect(_on_goto_event)
	else:
		# Default to special event handler
		event_tags = []
		num_required = 1
		num_done = 0
		#event_tags.append(chopped[0]) # add in what would be the specific tag
		for i in range(1, len(chopped)):
			if chopped[i][0] in "0123456789": #Quick easy if num check
				num_required = int(chopped[i])
			else:
				event_tags.append(chopped[i])
		#connect(QMS.something_died
		QMS.special_event.connect(_on_special_event)



func remove_listeners():
	if complete:
		return # Bit of a HACK , better way to do this needed.
	var chopped = command.split(" ")
	if chopped[0] == 'KILL':
		if QMS.creature_killed.is_connected(_on_kill_event):
			QMS.creature_killed.disconnect(_on_kill_event)
	elif chopped[0] == "GOTO":
		if QMS.creature_killed.is_connected(_on_goto_event):
			QMS.creature_killed.disconnect(_on_goto_event)
	else:
		# Default to special event handler
		if QMS.special_event.is_connected(_on_special_event):
			QMS.special_event.disconnect(_on_special_event)


func _on_kill_event(obituary):
	print("Objective: " + str(obituary))
	print("GOT EM!")
	for tag in event_tags:
		if tag not in obituary:
			print("it's not who I was looking for")
			return
	print("We care! :D")
	num_done += 1
	if num_done >= num_required:
		complete = true
		print("OBJECTIVE COMPLETE!")
		QMS.creature_killed.disconnect(_on_kill_event)

func _on_goto_event(visitors_guide):
	print("Objective: " + str(visitors_guide))
	print("WENT EM!")
	for tag in event_tags:
		if tag not in visitors_guide:
			print("it's not where I was looking for")
			return
	print("We care! :D")
	num_done += 1
	if num_done >= num_required:
		complete = true
		print("OBJECTIVE COMPLETE!")
		QMS.location_entered.disconnect(_on_goto_event)

func _on_special_event(whatMakesItSpecial):
	print("Objective: " + str(whatMakesItSpecial))
	print("GOT EM!")
	for tag in event_tags:
		if tag not in whatMakesItSpecial:
			print("it's not who I was looking for")
			return
	print("It's an older code, but it checks out.")
	num_done += 1
	if num_done >= num_required:
		complete = true
		print("OBJECTIVE COMPLETE!")
		if QMS.creature_killed.is_connected(_on_special_event):
			QMS.creature_killed.disconnect(_on_special_event)

### 
# Objective notation: CAPITAL objective type, followed by number, followed by text tags
# no number, default to 1
# text tags for event checking
# Objective when made subscribes to signal of particular type.
# signal emits with array of tags describing event.
# EX Kill pirate, so it emits on kill signal with:
# ["Pirate","Ergskerler","FactionRank","Level3","NPC_NAME_HERE"]
# Since it had pirate and ergskerler in it, it would incriment
# on the next thing here.
# Makes objectives save out on one line of text, for json or other. 
# still need normal readable text line, progress tracking, and complete bool
#KILL:5 Pirate Ergskerler | KILL 2 Ergskerler Liutenant
#TIMER:5 minutes
#GET:1 Sweetroll
#CURRENCY:50
#GOTO:Earth
