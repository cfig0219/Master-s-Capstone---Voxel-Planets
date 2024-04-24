@tool
extends Area3D
class_name BoundingBoxes

var bounding_radius = 100
# an array of arrays that contains all the bounding boxes
var bounding_boxes = [[], [], [], [], [], [], []]

	
# initializes all the bounding boxes
func set_bounding_boxes():
	# creates the root planet bounding box
	var planet_box = CollisionShape3D.new()
	planet_box.shape = SphereShape3D.new()
	planet_box.scale = Vector3(bounding_radius*20, bounding_radius*20, bounding_radius*20)
	self.add_child(planet_box)
	bounding_boxes[0].append(planet_box)
	
	# initializes parent face bounding boxes
	for i in range(1,7):
		var parent_face = CollisionShape3D.new()
		parent_face.shape = BoxShape3D.new()
		parent_face.scale = Vector3(bounding_radius*6, bounding_radius*6, bounding_radius*6)
		
		# rotates the box depending on the current index
		if i == 1: # top
			parent_face.translate(Vector3(0, 0.5, 0))
			parent_face.rotate_x(deg_to_rad(180))
		if i == 2: # bottom
			parent_face.translate(Vector3(0, -0.5, 0))
			parent_face.rotate_x(deg_to_rad(0))
		if i == 3: # left
			parent_face.translate(Vector3(-0.5, 0, 0))
			parent_face.rotate_z(deg_to_rad(270))
		if i == 4: # right
			parent_face.translate(Vector3(0.5, 0, 0))
			parent_face.rotate_z(deg_to_rad(90))
		if i == 5: # front
			parent_face.translate(Vector3(0, 0, -0.5))
			parent_face.rotate_x(deg_to_rad(90))
		if i == 6: # back
			parent_face.translate(Vector3(0, 0, 0.5))
			parent_face.rotate_x(deg_to_rad(270))
		
		# appends new boxes to the bounding boxes array
		self.add_child(parent_face)
		bounding_boxes[i].append(parent_face)
	#print(bounding_boxes)
	
	
# calls when initializes
func _ready():
	set_bounding_boxes()
	
# player is present
func _process(delta):
	#print("called")
	pass
