import 'package:flutter/material.dart';
import '../models/kitap.dart';
import '../models/kitap_kategorisi.dart';
import 'odunc_durum_rozeti.dart';

// Kitap bilgilerini şık bir kartta gösteren, kendi içinde durumu değişmeyen (Stateless) widget
class KitapKarti extends StatelessWidget {

  // Bu kartın içine hangi kitabın verilerini yerleştireceğimizi tutan değişken
  final Kitap kitap;

  // Kullanıcı bu karta dokunduğunda (tıkladığında) ne olacağını belirten fonksiyon.
  // "VoidCallback?" demek, "geriye değer döndürmeyen (void) bir fonksiyon (callback).
  // Ve sonundaki soru işareti (?) nedeniyle bu karta tıklama özelliği verilmeyebilir (null olabilir)" demektir.
  final VoidCallback? onTap;

  // Fabrika (Constructor). Bu kartı çizmek için 'kitap' bilgisini vermek ZORUNLUDUR (required).
  const KitapKarti({
    super.key,
    required this.kitap,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Card: Flutter'ın kendinden gölgeli, köşeleri yuvarlak, arka planlı standart kart tasarımı.
    return Card(
      // Kartın dışından sağ-sol 16, alt-üst 8 birim mesafe (margin) bırak. (Kartlar birbirine yapışmasın)
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      // Kartın havada duruyor hissi vermesi için 4 birimlik alt gölge (elevation) ekle.
      elevation: 4,
      // Kartın köşelerini 16 birim yuvarlak (kavisli) yap.
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      // Kartın içindeki resim/yazı eğer kartın dışına taşarsa (kavisli köşelerden), taşan kısmı kes at (antiAlias).
      clipBehavior: Clip.antiAlias,

      // InkWell: Karta dokunulduğunda Android'deki o meşhur "su dalgası" (ripple) efektini veren widget.
      child: InkWell(
        // Dokunulduğunda yukarıda tanımladığımız onTap fonksiyonunu çalıştır.
        onTap: onTap,

        // Kartın içindeki her şeye 12 birim boşluk (Padding) ver ki yazılar kenarlara yapışmasın.
        child: Padding(
          padding: const EdgeInsets.all(12),

          // Row (Satır): Kartın içini yatayda yan yana diziyoruz. (Sol taraf resim, sağ taraf yazılar)
          child: Row(
            // Satırın içindeki elemanları yukarıdan hizala (CrossAxisAlignment.start).
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // --- SOL TARAF: KİTAP KAPAK GÖRSELİ ---

              // Hero: Uygulamada çok havalı bir animasyondur. Bu karta tıkladığında detay sayfasına giderken
              // resmin büyüyerek diğer sayfaya uçmasını sağlar.
              Hero(
                // Bu resmin kimlik numarası. Hangi kitabın uçacağını bilmesi için benzersiz bir isim veriyoruz.
                tag: 'kitap_resim_${kitap.id}',

                // ClipRRect: İçindeki resmi, verdiğimiz oranda (12) köşelerinden kırparak yuvarlatır.
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),

                  // SizedBox: Resmin genişliğini 80, yüksekliğini 110 olarak kilitliyoruz.
                  child: SizedBox(
                    width: 80,
                    height: 110, // Kitap kapakları genelde diktörgendir

                    // İnternetten (URL üzerinden) resmi çek ve çiz.
                    child: Image.network(
                      kitap.kapakGorseliUrl,
                      // Resmi kutunun içine, oranını bozmadan ama boşluk bırakmadan sığdır.
                      fit: BoxFit.cover,

                      // loadingBuilder: Resim internetten inerken (birkaç saniye sürebilir) ekranda ne görünecek?
                      loadingBuilder: (context, child, loadingProgress) {
                        // Eğer yükleme bitmişse (null), artık resmi (child) göster.
                        if (loadingProgress == null) return child;
                        // Yükleme devam ediyorsa ekranın ortasında dönen bir yuvarlak (CircularProgressIndicator) göster.
                        return const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        );
                      },

                      // errorBuilder: Eğer internet kopuksa veya resim linki kırıksa uygulama ÇÖKMESİN, ne gösterelim?
                      errorBuilder: (context, error, stackTrace) {
                        // Gri arka planlı, ortasında kitap ikonu olan yedek (fallback) bir kutu çiziyoruz.
                        return Container(
                          color: Colors.grey.shade800, // Karanlık temaya uygun
                          child: const Icon(Icons.menu_book, color: Colors.grey),
                        );
                      },
                    ),
                  ),
                ),
              ),

              // Resim ile sağdaki yazılar arasına 12 birim boşluk koy.
              const SizedBox(width: 12),

              // --- SAĞ TARAF: METİN BİLGİLERİ ---

              // Expanded: Sağ taraftaki yazıların, kalan tüm boşluğu (ekranın sonuna kadar) doldurmasını sağlar.
              // Eğer yazılar çok uzun olursa ekranın dışına taşıp hata vermesini engeller.
              Expanded(
                // Column (Sütun): Sağ taraftaki yazıları alt alta (Kategori, Kitap Adı, Yazar) diziyoruz.
                child: Column(
                  // Yazıları sola dayalı (start) hizala.
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // --- ÜST SATIR: Kategori Adı ve Ödünç Rozeti ---
                    Row(
                      // Kategori ismini en sola, rozeti en sağa it. (Aralarını aç)
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [

                        // Kategori adı (Yine bizim güvenli enum yapısından geliyor: Örn "Bilim Kurgu")
                        Text(
                          kitap.kategori.gorunenAd,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade400,
                          ),
                        ),

                        // Kendi tasarladığımız diğer widget. Sadece "kitap ödünç alındı mı?" (true/false) bilgisini veriyoruz,
                        // o yeşil "Rafta" veya kırmızı "Alındı" butonunu kendi çiziyor.
                        OduncDurumRozeti(oduncAlindiMi: kitap.oduncAlindiMi),
                      ],
                    ),

                    // Satır arasına biraz boşluk
                    const SizedBox(height: 8),

                    // --- KİTAP ADI ---
                    Text(
                      kitap.kitapAdi,
                      // Kitap adı çok uzunsa bile en fazla 2 satır yer kaplasın.
                      maxLines: 2,
                      // Eğer 2 satırdan da uzunsa cümlenin sonuna üç nokta (...) koy (ellipsis).
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold, // Yazıyı kalın yap.
                      ),
                    ),
                    const SizedBox(height: 6),

                    // --- YAZAR ADI ---
                    Text(
                      kitap.yazar,
                      // Yazar adı en fazla 1 satır olsun.
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis, // Sığmazsa sonuna üç nokta (...) koy.
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade300, // Biraz daha soluk gri (odak kitap adında kalsın).
                      ),
                    ),
                    const SizedBox(height: 8),

                    // --- ALT KISIM: Sayfa Sayısı İkonu ve Metni ---
                    // Sadece sayfa sayısını yazmak yerine ikonla beraber şık bir Row (satır) yapıyoruz.
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Sayfa veya belge ikonu (description_outlined), mavi renkli.
                        const Icon(Icons.description_outlined, size: 16, color: Colors.blueAccent),
                        // İkonla yazı arası küçük boşluk.
                        const SizedBox(width: 4),
                        // Örn: "249 Sayfa"
                        Text(
                          '${kitap.sayfaSayisi} Sayfa',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.blueAccent, // İkonla aynı mavi renkte.
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}