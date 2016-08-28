ghost_detect_dist=48

function create_ghosts()
	sfx(2,0)
	sfx(1,1)
	for x=0,128,1 do 
		for y=0,128,1 do 
			if(fget(mget(x,y),4)) then
				create_ghost(x*8,y*8)
				mset(x,y,0)
			end
		end
	end
	
end

function create_ghost(x,y)
	ghost=create_actor(x,y,2,2)
	add(ghost.type, "ghost")
	ghost.speed=1
	ghost.maxspeed=.5
	ghost.yoffset=-8
	ghost.state="idle"
	ghost.idlepoints={}
	add(ghost.idlepoints,ghost.x - 64)
	add(ghost.idlepoints,ghost.x + 64)
	ghost.chasedist=92
	ghost.movingto=1
	ghost.anims[1]=create_anim(ghost)
	idleanim=ghost.anims[1]
	idleanim.start=42
	idleanim.speed=6
	idleanim.frames=3
	ghost.anims[2]=create_anim(ghost)
	attackanim=ghost.anims[2]
	attackanim.start=32
	attackanim.frames=5
end

function manage_ghost_collision(a)
	a1,a2=solid_actor(a,a.velx,a.vely)

	if(a2!=nil) then
		for t in all(a2.type) do
			if(t=="ghost")	ghost_collide(a2)
		end
	end
end

function ghost_collide(col)
	actor[1].velx=(actor[1].x-col.x)*.75
	if(actor[1].velx > actor[1].maxspeed*3) actor[1].velx=actor[1].maxspeed*2
	if(actor[1].velx < -actor[1].maxspeed*3) actor[1].velx=-actor[1].maxspeed*2
	actor[1].vely=-12
end

function ghost_logic(a)

	a1,a2=solid_actor(a,a.velx,a.vely)

	if(a2!=nil) then
		for t in all(a2.type) do
			if(t=="player")	ghost_collide(a)
		end
	end

	if(a.state=="idle") ghost_idle_state(a)
	if(a.state=="chasing") ghost_chasing_state(a)
	if(a.state=="returning") ghost_returning_state(a)
end

function ghost_idle_state(a)
	a.curranim=1
	a.maxspeed=.5
	if(moveto(a,a.idlepoints[a.movingto],a.y,a.maxspeed))	iter_idlepoint(a)
	if(distance(a.x, a.y, actor[1].x, actor[1].y) < ghost_detect_dist)	a.state="chasing"
end

function ghost_chasing_state(a)
	a.curranim=2
	a.maxspeed=1.5
	moveto(a,actor[1].x,actor[1].y, 1)
	if(distance(a.x,a.y,actor[1].x,actor[1].y) >= 72)	a.state="returning"
end

function ghost_returning_state(a)
	a.curranim=1
	a.maxspeed=.5
	if(moveto(a,a.idlepoints[a.movingto], a.y,1))	a.state="idle"
end

function iter_idlepoint(a)
	a.movingto+=1
	if(a.movingto > #a.idlepoints)	a.movingto=1
end