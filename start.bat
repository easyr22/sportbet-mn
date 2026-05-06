@echo off
echo SportBet MN - Эхлүүлж байна...
echo.
echo Апп нээгдэх хаяг: http://localhost:3001
echo.

:: Backend + Flutter web нэг дор
start "SportBet MN" python "%~dp0backend\server.py"

:: 2 секунд хүлээгээд Brave-д нээх
timeout /t 2 /nobreak >nul
start "" "C:\Program Files\BraveSoftware\Brave-Browser\Application\brave.exe" "http://localhost:3001"
