class_name ShapeT
extends ShapeGeneric

func _init() -> void:
	tetrominoe_matrix = [
			{1 : [Vector2i(1,1),Vector2i(0,1),Vector2i(2,1),Vector2i(1,0)] as Array[Vector2i]}
			,{2 : [Vector2i(1,1),Vector2i(1,0),Vector2i(1,2),Vector2i(2,1)] as Array[Vector2i]}
			,{3 : [Vector2i(1,1),Vector2i(0,1),Vector2i(2,1),Vector2i(1,2)] as Array[Vector2i]}
			,{4 : [Vector2i(1,1),Vector2i(1,0),Vector2i(1,2),Vector2i(0,1)] as Array[Vector2i]}
		]		
	tetrominoe_texture = ExternalResourceLoader.sprites["t"]["square"]
	thumbnail = ExternalResourceLoader.sprites["t"]["thumbnail"]
	x_offset = 3
	super()
