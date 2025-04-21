extends Node

## This enum provides information about the current input type (for example NORMAL or SENDING_SPACESHIP).
## It means that an action is currently taking place and the game has to react accordingly.
enum InputMode {NORMAL, SENDING_SPACESHIP, SENDING_CREW}

## The current input mode.
var current_input_mode: InputMode = InputMode.NORMAL
## Variable used to store information about the planet a spaceship is being sent to
## during the SENDING_SPACESHIP input mode.
var spaceship_source: Planet = null
## Spaceship being currently controlled by the player.
var current_spaceship_controlled: Spaceship = null
## Crew ship is being sent from this planet.
var current_crew_planet: Planet = null

## This signal is emitted when the input mode changes.
signal input_mode_changed(new_mode: InputMode)
## This signal is emitted when the spaceship that is currently being controlled changes.
signal spaceship_controlled_changed(new_spaceship: Spaceship)
## Emitted when the player attempts to send a crew ship but doesn't have enough money.
signal no_money_for_crew()

var connecting_line: ConnectingLine = null


## This function sets the current input mode enum.
func set_input_mode(mode: InputMode) -> void:
	current_input_mode = mode
	emit_signal('input_mode_changed', current_input_mode)
	
	if current_input_mode == InputMode.SENDING_CREW:
		if not connecting_line:
			var line_scene = load("res://scenes/misc/ConnectingLine.tscn")
			connecting_line = line_scene.instantiate()
			$"/root/Game".add_child(connecting_line)
		else:
			connecting_line.show()
	else:
		if connecting_line:
			connecting_line.hide()


## Sets the spaceship being currently controlled.
func set_spaceship_controlled(spaceship: Spaceship):
	self.current_spaceship_controlled = spaceship
	emit_signal('spaceship_controlled_changed', spaceship)


## Stops the spaceship controlling mode.
func end_spaceship_control():
	spaceship_source = null
	set_spaceship_controlled(null)
	set_input_mode(InputMode.NORMAL)


## Sends a crew ship from a planet to the destination direction.
func send_crew_to(destination: Vector2) -> void:
	if current_crew_planet:
		if GameManager.spend_money(500):
			current_crew_planet.send_crew_ship(destination)
			set_input_mode(InputMode.NORMAL)
			current_crew_planet = null
		else:
			emit_signal("no_money_for_crew")


## Sets the current crew ship planet.
func set_current_crew_planet(planet: Planet) -> void:
	current_crew_planet = planet
	connecting_line.set_point1(current_crew_planet.global_position)
	connecting_line.follow_mouse()


## Resets itself. Sets some variables to their original state.
func reset() -> void:
	current_input_mode = InputMode.NORMAL
	spaceship_source = null
	current_spaceship_controlled = null
	current_crew_planet = null
	connecting_line = null
