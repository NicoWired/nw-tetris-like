class_name ShapeI
extends ShapeGeneric

func _init() -> void:
	tetrominoe_matrix = [
			{1 : [Vector2i(0,1),Vector2i(1,1),Vector2i(2,1),Vector2i(3,1)] as Array[Vector2i]}
			,{2 : [Vector2i(1,0),Vector2i(1,1),Vector2i(1,2),Vector2i(1,3)] as Array[Vector2i]}
			,{3 : [Vector2i(0,2),Vector2i(1,2),Vector2i(2,2),Vector2i(3,2)] as Array[Vector2i]}
			,{4 : [Vector2i(2,0),Vector2i(2,1),Vector2i(2,2),Vector2i(2,3)] as Array[Vector2i]}
		]
	tetrominoe_texture = ExternalResourceLoader.sprites["i"]["square"]
	thumbnail = ExternalResourceLoader.sprites["i"]["thumbnail"]
	x_offset = 3
	super()
