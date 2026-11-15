#!/bin/sh
# HELION baslatici (Ubuntu/Linux): eski sunucuyu kapatir, yenisini acar, tarayiciyi acar.
cd "$(dirname "$0")" || exit 1
PORT=8020
echo "HELION baslatiliyor: http://localhost:$PORT"
# Bu portta eski surumden kalma bir sunucu varsa kapat (port cakismasi hatasini onler)
(command -v fuser >/dev/null 2>&1 && fuser -k $PORT/tcp) >/dev/null 2>&1
pkill -f "http.server $PORT" >/dev/null 2>&1
sleep 1
python3 -m http.server $PORT &
sleep 1
xdg-open "http://localhost:$PORT" >/dev/null 2>&1
wait
