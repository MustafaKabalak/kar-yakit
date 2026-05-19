Proje Adı: Kâr Yakıt - Akıllı Finans ve Rota Asistanı

Projenin Amacı ve Kullanıcılara Sağladığı Faydalar:
Kâr Yakıt, akaryakıt fiyatlarındaki anlık dalgalanmaları ve güzergah üzerindeki istasyon konumlarını analiz ederek sürücülere en yüksek tasarrufu sağlayan yapay zeka destekli bir mobil asistandır. Kullanıcılar kalkış ve varış noktalarını girdiklerinde, sistem sadece en kısa rotayı çizmekle kalmaz; rota üzerindeki gerçek istasyonları tarar, güncel pompa fiyatlarını karşılaştırır ve "Hangi istasyondan yakıt alınırsa ne kadar kâr edileceğini" net bir finansal tavsiye ile sunar. Kullanıcı, tek bir ekranda hem zamanını hem de bütçesini optimize ederek uzun vadede ciddi bir finansal tasarruf elde eder.

Kullanılan Teknolojiler ve Mimari:
Proje, esnek ve hataya dayanıklı (Fault Tolerant) bir mikroservis mimarisi üzerine inşa edilmiştir.

Frontend (Mobil Arayüz): Çapraz platform desteği ve hızlı kullanıcı deneyimi için Flutter kullanılmıştır.

Backend (Sunucu): Veri işleme, routing ve API yönetimi için Python (Flask) tercih edilmiştir.

Harita ve Konumlandırma: Kullanıcının rotasını çizmek ve fiziksel istasyonları tespit etmek için Google Cloud Maps Platform (Directions API ve Places API) entegre edilmiştir.

Yapay Zeka ve Veri Çekimi: Uygulamanın analitik beyni olarak Google Gemini 2.5 Flash modeli kullanılmıştır. Gemini'ın "Search Grounding" yeteneği ile internetten anlık fiyat verileri kazınmış (Web Scraping), ayrıca sunucu kesintilerine karşı yedekli (fallback) algoritmalar geliştirilmiştir.

Gelecek Vizyonu:
Mevcut mimarimiz, üretim (production) aşamasına geçildiğinde web simülasyonlarından çıkarak doğrudan EPDK (Enerji Piyasası Düzenleme Kurumu) resmi veri tabanına entegre olacak şekilde ölçeklenebilir olarak tasarlanmıştır.
