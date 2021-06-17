import  random, strformat, httpclient, strutils, os, threadpool, tables, hashes

let colors = {"red": "\e[31m", "yellow":"\e[33m", "cyan":"\e[36m", "green": "\e[32m", "blue":"\e[34m", "def":"\e[0m"}.toTable


let 
    help="""
----------------- BEGIN OF HELP -----------------

-t=200 Number of threads to use
-p=yes/no Need to use proxies or not
-n=500 Number of code to check per threads

------------------ END OF HELP ------------------
"""
    banner = """
    _   ________  _____________  ____  _____________   __
   / | / /  _/  |/  /_  __/ __ \/ __ \/ ____/ ____/ | / /
  /  |/ // // /|_/ / / / / /_/ / / / / / __/ __/ /  |/ / 
 / /|  // // /  / / / / / _, _/ /_/ / /_/ / /___/ /|  /  
/_/ |_/___/_/  /_/ /_/ /_/ |_|\____/\____/_____/_/ |_/
                                    by 0x454d505459#5042
"""
var 
    params: seq[string]
    threads_counts: int = 200
    useproxies: bool = true
    codes_to_check: int = 500

if paramCount() < 1: echo help ; quit(1)
for i in 1..paramCount(): params.add(paramStr(i))

for param in params:
    if param.startsWith("-t"):
       threads_counts = parseInt(param.split('=')[1])
    elif param.startsWith("-p"):
        if param.split('=')[1] == "yes": useproxies = true else: useproxies = false
    elif param.startsWith("-n"):
        codes_to_check = parseInt(param.split('=')[1])

type EKeyboardInterrupt = object of CatchableError

proc handler() {.noconv.} =
  raise newException(EKeyboardInterrupt, "Keyboard Interrupt")

setControlCHook(handler)

var proxies: seq[Proxy]

proc proxy_loader() =
    if not useproxies: return
    echo &"{colors[\"blue\"]}INFO{colors[\"def\"]}: Loading proxies"
    if not os.fileExists("./proxies.txt"): echo &"{colors[\"red\"]}ERROR{colors[\"def\"]}: Create a proxy file named 'proxies.txt' with HTTP proxies inside"; quit(1)
    let file = readFile("./proxies.txt")
    if file == "": echo &"{colors[\"red\"]}ERROR{colors[\"def\"]}: Add some proxies to proxies.txt"; quit(1)
    let lines = file.splitLines()
    var proxies_count = 0
    for proxy in lines:
        let myproxy = newProxy(proxy)
        proxies.add(myproxy)
        proxies_count += 1
    echo &"{colors[\"blue\"]}INFO{colors[\"def\"]}: Loaded {colors[\"green\"]}{proxies_count}{colors[\"def\"]} proxies"

proc gen(): string = 
    randomize()
    let chars = @["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", 
    "o", "p", "q","r", "s", "t", "u", "v", "w", "x","y", "z", "A", "B", "C", "D", 
    "E", "F", "G", "H","I","J", "K", "L", "M", "O", "P", "Q","R", "S", "T", "U",
     "V", "W", "X","Y", "Z", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
    var code = ""
    for i in 1..16: code &= sample(chars)
    return code

proc check(code:string, proxies: seq): string = 
    var client: HttpClient
    if useproxies: 
        client = newHttpClient(proxy = sample(proxies)) 
    else: 
        client = newHttpClient()

    try: discard client.getContent(&"https://discord.com/api/v9/entitlements/gift-codes/{code}?with_application=false&with_subscription_plan=true"); return "true" except HttpRequestError: return "false" except OSError: return "OSERROR"

proc processus(proxies: seq, colors: Table) {.thread.} = 
    for i in 1..codes_to_check:
        let code = gen()
        let checked = check(code, proxies)
        if checked == "true": echo &"{colors[\"blue\"]}INFOS{colors[\"def\"]}: found {colors[\"green\"]}working{colors[\"def\"]} code: {code}" elif checked == "false": echo &"{colors[\"blue\"]}INFO{colors[\"def\"]}: found {colors[\"red\"]}not working{colors[\"def\"]} code: {code}"  else: echo &"{colors[\"yellow\"]}WARNING{colors[\"def\"]}: Not working proxy"


proxy_loader()
echo &"{colors[\"cyan\"]}{banner}{colors[\"def\"]}"
try:
    for i in 1..threads_counts:
        spawn processus(proxies, colors)
    echo &"{colors[\"yellow\"]}WARNING{colors[\"def\"]}: Waiting for all threads to finish"
    sync()
    echo &"{colors[\"green\"]}INFO{colors[\"def\"]}: Finished checking all codes"


except EKeyboardInterrupt:
    echo &"\n{colors[\"green\"]}Goodbye:){colors[\"def\"]}"