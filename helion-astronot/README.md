# HELION

**Aktif hazırlık öz-test bataryası — astronotlar için, sadece laptop kamerasıyla.**
*Active readiness self-test battery for astronauts — laptop camera only, no sensors.*

NASA Space Apps Challenge 2026 · Görev: *Create Health Monitoring Software for Astronauts on Space Missions*
Team HELION — Arel Zafer Okuklu · Kerem Çanta · Ali Yiğit Ok (Ankara, yüz yüze)

**Test et. Bil. Hazır ol.**

---

## Nedir?

HELION, uzun görevdeki astronotun her gün ~5 dakikada kendi kendine uyguladığı bir hazırlık
testidir. Ek sensör, giyilebilir cihaz ya da laboratuvar gerekmez; tek donanım laptop kamerasıdır.

- **4 test:** Fiziksel Sağlık, Hatırlama, Sosyallik, Hassasiyet (Tepki) — her biri 0–100 puan
- **1 rapor:** toplam skor, en zayıf alan (kırmızıyla) ve kişiye özel öneri + gün gün **eğilim grafiği**
- **2 skorsuz ek:** Günlük Takip (su, öğün, uyku, ruh hali, Dünya'ya görev notu) ve Nefes Egzersizi
- **Tamamen çevrimdışı çalışır** (tek istisna: canlı görüntülü görüşmenin sinyal adımı — aşağıda)

Bilimsel çerçeve NASA'nın **RIDGE** modelidir (Human Research Program): Radyasyon, İzolasyon,
Uzaklık, Yerçekimi, Kapalı Ortam. HELION, I ve D'ye doğrudan cevap verir; G ve E'nin etkilerini
izler; radyasyonu ölçmez (kamera ile ölçülemez — bunu açıkça söylüyoruz).

## Hızlı Başlatma

> ⚠️ Dosyaları çift tıklayıp `file://` ile AÇMAYIN. Tarayıcılar, kamera modellerinin yerel
> dosyalardan yüklenmesini güvenlik gereği engeller; uygulama yerel sunucudan çalışmalıdır.

**En kolayı — başlatıcı dosyalar:**

- Ubuntu/Linux: klasörde terminal açıp `bash Baslat-Ubuntu.sh`
- Windows: `Baslat-Windows.bat` dosyasını çalıştırın

İkisi de sunucuyu başlatır ve uygulamayı **http://localhost:8015** adresinde açar.

**Elle:**

```bash
# Ubuntu / Linux
cd helion-app && python3 -m http.server 8000

# Windows
cd helion-app && py -m http.server 8000
```

Sonra tarayıcıda (Chrome/Chromium/Brave önerilir) `localhost:8015` adresine gidin.
Sunucuyu durdurmak için terminali kapatmak yeterlidir. 8000 portu doluysa başka bir port
kullanın (örn. `python3 -m http.server 8001` → `localhost:8001`).

## Bölümler

| Bölüm | Ne ölçer? | Nasıl? |
|---|---|---|
| **Fiziksel Sağlık** | Hareket kabiliyeti, zorlanma | 9 hareket (5 el + 4 vücut); tekrar/açı/süre **kamerayla doğrulanır** (MediaPipe Pose + Hand Landmarker). Zorlanılan hareket işaretlenir. Skor = tamamlama − zorlanılan başına 5 |
| **Hatırlama** | Bilişsel tazelik | Cümle ezber-tekrar testi + renk/şekil dizisini aynı sırayla işaretleme. Model: NASA **Cognition** bataryası |
| **Sosyallik** | İletişim durumu | Partnerle görüntülü konuşma; partner 5 ölçütten puanlar (göz teması, akıcılık, anlama, katılım, genel iletişim). Skor = ortalama × 20 |
| **Hassasiyet (Tepki)** | Dikkat / yorgunluk | Rastgele beliren noktaya tıklama süresi; 5 denemenin ortancası. Kalibrasyon: 350 ms → 100, 1200 ms → 0. Model: **PVT / Reaction Self-Test** |
| **Rapor** | Toplam hazırlık | 4 skor + ağırlıklı toplam, en zayıf alana öneri, günlük göstergeler ve **eğilim grafiği** |
| **Günlük Takip** *(ek)* | Günün göstergeleri | Su sayacı (bardak/ml), öğün işaretleme, uyku saati, ruh hali (1–5), Dünya'ya görev notu |
| **Nefes Egzersizi** *(ek)* | Sakinleşme | Kutu nefesi 4-4-4-4 halka animasyonu; 1/2/3 dakika |

## Çevrimdışı Çalışma ve Kuyruk Sistemi

HELION, bağlantının kopacağını varsayarak tasarlandı (güneş fırtınası senaryosu):

- Kamera modelleri ve tüm kod **uygulama klasörünün içindedir** (`vendor/`, `models/`) —
  çalışma anında internetten hiçbir şey indirilmez.
- Tamamlanan her kayıt **kuyruğa** yazılır (`helionQueue`): test skorları, günlük kayıtlar,
  nefes oturumları, görev notları, çevrimdışı puanlar. Kuyruk, oturum sıfırlamalarından
  etkilenmez.
- Ana ekrandaki **⬇ Raporu İndir** düğmesi bütün veriyi tek JSON dosyası olarak verir —
  bağlantı dönünce "Dünya'ya" gönderilecek dosya budur.
- Rapordaki **eğilim grafiği** kuyruktaki kayıtlardan çizilir; bir skorun günler içindeki
  düşüşü (örn. 82 → 74 → 58) kırmızı işaretlenir.
- **Sosyallik çevrimdışı akışı:** Dünya'daki doktora ulaşılamıyorsa 2. astronot diğerini
  **yüz yüze puanlar** ("📴 Çevrimdışı Puanlama" düğmesi); puan kuyruğa alınır. Ayrıca
  **"📬 Dünya'ya Gönder"** paneli var: **Kendim Hakkında** — astronot üsse yazılı mesaj
  yazar; **Başkası Hakkında** — önce kimin hakkında olduğu sorulur, sonra aynı 5 ölçütlük
  puanlama anahtarı ve ek not alanı açılır. İkisi de kuyruğa girer, bağlantı kurulunca
  Dünya'daki üsse gönderilir.
- **Tek istisna:** canlı görüntülü görüşmenin iki cihazı buluşturan sinyal adımı herkese açık
  bir MQTT sunucusu kullanır ve bağlantı ister. Aynı yerel ağda (örn. istasyon iç ağı) yerel
  bir sinyal sunucusuyla bu adım da internetsiz çalışır; görüşmenin kendisi zaten cihazdan
  cihazadır (WebRTC). Çevrimdışı alternatifler yukarıdadır.

## Veri Modeli (hepsi cihazda, localStorage)

| Anahtar | İçerik |
|---|---|
| `helionResults` | Bölüm skorları ve detayları (fiziksel / hatirlama / sosyallik / tepki) |
| `helionDaily` | Günün günlük-takip kaydı (su, öğünler, uyku, ruh hali, not) |
| `helionQueue` | Kuyruk: zaman damgalı tüm kayıtlar (test, gunluk, nefes, not, sosyallik-puan, mesaj-kendim, sosyallik-puan-baskasi) |

Veriler cihazdan dışarı yalnız kullanıcının indirdiği JSON dosyasıyla çıkar.

## Klasör Yapısı

```
helion-app/
├── index.html                        Ana ekran (test kartları, ek araçlar, kuyruk, export)
├── helion-fiziksel-bolum-v4.html     Bölüm 1 — Fiziksel (kamera doğrulamalı)
├── helion-hatirlama-bolum.html       Bölüm 2 — Hatırlama
├── helion-sosyallik-bolum.html       Bölüm 3 — Sosyallik (görüşme + puanlama + çevrimdışı)
├── helion-sosyallik-puanlayici.html  Puanlayıcının ayrı sayfası
├── helion-hassasiyet-bolum.html      Bölüm 4 — Tepki
├── helion-rapor-bolum.html           Rapor (skorlar, öneri, eğilim)
├── helion-gunluk-takip.html          Ek — Günlük Takip + Görev Notu
├── helion-nefes.html                 Ek — Nefes Egzersizi
├── vendor/                           MediaPipe kütüphanesi (yerel)
│   └── wasm/                         MediaPipe WASM dosyaları (yerel)
├── models/                           pose_landmarker_lite.task, hand_landmarker.task (yerel)
├── Baslat-Ubuntu.sh                  Başlatıcı (Linux)
├── Baslat-Windows.bat                Başlatıcı (Windows)
└── README.md                         Bu dosya
```

## Teknoloji

Düz HTML/CSS/JavaScript — framework yok, derleme yok. MediaPipe Tasks Vision (Pose Landmarker
Lite + Hand Landmarker) **yerel dosyalardan** çalışır. Sosyallik görüşmesi WebRTC ile
cihazdan cihazadır; sinyal için elle yazılmış küçük bir MQTT istemcisi kullanılır
(`wss://broker.emqx.io:8084/mqtt`), puan aktarımı otomatiktir ve kodsuzdur: görüşme bitse bile veri kanalı puan aktarılana kadar açık kalır, aktarım bitince kapanır; astronotun sayfası kapalıysa puan sunucuda bekler, sayfa açılınca kendiliğinden düşer.

## NASA Kaynakları

1. NASA Human Research Program — *The Human Body in Space* (RIDGE çerçevesi)
   https://www.nasa.gov/humans-in-space/the-human-body-in-space
2. NASA Cognition Test Battery (Basner ve ark., NASA HRP Task Book) — Hatırlama modeli
   https://taskbook.nasaprs.com/tbp/tbpdf.cfm?id=356559081DB676F5B2C6B9D01BB07BBB
3. Psychomotor Vigilance Test / Reaction Self-Test on ISS (Dinges, NASA HRP Task Book) — Tepki modeli
   https://taskbook.nasaprs.com/tbp/tbpdf.cfm?id=1EC326EA683537F6CA5DCAA4F042DE02

## Sorun Giderme

- **"Kamera modelleri yüklenemedi" bannerı:** Sayfayı `file://` ile açmışsınız. Başlatıcı
  dosyasıyla / `localhost:8000` üzerinden açın.
- **Kamera açılmıyor:** Tarayıcıda kamera iznini kontrol edin; sayfanın `localhost` üzerinden
  açıldığından emin olun.
- **"Hazırlanıyor…"da takıldı:** Sayfayı yenileyin; modeller bir kez yüklenince hızlanır.
- **Sonuçlar eski görünüyor:** Uygulama her yeni tarayıcı oturumunda test sonuçlarını otomatik
  sıfırlar (kuyruk kayıtları korunur). Ana ekrandaki "Sonuçları Sıfırla" da aynı işi yapar.
- **Puan rapora düşmedi:** Puan, puanlayıcı kaydedince otomatik gider; astronotun Sosyallik
  sayfasını açması yeterlidir (bekleyen puan sayfa açılınca düşer). İki cihazda da internet
  olduğundan ve puanlamanın aynı oda üzerinden yapıldığından emin olun.

## Önemli Notlar

- HELION bir **öz-test ve hazırlık göstergesi** aracıdır; tıbbi tanı koymaz. Düşük skor bir
  sağlık sorunu olduğu anlamına gelmez; düzenli tekrar ve eğilim takibi esastır.
- **Super Intelligence (SI) beyanı:** Ekip, etkinlik boyunca yazılım geliştirme, tasarım ve
  metin taslaklarında yapay zekâ yardımından (Muse) yararlanmıştır. Tüm tasarım kararları,
  testler ve nihai içerik ekibe aittir; sistemin her parçasını ekip üyeleri anlatabilir.

*Sürüm: final (v21 paketi) — 14 Kasım 2026, Ankara.*
