extends Control
class_name Console


@onready var message_container: VBoxContainer = $ConsoleContainer/ConsoleScrollContainer/ConsoleMarginContainer/MessageContainer
@onready var warning_container: VBoxContainer = $ConsoleContainer/ConsoleScrollContainer/ConsoleMarginContainer/WarningContainer
@onready var info_container: VBoxContainer = $ConsoleContainer/ConsoleScrollContainer/ConsoleMarginContainer/InfoContainer

@onready var console_scroll_container: ScrollContainer = $ConsoleContainer/ConsoleScrollContainer


## Checks if a message container contains more than 100 messages.
## If so, the first message out of those 100+ is freed.
func check_message_limit(container: Container) -> void:
	var children = container.get_children()
	if children:
		if len(children) > 100:
			var removed_child = children[0]
			removed_child.queue_free()


## Adds a warning message to the All and Warnings tab.
func add_warning(message: String, click_function: Callable) -> void:
	var warning_message1: WarningMessage = WarningMessage.new(message, click_function)
	var warning_message2: WarningMessage = WarningMessage.new(message, click_function)
	warning_container.add_child(warning_message1)
	message_container.add_child(warning_message2)
	
	check_message_limit(warning_container)
	check_message_limit(message_container)
	
	scroll_to_bottom()


## Adds an info message to the All and Info tabs.
func add_info(message: String) -> void:
	var info_message1: ConsoleMessage = ConsoleMessage.new(message)
	var info_message2: ConsoleMessage = ConsoleMessage.new(message)
	info_container.add_child(info_message1)
	message_container.add_child(info_message2)
	
	check_message_limit(info_container)
	check_message_limit(message_container)
	
	scroll_to_bottom()


## When the All button is pressed, show the All tab and hide the rest.
func _on_all_button_pressed() -> void:
	message_container.show()
	info_container.hide()
	warning_container.hide()


## When the Info button is pressed, show the Info tab and hide the rest.
func _on_info_button_pressed() -> void:
	message_container.hide()
	info_container.show()
	warning_container.hide()


## When the Warnings button is pressed, show the Warnings tab and hide the rest.
func _on_warning_button_pressed() -> void:
	message_container.hide()
	info_container.hide()
	warning_container.show()


## Scroll the console scroll container to the bottom.
func scroll_to_bottom() -> void:
	await get_tree().process_frame
	console_scroll_container.scroll_vertical = console_scroll_container.get_v_scroll_bar().max_value
