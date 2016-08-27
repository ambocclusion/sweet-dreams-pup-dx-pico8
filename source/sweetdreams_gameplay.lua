pkup_cont=0
time_to_play=180.0

function setup_actors()
	plr = create_actor(64,60,2,2)
	plr.speed=1
	plr.maxspeed=2
	plr.dx=1
	add(plr.type,"player")
	add(plr.type,"health")
	add(plr.type,"jumpable")
	-- idle anim
	idle=plr.anims[1]
	idle.speed=3
	run=create_anim(plr)
	run.start=10
	run.frames=3
	run.speed=4

	local camera = create_actor(0,0,0,0)
	add(camera.type,"camera")
	camera.speed=1
	camera.maxspeed=2

	create_ghosts()
end

function create_ghosts()

	ghosts={}
	ghosts[1]=create_actor(128,62,2,2)
	ghosts[1].anims[1]=create_anim(ghosts[1])
	idleanim=ghosts[1].anims[1]
	idleanim.start=42
	idleanim.speed=3
	idleanim.frames=3

end

function manage_jumper(a)
	if(btn(4) and touch_ground(a)) a.vely=-512
end

function manage_pickup(a)
	pkup_cont+=1
end

function manage_ghost(a)

end

function game_loop()

end

function init_sweetdreams()
	init_timers()
end