-- dummy text
function blankScreen(fg, bg)
  w, h = term.getSize()
  term.setCursorPos(0, 0)
  term.setBackgroundColor(colors.gray)
  term.setTextColor(colors.white)
  for i=1,h+1 do
    term.blit(string.rep(" ", w+1), string.rep(fg, w+1), string.rep(bg, w+1))
    x, y = term.getCursorPos()
    term.setCursorPos(0, y+1)
  end
end
function cleanUp()
  blankScreen('f', 'f')
  term.setCursorPos(0, 0)
  term.setBackgroundColor(colors.black)
  term.setTextColor(colors.white)
  print()
end

function transferFS()
  print("  Begin transfer")
  function walk(path)
    print("Searching... "..path)
    for i, v in ipairs(fs.list(path)) do
      if fs.isDir(path..v) then
        walk(path..v..'/')
      elseif not fs.isDir(path..v) then
        if v ~= "idisk.lua" then
          print("  > Copy "..path..v.." to "..string.gsub(path..v, "disk/install/copy/", ""))
          srcfile = fs.open(path..v, "rb")
          dstfile = fs.open(string.gsub(path..v, "disk/install/copy/", ""), "wb")
          dstfile.write(srcfile.readAll())
          srcfile.close()
          dstfile.close()
        end
      else
        print("  ~ Skipping folder "..path..v.." due to it being ignored")
      end
    end
  end
  walk("disk/install/copy/")
end

function checkMeta()
  print("Checking install environment...")
  metafile = fs.open("disk/idiskmeta", "r")
  one = metafile.readLine()
  two = metafile.readLine()
  metafile.close()
  currentAdv = term.isColor()
  currentTurt = turtle and true or false
  function parseMetaLine(text)
    lKey = nil
    lValue = nil
    for i in string.gmatch(text, "%S+") do
      if lKey == nil then lKey = i else lValue = i end
    end
    return lKey, lValue
  end
  fileAdv = nil
  fileTurt = nil
  key1, val1 = parseMetaLine(one)
  val1 = val1 == "true"
  if key1 == "advanced" then
    fileAdv = val1
  end
  key2, val2 = parseMetaLine(one)
  val2 = val2 == "true"
  if key2 == "advanced" then
    fileAdv = val1
  end
end

function main()
  blankScreen('7', '7')
  term.setCursorPos(3, 1)
  print("Welcome to the IDisk installer!")
  print("  Press ENTER to install the software")
  print("  Ensure that this is the only disk inserted.")
  print()
  print("Connected peripherals:")
  con = peripheral.getNames()
  for i, v in ipairs(con) do
    term.write(v..'  ')
  end
  e, k = os.pullEvent("key")
  print(k)
  print(keys.enter)
  if k ~= keys.enter then
    cleanUp()
    print("Install canceled.")
    return
  end
  blankScreen('7', '7')
  term.setCursorPos(3, 1)
  transferFS()
  sleep(1)
  print("Install complete; Press any key")
  os.pullEvent("key")
  cleanUp()
  print("Install complete.")
  print("Please remove disk.")
end

main()