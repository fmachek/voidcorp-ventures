extends Label
class_name MonthLabel


@onready var time_manager: TimeManager = $"/root/Game/TimeManager"


func _ready() -> void:
	update_text(time_manager.current_month)
	time_manager.connect("month_changed", _on_month_changed)


func update_text(month: int) -> void:
	text = "Month " + str(month)


func _on_month_changed(new_month: int):
	update_text(new_month)
