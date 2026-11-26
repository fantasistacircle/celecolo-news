@echo off
chcp 65001 >nul
cd /d "%~dp0"
echo news.txt を板に反映します（GitHub に上げます）
git add news.txt
git commit -m "お知らせを更新" >nul
git pull --rebase --autostash -q
git push
if errorlevel 1 (echo 失敗しました。上の英語の行を Claude に見せてね& pause & exit /b 1)
echo 上げました。1〜2 分で板に出ます（ワールドに入り直すと読み直します）
pause
