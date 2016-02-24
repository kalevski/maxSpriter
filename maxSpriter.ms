function startProgram = (
	if undefined != main then closeRolloutFloater main
	main = newRolloutFloater "Max Spriter" 330 410
	addRollout AboutMe main rolledup:false
	addRollout OptionsRollout main rolledup:false
)

rollout AboutMe "About Me" width:340 (
	label lbl1 "Made by:" pos:[9,6] width:59 height:17
	label lbl2 "Daniel Kalevski" pos:[70,7] width:175 height:14
	label lbl3 "Website:" pos:[9,22] width:59 height:17
	label lbl4 "www.KALEVSKI.com" pos:[71,23] width:175 height:14
)

rollout OptionsRollout  "Render Options" width:340 (
	
	label	lblStartFrame "Frame start" pos:[25,6] width:95	height:16	
	spinner	startFrame "" pos:[5,26] width:95 height:16	range:[-99999,99999,0] type:#integer
	
	label	lblStopFrame "Frame stop" pos:[130,6] width:95 height:16 align:#center
	spinner	stopFrame "" pos:[110,26] width:95 height:16 range:[-99999,99999,0] type:#integer
	
	label	lblJumpFrame "Render every" pos:[230,6] width:95 height:16 
	spinner	jumpFrame "" pos:[215,26] width:95 height:16 range:[-99999,99999,0] type:#integer
	

	GroupBox groupRenderType "Type of render" pos:[175,60] width:135 height:65
	radiobuttons renderType "" pos:[180,80] width:102 height:48 labels:#("In one line", "Multiple lines") columns:1

	GroupBox groupMultiLineType "Only for multiline type" pos:[175,125] width:135 height:120
	button calculateFrames "Calculate frames" pos:[180,145] width:125 height:20
	label	lblCalculateFrames "Frames: --" pos:[185,170] width:100 height:20 
	label	lblFramesInLine "Frames in one line:" pos:[185,200] width:100 height:20 
	spinner	framesInLine "" pos:[180,220] width:125 height:16 range:[-99999,99999,0] type:#integer
	
	multiListBox allCameras "" pos:[5,65] width:160 height:13
	
	button renderButton "Create SpriteSheet!" pos:[5,255] width:305 height:50
	
	
	on calculateFrames pressed do (
		if (renderType.state == 2) do (
			stop = stopFrame.value 
			start = startFrame.value
			jump = jumpFrame.value
			numOfFrames = ((stop - start)/jump+1)
			lblCalculateFrames.text = "Frames: "+numOfFrames as string
			
			defaultNumOfFrames = sqrt numOfFrames as integer
			if (defaultNumOfFrames + 2 <= numOfFrames) do (
				framesInLine.value = defaultNumOfFrames + 2
			)
			if (defaultNumOfFrames + 2 >  numOfFrames) do (
				framesInLine.value = defaultNumOfFrames + 1
			)
		) 
		if (renderType.state == 1) do (
			lblCalculateFrames.text = "Frames: --"
			framesInLine.value = 0
		)
	)
	
	on OptionsRollout open do (
		startFrame.value  = ((animationRange.start) as integer )/ TicksPerFrame as integer
		stopFrame.value  = ((animationRange.end) as integer )/ TicksPerFrame as integer
		jumpFrame.value = 1
		
		foundCameras = #("Top","Back","Front","Left","Bottom","Right","Orthographic","Perspective")
		for findCamera in cameras do (
			if(findString findCamera.name ".Target" == undefined) do (
				append foundCameras findCamera.name
			)
		)
		
		allCameras.items = foundCameras
	)
	
	on browsePath pressed do
	(
		location = getSavePath()
		if(location != undefined) do (
			outputPath.text = location
		)
	)
	
	on renderButton pressed do (
		validate = 1;
		
		camerasArray = allCameras.selection as array
		for i = 1 to camerasArray.count do (
			camerasArray[i] = allCameras.items[camerasArray[i]]
		)
		
		if (validate == 1) do (
			RenderSpriteSheet startFrame.value stopFrame.value jumpFrame.value camerasArray renderType.state framesInLine.value
		)
	)
)

fn RenderSpriteSheet start stop jump camerasArray renderType framesInLine = (
	camCounter = 1
	for cam in camerasArray do (
		
		case cam of (			
			"Top": viewport.setType #view_top
			"Bottom": viewport.setType #view_bottom 
			"Right": viewport.setType #view_right 
			"Left": viewport.setType #view_left 
			"Front": viewport.setType #view_front
			"Back": viewport.setType #view_back 
			"Perspective": viewport.setType #view_persp_user
			"Orthographic": viewport.setType #view_iso_user			
			default: viewport.setCamera (execute ("$'" + cam + "'"))
		)
		completeSprite = render vfb:false 
		height = ((temp = getBitmapInfo completeSprite)[4]) 
		width = ((temp = getBitmapInfo completeSprite)[3])
		numOfFrames = ((stop - start)/jump+1)
		
		if (renderType == 1) then (
			fullWidth  = width * numOfFrames
			fullHeight = height
			bittemp = bitmap fullWidth fullHeight
			for frame = 1 to numOfFrames do (
				sliderTime = (start + ((frame-1) * jump))
				img =  render vfb:false
				for yPix = 0 to height do (
					frameStartX = (frame-1)*width
					setPixels bittemp [frameStartX,yPix] (getPixels img [0,yPix] width)
				)
			)
		)
		
		
		if (renderType == 2) then (
			
			heightLines = numOfFrames / framesInLine
			if (heightLines as float < numOfFrames / framesInLine as float) then (
				heightLines = heightLines + 1
			)
			
			fullWidth = width * framesInLine
			fullHeight = height * heightLines
			
			bittemp = bitmap fullWidth fullHeight
			for frame = 1 to numOfFrames do (
				sliderTime = (start + ((frame-1) * jump))
				img =  render vfb:false
				
				
				frameXX = mod frame framesInLine as integer
				frameXXX = (frame / framesInLine)
				if (frameXX == 0) then ( 
					frameXX = framesInLine 
					frameXXX = frameXXX - 1
				)
				xPixel = (frameXX - 1) * width
				yPixel = frameXXX * height
				
				for yPix = 0 to height do (
					setPixels bittemp [xPixel,yPix+yPixel] (getPixels img [0,yPix] width)
				)
			)
		)
		
		display bittemp
		camCounter = camCounter + 1
	)
)

startProgram()
