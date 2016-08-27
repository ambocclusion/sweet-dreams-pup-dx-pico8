pkup_cont=0
time_to_play=180.0

function setup_actors()
	plr = create_actor(64,0,2,2)
	plr.speed=1
	plr.maxspeed=2
	add(plr.type,"player")
	add(plr.type,"health")
	add(plr.type,"animator")
	-- idle anim
	plr.anims={}
	plr.anims[1]={}
	plr.anims[1].start=0
	plr.anims[1].frames=4
	plr.anims[1].speed=7
	plr.anims[1].flipx=false
	plr.anims[1].flipy=false
	plr.anims[1].loop=true
	plr.anims[1].reset=false 
	plr.anims[1].step=0
	plr.anims[1].current=0
	plr.anims[1].reverse=true

	local camera = create_actor(0,0,0,0)
	add(camera.type,"camera")
	camera.speed=1
	camera.maxspeed=2
end

function manage_pickup(a)
	pkup_cont+=1
end

function game_loop()

end

function init_sweetdreams()
	init_timers()
end