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

backgroundColor = colors.lightGray
uiColor1 = colors.white
uiColor2 = colors.gray

colorMap = {}
functionMap = {}
overrideFunctionMap = {}

appExt = ".app"
prgExt = ".prg"
apiExt = ".lua"
setExt = ".set"
navExt = ".nav"
picExt = ".pic"
anmExt = ".anm"
vidExt = ".vid"