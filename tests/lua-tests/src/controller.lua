
-- jit off
-- local jit = require("jit")
-- jit.off()
-- avoid memory leak
collectgarbage("setpause", 100) 
collectgarbage("setstepmul", 5000)
	

----------------
-- run
local director = cc.Director:getInstance()
local glView   = director:getOpenGLView()
local widthx = 1024
local heighty = 2112
if nil == glView then
    glView = cc.GLView:createWithRect("Lua Tests", cc.rect(0,0,widthx,heighty))
    director:setOpenGLView(glView)
end

--turn on display FPS
director:setDisplayStats(true)

--set FPS. the default value is 1.0/60 if you don't call this
director:setAnimationInterval(1.0 / 60)

local screenSize = glView:getFrameSize()

local designSize = {width = widthx / 2, height = heighty / 2}

if screenSize.height > 320 then
    local resourceSize = {width = widthx, height = heighty}
    cc.Director:getInstance():setContentScaleFactor(resourceSize.height/designSize.height)
end

glView:setDesignResolutionSize(designSize.width, designSize.height, cc.ResolutionPolicy.NO_BORDER)

local fileUtils = cc.FileUtils:getInstance()
local function addSearchPath(resPrefix, height)
    local searchPaths = fileUtils:getSearchPaths()
    table.insert(searchPaths, 1, resPrefix)
    table.insert(searchPaths, 1, resPrefix .. "cocosbuilderRes")
    
    if screenSize.height > 320 then
        table.insert(searchPaths, 1, resPrefix .. "hd")
        table.insert(searchPaths, 1, resPrefix .. "ccs-res")
        table.insert(searchPaths, 1, resPrefix .. "ccs-res/hd")
        table.insert(searchPaths, 1, resPrefix .. "ccs-res/hd/Images")
        table.insert(searchPaths, 1, resPrefix .. "ccs-res/hd/scenetest/ArmatureComponentTest")
        table.insert(searchPaths, 1, resPrefix .. "ccs-res/hd/scenetest/AttributeComponentTest")
        table.insert(searchPaths, 1, resPrefix .. "ccs-res/hd/scenetest/BackgroundComponentTest")
        table.insert(searchPaths, 1, resPrefix .. "ccs-res/hd/scenetest/EffectComponentTest")
        table.insert(searchPaths, 1, resPrefix .. "ccs-res/hd/scenetest/LoadSceneEdtiorFileTest")
        table.insert(searchPaths, 1, resPrefix .. "ccs-res/hd/scenetest/ParticleComponentTest")
        table.insert(searchPaths, 1, resPrefix .. "ccs-res/hd/scenetest/SpriteComponentTest")
        table.insert(searchPaths, 1, resPrefix .. "ccs-res/hd/scenetest/TmxMapComponentTest")
        table.insert(searchPaths, 1, resPrefix .. "ccs-res/hd/scenetest/UIComponentTest")
        table.insert(searchPaths, 1, resPrefix .. "ccs-res/hd/scenetest/TriggerTest")
    else
        table.insert(searchPaths, 1, resPrefix .. "ccs-res/Images")
        table.insert(searchPaths, 1, resPrefix .. "ccs-res/scenetest/ArmatureComponentTest")
        table.insert(searchPaths, 1, resPrefix .. "ccs-res/scenetest/AttributeComponentTest")
        table.insert(searchPaths, 1, resPrefix .. "ccs-res/scenetest/BackgroundComponentTest")
        table.insert(searchPaths, 1, resPrefix .. "ccs-res/scenetest/EffectComponentTest")
        table.insert(searchPaths, 1, resPrefix .. "ccs-res/scenetest/LoadSceneEdtiorFileTest")
        table.insert(searchPaths, 1, resPrefix .. "ccs-res/scenetest/ParticleComponentTest")
        table.insert(searchPaths, 1, resPrefix .. "ccs-res/scenetest/SpriteComponentTest")
        table.insert(searchPaths, 1, resPrefix .. "ccs-res/scenetest/TmxMapComponentTest")
        table.insert(searchPaths, 1, resPrefix .. "ccs-res/scenetest/UIComponentTest")
        table.insert(searchPaths, 1, resPrefix .. "ccs-res/scenetest/TriggerTest")
    end

    fileUtils:setSearchPaths(searchPaths)

end

addSearchPath("res/", screenSize.height)
addSearchPath("", screenSize.height)


require "src/mainMenu"

local scene = cc.Scene:create()
scene:addChild(CreateTestMenu())
if cc.Director:getInstance():getRunningScene() then
    cc.Director:getInstance():replaceScene(scene)
else
    cc.Director:getInstance():runWithScene(scene)
end
