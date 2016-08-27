function setup_actors()
	plr = create_actor(39*8,50*8,1,2)
	plr.speed=1
	plr.maxspeed=2
	add(plr.type,"player")
	add(plr.type,"health")

	local camera = create_actor(32*8,32*8,0,0)
	add(camera.type,"camera")
	camera.speed=1
	camera.maxspeed=2
end