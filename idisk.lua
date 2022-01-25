
function writeMeta(sourcepath)
  isAdv = term.isColor()
  isTurt = turtle and true or false
  print("Creating install metafile")
  print("  Advanced: "..tostring(isAdv))
  print("  Turtle:   "..tostring(isTurt))
  metafile = fs.open("disk/idiskmeta", "w")
  metafile.writeLine("advanced "..tostring(isAdv))
  metafile.writeLine("turtle "..tostring(isTurt))
  metafile.close()
  print("  Done writing metafile")
  print("Writing install file (disk/startup)")
  sourcefile = fs.open(sourcepath, "rb")
  installfile = fs.open("disk/startup", "wb")
  installfile.write(sourcefile.readAll())
  sourcefile.close()
  installfile.close()
end
function promptWipeDisk()
  
  if table.getn(fs.list('disk')) > 0 then
    term.setCursorPos(3, 2)
    term.write("Destroy contents of disk?")
    term.setCursorPos(3, 3)
    term.write(tostring(table.getn(fs.list('disk'))).." files found")
    term.setCursorPos(3, 4)
    term.write("Press Y or N")
    e, k = os.pullEvent("char")
    if k == "y" then
      function walk(path)
        for i, v in ipairs(fs.list(path)) do
          if fs.isDir(path..v) then
            walk(path..v..'/')
            fs.delete(path..v)
          else
            print("  > Delete "..path..v)
            fs.delete(path..v)
          end
        end
      end
      print()
      walk("disk/")
      return true
    elseif k == "n" then
      return false
    end
  else
    term.setCursorPos(3, 2)
    term.write("Nothing on disk to delete")
    return true
  end
  return false
end

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

function makeInstallDir()
  fs.makeDir("disk/install")
  print("    Created install dir")
end
function makeCopyDir()
  fs.makeDir("disk/install/copy")
  print("    Created install/copy dir")
end

function prepareFS()
  print("  Preparing filesystem")
  pcall(makeInstallDir)
  pcall(makeCopyDir)
  print("  ... done")
end

-- Put files you don't want to transfer into a "protected" folder!

function transferFS()
  print()
  print("  Begin transfer")
  function walk(path)
    for i, v in ipairs(fs.list(path)) do
      if fs.isDir(path..v) and v ~= "disk" and v ~= "rom" and v ~= "protected" then
        walk(path..v..'/')
      elseif not fs.isDir(path..v) then
        if not string.find(v, "idisk") then
          print("  > Copy "..path..v.." to disk/install/copy/"..path..v)
          srcfile = fs.open(path..v, "rb")
          dstfile = fs.open("disk/install/copy/"..path..v, "wb")
          dstfile.write(srcfile.readAll())
          srcfile.close()
          dstfile.close()
        end
      else
        print("  ~ Skipping folder "..path..v.." due to it being ignored")
      end
    end
  end
  walk('')
end

function main()
  print("iDisk disk creator v0.1")
  if not fs.exists('disk') then
    printError("No disk found!")
    cleanUp()
    return
  end
  blankScreen('7', '7')
  if not promptWipeDisk() then
    cleanUp()
    return
  end
  sleep(1)
  blankScreen('7', '7')
  term.setCursorPos(3, 2)
  writeMeta("idiskpayload.lua")
  prepareFS()
  sleep(1)
  blankScreen('7', '7')
  term.setCursorPos(3, 1)
  transferFS()
  print("Press any key to exit")
  os.pullEvent("char")
  cleanUp()
end
main()