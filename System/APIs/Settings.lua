wifiOn = false
soundOn = false

overrideFuncions = false
monitorMode = false
monitor = nil
isLowSpace = false
loggedIn = false
user = ""

sizeX, sizeY = term.getSize()
midX = math.ceil(sizeX / 2)
midY = math.ceil(sizeY / 2)

DEFAULT_BACKGROUND_COLOR = 256
backgroundColor = DEFAULT_BACKGROUND_COLOR
DEFAULT_UI_COLOR_1 = 256
uiColor1 = DEFAULT_UI_COLOR_1
DEFAULT_UI_COLOR_2 = 128
uiColor2 = DEFAULT_UI_COLOR_2

colorMap = {}
functionMap = {}
overrideFunctionMap = {}
paintMap = {}

appExt = ".app"
prgExt = ".prg"
apiExt = ".lua"
setExt = ".set"
picExt = ".pic"
anmExt = ".anm"
vidExt = ".vid"