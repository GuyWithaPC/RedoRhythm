extends Object

class_name ChartParser

const DISTANCE = 256
const bpmSpeedFactor = 1.5
var file: String
var parsed: Dictionary = {
	"song":"",
	"bpm":0,
	"up":[],
	"right":[],
	"down":[],
	"left":[],
	"messages":{},
	"bpmChanges":{},
	"winTime":{}
}
var time: float
var secondsPerBeat: float
var inLoop: bool
var loopTimes: int
var loopTimer: float
var loopDict: Dictionary = {
	"left":[],
	"right":[],
	"up":[],
	"down":[]
}
var mostRecentBpm: int = 0

func loadTextFile(fileName: String) -> String:
	return FileAccess.get_file_as_string(fileName)

func loadChart(chartName: String) -> Dictionary:
	file = loadTextFile("res://Charts/"+chartName+".txt")
	var lines = file.split("\n")
	for line in lines:
		parseLine(line)
	parsed.left.sort()
	parsed.right.sort()
	parsed.up.sort()
	parsed.down.sort()
	print_debug(parsed)
	return parsed

func parseLine(line: String):
	var words = line.split(" ")
	if words.is_empty():
		return
	if words[0] == "#":
		return
	if words[0] == "win":
		parsed.winTime = time
	if words[0] == "message":
		var message = ""
		for word in words.slice(1):
			message += word + " "
		message.rstrip(" ")
		parsed.messages[time] = message
	if words[0].to_lower() == "song":
		var songName = ""
		for word in words.slice(1):
			songName += word
		parsed.song = songName
		return
	if words[0].to_lower() == "bpm":
		if parsed.bpm == 0: parsed.bpm = int(words[1])
		mostRecentBpm = int(words[1])
		print(mostRecentBpm)
		parsed.bpmChanges[time] = int(words[1])
		secondsPerBeat = 60.0/int(words[1])
		return
	if words[0].to_lower() == "wait":
		var addTime = float(words[1])*secondsPerBeat
		time += addTime
		if inLoop:
			loopTimer += addTime
		return
	if words[0].to_lower() == "send":
		var speed = mostRecentBpm / bpmSpeedFactor
		var correctedTime = time - (DISTANCE / speed)
		for word in words.slice(1):
			if !inLoop:
				parsed[word].append([correctedTime,speed])
			else:
				loopDict[word].append([correctedTime,speed])
		return
	if words[0].to_lower() == "loop":
		inLoop = true
		loopTimes = int(words[1])
		return
	if words[0].to_lower() == "end":
		inLoop = false
		for i in range(loopTimes):
			for t in loopDict.up:
				parsed.up.append([t[0] + loopTimer*i,t[1]])
			for t in loopDict.down:
				parsed.down.append([t[0] + loopTimer*i,t[1]])
			for t in loopDict.left:
				parsed.left.append([t[0] + loopTimer*i,t[1]])
			for t in loopDict.right:
				parsed.right.append([t[0] + loopTimer*i,t[1]])
		time += loopTimer*(loopTimes-1)
		loopDict = {
			"left":[],
			"right":[],
			"up":[],
			"down":[]
		}
		loopTimer = 0
		return
	if words[0].to_lower() == "back":
		var addTime = float(words[1])*secondsPerBeat
		time -= addTime
		if inLoop:
			loopTimer -= addTime
		return
