# akilli-yakit-asistani
## Projenin Amacı
YakıtCüzdanı, bireysel sürücülerin ve KOBİ'lerin seyahatleri sırasındaki akaryakıt giderlerini optimize eden, yapay zeka destekli bir kişisel finans asistanıdır. Sadece yakıt fiyatlarını listelemekle kalmaz; hedef rotanız üzerindeki güncel istasyon fiyatlarını ve aracınızın yakıt tüketimini analiz ederek bütçeniz için **en kârlı alım noktasını** hesaplar.

## Agentik Yapay Zeka (Gemini API) Entegrasyonu
Bu projenin karar mekanizması **Google Gemini API** kullanılarak agentik bir yapıda kurgulanmıştır. Sistem, web üzerinden çekilen anlık fiyat verilerini ve kullanıcı rotasını harmanlayarak bir "Finansal Ajan" gibi davranır:
- Güzergah üzerindeki istasyonların fiyat farklarını hesaplar.
- "X istasyonundan almak sana toplamda 45 TL tasarruf sağlar" gibi nokta atışı bütçe tavsiyeleri verir.
- Kullanıcının aylık yakıt harcamalarını analiz ederek tasarruf içgörüleri sunar.

## Kullanılan Teknolojiler
* **Yapay Zeka:** Google Gemini 1.5 API (Akıl yürütme ve agentik karar motoru)
* **Veri Toplama (Scraping):** Python (Güncel akaryakıt fiyatlarının anlık çekilmesi)
* **Uygulama Mimarisi:** Flutter
