-- filepath: c:\Users\aguv\Desktop\TRASH 1\lua-dolar\build.bat
@echo off
echo Building lua-dolar portable...

rem Create distribution folder
if exist "dist" rd /s /q "dist"
mkdir dist\lua-dolar-portable

rem Create .love file
powershell Compress-Archive -Path main.lua,conf.lua,json.lua -DestinationPath game.zip
ren game.zip lua-dolar.love

rem Create executable
copy /b "C:\Program Files\LOVE\love.exe"+"lua-dolar.love" "dist\lua-dolar-portable\lua-dolar.exe"

rem Copy required DLLs
copy "C:\Program Files\LOVE\*.dll" "dist\lua-dolar-portable"

rem Create final ZIP
cd dist
powershell Compress-Archive -Path lua-dolar-portable -DestinationPath lua-dolar-portable.zip
cd ..

rem Cleanup
del lua-dolar.love

echo Build complete! Check dist\lua-dolar-portable.zip
pause