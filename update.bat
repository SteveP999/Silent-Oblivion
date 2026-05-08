@echo off
:: ============================================================
:: Hello Texas Records — Artist Site Update Script
:: Repo-safe update for standardized HTR artist sites.
:: Generates latest.json and radio.json from songs.json, then pushes.
:: ============================================================

for %%I in (.) do set REPO=%%~nxI

echo.
echo ==========================================
echo  HTR Artist Update — %REPO%
echo ==========================================
echo.

if not exist "songs.json" (
  echo ERROR: songs.json not found in %CD%
  pause
  exit /b 1
)

where node >nul 2>&1
if %errorlevel% neq 0 (
  echo ERROR: Node.js not found. Cannot validate/generate JSON.
  echo Install Node.js or update latest.json/radio.json manually.
  pause
  exit /b 1
)

echo Validating songs.json and generating latest.json / radio.json...
node -e "const fs=require('fs'); const songs=JSON.parse(fs.readFileSync('songs.json','utf8')); if(!Array.isArray(songs)||!songs.length) throw new Error('songs.json must be a non-empty array'); const required=['id','title','artist','album','cover','audio']; for(const s of songs){ for(const k of required){ if(!s[k]) throw new Error('Missing '+k+' on song: '+(s.title||s.id||'UNKNOWN')); } if(!Array.isArray(s.videos)) s.videos=[]; if(!s.streaming) s.streaming={spotify:'',appleMusic:'',youtubeMusic:''}; if(typeof s.includeOnRadio==='undefined') s.includeOnRadio=true; if(typeof s.includeOnHomepage==='undefined') s.includeOnHomepage=true; } fs.writeFileSync('songs.json',JSON.stringify(songs,null,2)); const latest=songs.find(s=>s.isLatest)||songs[songs.length-1]; const latestOut={title:latest.title,artist:latest.artist,album:latest.album,type:latest.type||'Latest Single',cover:latest.cover,image:latest.cover,audio:latest.audio,audioSrc:latest.audio,streaming:latest.streaming||{},videos:Array.isArray(latest.videos)?latest.videos:[]}; fs.writeFileSync('latest.json',JSON.stringify(latestOut,null,2)); const repo=process.cwd().split('\\').pop().split('/').pop(); const base='https://raw.githubusercontent.com/SteveP999/'+repo+'/main'; const radioTracks=songs.filter(s=>s.includeOnRadio!==false); const radio={artist:latest.artist,latestUrl:base+'/latest.json',featuredTrack:{title:latest.title,artist:latest.artist,album:latest.album,cover:latest.cover,audioSrc:latest.audio,streaming:latest.streaming||{},videos:Array.isArray(latest.videos)?latest.videos:[]},tracks:radioTracks.map(s=>({id:s.id,title:s.title,artist:s.artist,album:s.album,cover:s.cover,audioSrc:s.audio,streaming:s.streaming||{},videos:Array.isArray(s.videos)?s.videos:[]}))}; fs.writeFileSync('radio.json',JSON.stringify(radio,null,2)); console.log('Latest: '+latest.title); console.log('Radio tracks: '+radioTracks.length);"
if %errorlevel% neq 0 (
  echo ERROR: JSON validation/generation failed.
  pause
  exit /b 1
)

echo.
echo Pushing to GitHub...
git add .
git status
echo.
set /p MSG="Commit message (Enter = 'update artist site'): "
if "%MSG%"=="" set MSG=update artist site
git commit -m "%MSG%"
git push
if %errorlevel% equ 0 (
  echo.
  echo ==========================================
  echo  SUCCESS! %REPO% was pushed.
  echo ==========================================
) else (
  echo ERROR: Push failed. Check git credentials/branch.
)
echo.
pause
