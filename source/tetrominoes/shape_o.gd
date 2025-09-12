class_name ShapeO
extends ShapeGeneric

func _init() -> void:
	tetrominoe_matrix = [
			{1 : [Vector2i(1,1),Vector2i(2,1),Vector2i(1,2),Vector2i(2,2)] as Array[Vector2i]}
		]		
	tetrominoe_texture = ExternalResourceLoader.sprites["o"]["square"]
	thumbnail = ExternalResourceLoader.sprites["o"]["thumbnail"]
	x_offset = 3
	super()
