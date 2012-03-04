function love.conf(t)
	t.title = "COMP 421 - Assignment 2"
	t.author = "Etienne Perot"
	t.screen.width = 800
	t.screen.height = 600
	t.screen.fullscreen = false
	t.screen.vsync = true
	t.screen.fsaa = 0
	t.modules.joystick = false
	t.modules.audio = false
	t.modules.keyboard = true
	t.modules.event = true
	t.modules.image = false
	t.modules.graphics = true
	t.modules.timer = true
	t.modules.mouse = true
	t.modules.sound = false
	t.modules.physics = false
end