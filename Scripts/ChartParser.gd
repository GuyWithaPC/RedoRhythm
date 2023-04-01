extends Object

class_name ChartParser

var file: String
var parsed: Dictionary = {
	"song":"",
	"bpm":0,
	"up":[],
	"right":[],
	"down":[],
	"left":[]
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
	if words[0].to_lower() == "song":
		var songName = ""
		for word in words.slice(1):
			songName += word
		parsed.song = songName
		return
	if words[0].to_lower() == "bpm":
		parsed.bpm = int(words[1])
		secondsPerBeat = 60.0/parsed.bpm
		return
	if words[0].to_lower() == "wait":
		var addTime = float(words[1])*secondsPerBeat
		time += addTime
		if inLoop:
			loopTimer += addTime
		return
	if words[0].to_lower() == "send":
		for word in words.slice(1):
			if !inLoop:
				parsed[word].append(time)
			else:
				loopDict[word].append(time)
		return
	if words[0].to_lower() == "loop":
		inLoop = true
		loopTimes = int(words[1])
		return
	if words[0].to_lower() == "end":
		inLoop = false
		for i in range(loopTimes):
			for t in loopDict.up:
				parsed.up.append(t + loopTimer*i)
			for t in loopDict.down:
				parsed.down.append(t + loopTimer*i)
			for t in loopDict.left:
				parsed.left.append(t + loopTimer*i)
			for t in loopDict.right:
				parsed.right.append(t + loopTimer*i)
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
