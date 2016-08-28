function create_ghosts()
	sfx(2,0)
	sfx(1,1)
	ghosts={}
	ghosts[1]=create_actor(128,62,2,2)
	add(ghosts[1].type, "ghost")
	ghosts[1].speed=1
	ghosts[1].maxspeed=2
	ghosts[1].state="idle"
	ghosts[1].idlepoints={}
	add(ghosts[1].idlepoints,ghosts[1].x - 64)
	add(ghosts[1].idlepoints,ghosts[1].x + 64)
	ghosts[1].chasedist=92
	ghosts[1].movingto=1
	ghosts[1].anims[1]=create_anim(ghosts[1])
	idleanim=ghosts[1].anims[1]
	idleanim.start=42
	idleanim.speed=6
	idleanim.frames=3
end

function ghost_logic(a)
	--if(a.state=="idle") ghost_idle_state(a)
	--if(a.state=="chasing") ghost_chasing_state(a)
	--if(a.state=="returning") ghost_returning_state(a)
end

function ghost_idle_state(a)
	moveto(a,a.idlepoints[a.movingto],a.y,a.maxspeed)
	addToPrintQ(flr(a.x).." "..a.idlepoints[a.movingto])
	addToPrintQ(a.movingto)
	if(a.x-a.idlepoints[a.movingto] <= 1.0) then
		iter_idlepoint(a)
	end
end

function ghost_chasing_state(a)

end

function iter_idlepoint(a)
	a.movingto+=1
	if(a.movingto > #a.idlepoints) then
		a.movingto=1
	end
end