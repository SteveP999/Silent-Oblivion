@echo off
for %%I in (.) do set REPO=%%~nxI
echo.
echo ==========================================
echo  HTR Update — %REPO%
echo ==========================================
echo.
if not exist "songs.json" (echo ERROR: songs.json not found & pause & exit /b 1)
where node >nul 2>&1
if %errorlevel% neq 0 (echo WARNING: Node.js not found. Skipping auto-generation. & goto :PUSH)
echo Generating latest.json...
node -e "const fs=require('fs');const songs=JSON.parse(fs.readFileSync('songs.json','utf8'));const latest=songs.find(s=>s.isLatest)||songs[songs.length-1];const out={title:latest.title,artist:latest.artist,album:latest.album,type:'Latest Single',cover:latest.cover,image:latest.cover,audio:latest.audio,audioSrc:latest.audio};fs.writeFileSync('latest.json',JSON.stringify(out,null,2));console.log('  -> '+latest.title);"
if %errorlevel% neq 0 (echo ERROR generating latest.json & pause & exit /b 1)
echo Generating radio.json...
node -e "const fs=require('fs');const songs=JSON.parse(fs.readFileSync('songs.json','utf8'));const latest=songs.find(s=>s.isLatest)||songs[songs.length-1];const others=songs.filter(s=>s.id!==latest.id);const repo=process.cwd().split('\\').pop().split('/').pop();const base='https://raw.githubusercontent.com/SteveP999/'+repo+'/main';const radio={artist:latest.artist,latestUrl:base+'/latest.json',featuredTrack:{title:latest.title,artist:latest.artist,album:latest.album,cover:latest.cover,audioSrc:latest.audio},tracks:others.map(s=>({title:s.title,album:s.album,cover:s.cover,audioSrc:s.audio}))};fs.writeFileSync('radio.json',JSON.stringify(radio,null,2));console.log('  -> '+others.length+' additional tracks');"
:PUSH
echo.
echo Pushing to GitHub...
git add .
git status
echo.
set /p MSG="Commit message (Enter = 'update songs'): "
if "%MSG%"=="" set MSG=update songs
git commit -m "%MSG%"
git push --force
if %errorlevel% equ 0 (echo. & echo ========================================== & echo  SUCCESS! %REPO% is live. & echo ==========================================) else (echo ERROR: Push failed.)
echo.
pause
