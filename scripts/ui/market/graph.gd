extends Control
class_name Graph


# Points being drawn on the graph
var points: Array[Vector2] = []

# Init variables
var x_axis_name: String
var y_axis_name: String
var x_axis_length: int
var y_axis_length: int
var x_scale: float
var y_scale: float
var x_start: int
var y_start: int

# Contains labels for X and Y axis values
var label_control: Control
# Contains registered Y values
var y_values: Array = []


func _ready() -> void:
	label_control = Control.new()
	label_control.name = "LabelControl"
	add_child(label_control)
	add_axis_labels()
	queue_redraw()


func _init(x_axis_length: int, y_axis_length: int, x_scale: float, y_scale: float, x_start: int, y_start: int, x_axis_name: String, y_axis_name: String):
	self.x_axis_length = x_axis_length
	self.y_axis_length = y_axis_length
	self.x_axis_name = x_axis_name
	self.y_axis_name = y_axis_name
	self.x_scale = x_scale
	self.y_scale = y_scale
	self.x_start = x_start
	self.y_start = y_start
	
	self.custom_minimum_size = Vector2(x_axis_length, y_axis_length)
	
	self.pivot_offset = Vector2(0, -y_axis_length)


func _draw() -> void:
	draw_axis()
	free_labels()
	y_values.clear()
	if points:
		draw_points(points)


func draw_axis() -> void:
	# X axis
	draw_line(Vector2(0, y_axis_length), Vector2(x_axis_length, y_axis_length), Color.WHITE, 2)
	# Y axis
	draw_line(Vector2(0, 0), Vector2(0, y_axis_length), Color.WHITE, 2)


func draw_points(points: Array[Vector2]) -> void:
	var prev_point = Vector2(0, 0)
	for point: Vector2 in points:
		# Calculated graph point, taking into consideration
		# the X and Y axis start values and scales. The Y value
		# is also inverted, and the Y axis length is added to it to
		# move it to the graph space.
		var recalculated_point: Vector2 = Vector2((point.x - x_start) * x_scale, (-point.y + y_start) * y_scale + y_axis_length)
		
		# Draw vertical line for X
		draw_line(Vector2(recalculated_point.x, y_axis_length), Vector2(recalculated_point.x, 0), Color("#ffffff2a"), 1)
		# Draw horizontal line for Y
		if not point.y in y_values:
			draw_line(Vector2(0, recalculated_point.y), Vector2(x_axis_length, recalculated_point.y), Color("#ffffff2a"), 1)
		
		# Draw point
		draw_circle(recalculated_point, 3, Color.WHITE, true)
		# Connect point with previous point
		draw_line(prev_point, recalculated_point, Color.WHITE, 1)
		prev_point = recalculated_point
		
		# Add the X and Y axis value labels
		add_value_labels(point, recalculated_point)


func add_value_labels(point: Vector2, recalculated_point: Vector2) -> void:
	var x = recalculated_point.x
	var y = -recalculated_point.y
	
	# Create X axis label
	var x_label: Label = Label.new()
	# Don't initialize Y axis label yet
	var y_label: Label
	# Array of labels, only X axis label for now
	var labels = [x_label]
	
	# Set the X label text
	x_label.text = str(point.x)
	
	# Create the Y axis label, but only if the Y value
	# hasn't already been drawn.
	if not point.y in y_values:
		y_label = Label.new()
		y_label.text = str(point.y)
		# Add the label to the labels array
		labels.append(y_label)
		# Add the Y value to the array of registered Y values
		y_values.append(point.y)
	
	# Set some properties for both labels, or only X
	for label: Label in labels:
		label.add_theme_font_size_override("font_size", 6)
		label.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		label_control.add_child(label)
	
	# Draw small lines showing values on X and Y axis
	x_label.position = Vector2(x - (x_label.size.x/2), 5 + y_axis_length)
	draw_line(Vector2(x, 3 + y_axis_length), Vector2(x, -3 + y_axis_length), Color.WHITE, 1)
	# Draw the line for Y axis too, if the label was initialized
	if y_label:
		y_label.position = Vector2(-y_label.size.x - 5, -y - y_label.size.y/2)
		draw_line(Vector2(-3, -y), Vector2(3, -y), Color.WHITE, 1)


func add_axis_labels() -> void:
	# Add the X axis name label
	var x_label: Label = Label.new()
	x_label.text = x_axis_name
	add_child(x_label)
	x_label.add_theme_font_size_override("font_size", 6)
	x_label.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	x_label.position = Vector2(x_axis_length + 5, -(x_label.size.y/4) + y_axis_length)
	
	# Add the Y axis name label
	var y_label: Label = Label.new()
	y_label.text = y_axis_name
	add_child(y_label)
	y_label.add_theme_font_size_override("font_size", 6)
	y_label.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	y_label.position = Vector2(-y_label.size.x/2, -y_axis_length + y_axis_length)


func load_points(points: Array[Vector2]) -> void:
	# Set the points array and redraw with the new points
	self.points = points
	var highest_x
	var highest_y
	var lowest_x
	var lowest_y
	# Find lowest Y and X and highest Y and X
	for point in points:
		if highest_x == null:
			highest_x = point.x
		else:
			if point.x > highest_x:
				highest_x = point.x
		if highest_y == null:
			highest_y = point.y
		else:
			if point.y > highest_y:
				highest_y = point.y
		if lowest_x == null:
			lowest_x = point.x
		elif point.x < lowest_x:
			lowest_x = point.x
		if lowest_y == null:
			lowest_y = point.y
		elif point.y < lowest_y:
			lowest_y = point.y
	
	# Calculate the difference between highest X and lowest X (and Y)
	var x_diff = highest_x - lowest_x
	var y_diff = highest_y - lowest_y
	
	# Calculate X and Y scale
	x_scale = x_axis_length/x_diff
	if y_diff == 0:
		y_scale = 1
	else:
		y_scale = y_axis_length/float(y_diff * 1.5)
	
	x_start = lowest_x
	
	# Calculate Y start
	if lowest_y - int(y_diff / 10) > 0:
		if y_diff == 0:
			y_start = 0
		else:
			y_start = lowest_y - int(y_diff / 5)
	else:
		y_start = 0
	
	queue_redraw()


func add_points(new_points: Array[Vector2]) -> void:
	# Append points and redraw with both the old and new points
	for point: Vector2 in points:
		points.append(point)
		queue_redraw()


func free_labels() -> void:
	# Remove the labels showing values on X and Y axis
	var children = label_control.get_children()
	if children:
		for child in children:
			child.queue_free()


func set_x_start(new_x_start: int) -> void:
	self.x_start = new_x_start
