extends Area3D

func _on_body_entered(body):
	var player_camera := (body as Player).camera # !!!!! BAD, REPLACE THIS !!!!!
	var direction := player_camera.Direction.Left if player_camera.transform.origin.x > transform.origin.x else player_camera.Direction.Right
	player_camera.move_car(direction) 
	
