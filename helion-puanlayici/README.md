# HELION — Puanlayıcı Uygulaması (v21)

Bu uygulama **puanlayacak kişi** içindir. Tek işi vardır: görüşmeye katılıp puanlamak.

## Çalıştırma
- Windows: `Baslat-Windows.bat` — uygulama http://localhost:8016 adresinde açılır.
- Ubuntu: klasörde terminal açıp `bash Baslat-Ubuntu.sh`.

## Akış
1. Astronotun verdiği 6 haneli oda kodunu girin, "Görüşmeyi Başlat"a basın.
2. Görüşme bitince "Görüşmeyi Bitir ve Puanla" ile puanlama ekranına geçin.
3. 5 ölçüte göre puanlayıp "Puanı Kaydet"e basın — puan, astronotun uygulamasına
   **otomatik** gider (kod gerekmez); gönderim bitince bağlantı kendiliğinden kapanır.

Not: Bu uygulama yalnızca görüşme + puanlama içerir; testler ve rapor astronot
uygulamasındadır. Astronot, kendi uygulamasından kendini puanlayamaz.
