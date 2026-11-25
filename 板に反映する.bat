@echo off
chcp 65001 >nul
cd /d "%~dp0"
echo news.txt を板に反映します（GitHub に上げます）
git add news.txt
git commit -m "お知らせを更新" >nul
git pull --rebase --autostash -q
git push
if errorlevel 1 (echo 失敗しました。上の英語の行を Claude に見せてね& pause & exit /b 1)
rem 本番のワールドが新しい置き場に入れ替わるまで、古い置き場にも news.txt と version.txt を写す（sync-old.sh）
"C:\Program Files\Git\bin\sh.exe" sync-old.sh
if errorlevel 1 (echo 古い置き場への写しに失敗しました。上の行を Claude に見せてね) else (echo 上げました。1〜2 分で板に出ます（ワールドに入り直すと読み直します）)
pause
