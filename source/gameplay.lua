--start gameplay

currdad=-2.0
dad_desc={
	"ecstatic",
	"happy",
	"complacent",
	"disappointed",
	"angry"
}
needs_redadding=false

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

	create_dads()
	create_customer()

end

function create_dads()
	remove_all_dads()
	for x=0,128,1 do 
		for y=0,128,1 do 
			if(rnd(100) / 100 < .02
				and fget(mget(x,y),2)
				and distance(x*8,y*8,actor[2].x,actor[2].y)<128) then
					create_dad(x*8,(y-1)*8)
			end
		end
	end
end

function remove_all_dads()
	for t in all(actor) do
		if(is_type(t, "dad")) del(actor,t)
	end
end

function create_dad(x,y)

	local dad_text={
		{"i'm here to capture you!", "hi here to capture you,\ni'm dad"},
		{"wowwww","this is a test"}
	}

	local enemy = create_actor(x,y,1,2)
	enemy.sp=11
	enemy.maxspeed=.5
	add(enemy.type,"talkable")
	add(enemy.type,"dad")
	add(enemy.type,"health")
	enemy.capturechance=rnd(.5)
	enemy.maxcapchance=.65
	enemy.throwmod=.2
	local ang=rnd(1)
	enemy.angerlevel=rnd(1.0) - ang
	enemy.runchance=rnd(.1)
	enemy.evasion=rnd(.15)
	enemy.diag=pick_random_response(dad_text)

end

function restart_game()

	actor[1].x=39*8
	actor[1].y=50*8

end

waiting={}
walkingout={}
leaving=false
accepted=false
function start_new_cycle()
	create_customer()
end

function turn_in()
	local right_responses={
		"this is exactly what i wanted!",
		"just the right dad",
		"wow! great dad!"
	}
	local wrong_responses={
		"not exactly what i wanted",
		"i'm never coming back!"
	}
	--if(waiting!={}) then
	if(get_current_anger(waiting.wants) == get_current_anger(currdad)) then start_dialogue({"just what i was looking for!"},nil,function() walkingout=waiting currdad=-2.0 create_customer() leaving=true end)
	else	start_dialogue({"not exactly what i wanted..."},nil,function() walkingout=waiting currdad=-2.0 create_customer() leaving=true end)
		--end
		
	end
end

function create_customer()
	local cust = create_actor(39*8,64*8,1,2)
	local neg=rnd(1)
	cust.wants=rnd(1.0)-neg
	waiting=cust
	caninput=false
	accepted=false
end

function manage_customer()
	if(waiting!={} and distance(actor[1].x, actor[1].y, waiting.x, waiting.y)<64 and currdad!=-2.0 and btnp(4)) then
		turn_in()
	end
	if(accepted==false and waiting!=nil and moveto(waiting, 39*8, 54*8) and indialogue==false) then
		local tips={
			"you can find dads in the\ntall grass",
			"complacent dads are\nthe hardest to catch",
			"if you faint, you'll come\nback to the store"
		}
		local tip=pick_random_response(tips)
		if(get_current_anger(waiting.wants) == dad_desc[5]) start_dialogue({"i want an angry dad",tip},nil, function() accepted=true end)
		if(get_current_anger(waiting.wants) == dad_desc[4]) start_dialogue({"i want a disappointed dad",tip},nil, function() accepted=true end)
		if(get_current_anger(waiting.wants) == dad_desc[3]) start_dialogue({"i want a complacent dad",tip},nil, function() accepted=true end)
		if(get_current_anger(waiting.wants) == dad_desc[2]) start_dialogue({"i want a happy dad",tip},nil, function() accepted=true end)
		if(get_current_anger(waiting.wants) == dad_desc[1]) start_dialogue({"i want an ecstatic dad",tip},nil, function() accepted=true end)
	end

	if(leaving and moveto(walkingout, 42*8,64*8)) then del(actor,walkingout) end
end

function get_current_anger(l)
	if(l<-.66)	return dad_desc[5]
	if(l<-.33 and l>-.66)	return dad_desc[4]
	if(l>-.33 and l <.33)	return dad_desc[3]
	if(l>.33 and l <.66)	return dad_desc[2]
	if(l>.66)	return dad_desc[1]
end

menu_open=false
menu_state="main"
menu_select=1
function draw_menu()
	draw_tip()
end

function draw_tip()
	if(accepted) then
		rectfill(actor[2].x,actor[2].y+116,actor[2].x+52,actor[2].y+128,1)
		local color=7
		if(currdad!=-2) then
			if(get_current_anger(currdad)==get_current_anger(waiting.wants)) color=12
			if(get_current_anger(currdad)!=get_current_anger(waiting.wants)) color=8
		end
		print(get_current_anger(waiting.wants), actor[2].x+4, actor[2].y+120, color)
	end
	if(currdad!=-2)	then
		spr(58, actor[2].x+12, actor[2].y+120,1,1)
	end
end

function game_loop()
	if(indialogue) in_dialogue()
	if(inbattle) then
		battle_mode()
	end
	manage_customer()
end

function menu_update()
	if(btnp(5))	then	menu_open=false return end
	if(menu_state=="main") then
	end
end