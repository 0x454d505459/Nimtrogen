import random, strformat, httpclient, strutils, os
randomize()

let 
    red = "\e[31m"
    yellow = "\e[33m"
    # cyan = "\e[36m"
    green = "\e[32m"
    blue = "\e[34m"
    default = "\e[0m"



type EKeyboardInterrupt = object of CatchableError

proc handler() {.noconv.} =
  raise newException(EKeyboardInterrupt, "Keyboard Interrupt")

setControlCHook(handler)


# var proxies_list: seq[Proxy]


proc read(args: string): string =
  stdout.write(args)
  result = stdin.readline()

# proc config(): bool =
#     if not os.fileExists("./config.cfg"):
#         echo &"{red}Config file not found, please create a config file according to template available on github{default}"
#         quit()
#     let content:string = readFile("./config.cfg")
#     let splitted = content.split('\n')
#     var check_code = splitted[0]
#     check_code = check_code.split(' ')[1]
#     if check_code == "true": return true else: return false

# proc proxyfy() =
#     if not os.fileExists("./proxies.txt"):
#         echo &"{red}proxies.txt file not found, please create a proxies file according to template available on github{default}"
#         quit()

#     let proxy_file = readFile("./proxies.txt")
#     if proxy_file == "":
#         echo &"{red}proxies.txt file empty, please add some proxies to the file{default}"
#         quit()
#     let lines = proxy_file.splitLines()
#     for line in lines:
#         let some_proxy = newProxy(line)
#         proxies_list.add(some_proxy)


proc gen(): string = 
    let chars = @["a", "b", "c", "d", "e", "f", "g", "h","i","j", "k", "l", "m", "o", "p", "q","r", "s", "t", "u", "v", "w", "x","y", "z", "A", "B", "C", "D", "E", "F", "G", "H","I","J", "K", "L", "M", "O", "P", "Q","R", "S", "T", "U", "V", "W", "X","Y", "Z", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
    var code = ""
    for i in countup(1, 16):
        code &= sample(chars)
    
    randomize()
    return code


proc check(code: string): (bool, string) =
    randomize()
    
    let client = newHttpClient()
    try:
        discard client.getContent(&"https://discord.com/api/v6/entitlements/gift-codes/{code}?with_application=false&with_subscription_plan=true")
        return (true, code)
    except HttpRequestError:
        return (false, code)


# proc tothread(code: string) = 
#     let checked = check(code)
#     if checked[0]: echo &"{green}WORKING{default}: found working code: {checked[1]}"
#     if not checked[0]: echo &"{red}INVALID{default}: invalid code: {checked[1]}"


let banner = """

    _   ________  _____________  ____  _____________   __
   / | / /  _/  |/  /_  __/ __ \/ __ \/ ____/ ____/ | / /
  /  |/ // // /|_/ / / / / /_/ / / / / / __/ __/ /  |/ / 
 / /|  // // /  / / / / / _, _/ /_/ / /_/ / /___/ /|  /  
/_/ |_/___/_/  /_/ /_/ /_/ |_|\____/\____/_____/_/ |_/
                                    by 0x454d505459#5042

"""

echo &"{blue}{banner}{default}"
echo ""
# proxyfy()

try:

    let config = read(&"Dou you want to {green}generate{default} or {red}check{default} codes ? {green}g{default}/{red}c{default} > ")
    if config == "g": echo &"{yellow}WARNING{default}: check_code set to {red}FALSE{default}, code checking is disabled" else: echo &"{blue}INFO{default}: check_code set to {green}TRUE{default}, code generator is disabled and checker has been enabled"
    sleep(500)
    echo ""
        
    if config == "g":
        let n = read(&"How many {blue}codes{default} do you want to generate ? > {green}")
        let togen = parseInt(n)
        echo default
        echo &"{yellow}WARNING{default}: writing code to {red}./codes.txt{default} do NOT remove the file or stop the program, it could lead to data loss"
        if not os.fileExists("./codes.txt"): writeFile("codes.txt", "")
        if togen >= 1000000: echo &"{yellow}WARNING{default}: {togen} is really high, please be aware that more than 1 000 000 could take time to generate"
        let f = open("codes.txt", fmWrite)
        for i in countup(1, togen):
            var code = gen()
            f.writeLine(code)
        f.close()
        echo &"{green}SUCCESSFULLY{default} wrote {togen} codes to codes.txt, exiting"

        quit()
    if config == "c":
        if not os.fileExists("./codes.txt") or readFile("./codes.txt") == "":
            echo &"{red}ERROR{default}: codes.txt file does not exist or is empty, please generate some code first"
            quit()
        
        let file = readFile("./codes.txt")
        let lines = file.splitLines()

        for code in lines:
            let checked = check(code)
            if checked[0]: echo &"{green}WORKING{default}: found working code: {checked[1]}"
            if not checked[0]: echo &"{red}INVALID{default}: invalid code: {checked[1]}"

        echo &"{green}SUCCESSFULLY{default} check all codes"

except EKeyboardInterrupt:
    echo &"{default} \n Bye :)"
    quit()
    
# except:
#     echo &"{red}An error occured, exiting...{default}"
#     quit()