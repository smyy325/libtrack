import 'package:flutter/material.dart';
import '../models/kitap.dart';
import '../models/kitap_kategorisi.dart';
import '../widgets/odunc_durum_rozeti.dart';

// Kitap detaylarını ve ödünç alma/iade etme işlemlerini yöneten ekran.
// İçindeki veriler (ödünç durumu vb.) değişebileceği için StatefulWidget kullanıyoruz.
class KitapDetayEkrani extends StatefulWidget {
  // Önceki ekrandan (listeden) gelen seçili kitap bilgisi
  final Kitap kitap;
  // Bu ekranda kitapta bir değişiklik olursa, ana sayfaya bunu bildirmek için kullanılan haberleşme fonksiyonu
  final Function(Kitap) onKitapGuncellendi;

  const KitapDetayEkrani({
    super.key,
    required this.kitap,
    required this.onKitapGuncellendi,
  });

  @override
  State<KitapDetayEkrani> createState() => _KitapDetayEkraniState();
}

class _KitapDetayEkraniState extends State<KitapDetayEkrani> {
  // Ekranda gösterilecek ve üzerinde değişiklik yapılacak güncel kitap nesnesi.
  // 'late' kelimesi, "bunun içini initState içinde dolduracağım, şimdilik güven bana" demektir.
  late Kitap _guncelKitap;

  @override
  void initState() {
    super.initState();
    // Sayfa ilk yüklendiğinde, dışarıdan (widget.kitap) gelen kitabı yerel değişkene kopyalıyoruz
    // ki üzerinde rahatça değişiklik yapabilelim.
    _guncelKitap = widget.kitap;
  }

  // --- ASIL İŞLEMİ YAPAN METOT (Ödünç Alma veya İade Etme) ---
  void _oduncDurumunuDegistir() {
    // setState: İçindeki veri değiştiğinde ekrana "Kendini yeni veriye göre tekrar çiz!" komutunu verir.
    setState(() {
      // Daha önce yazdığımız 'copyWith' (kopyalama makinesi) sayesinde, kitabın diğer tüm
      // özelliklerini sabit tutup, sadece 'oduncAlindiMi' durumunu tersine çeviriyoruz (Ternary mantığı).
      _guncelKitap = _guncelKitap.copyWith(
        oduncAlindiMi: !_guncelKitap.oduncAlindiMi,
      );
    });

    // Haberleşme kablosu aracılığıyla, değişen bu yepyeni kitap nesnesini ana sayfaya (listeye) yolluyoruz.
    widget.onKitapGuncellendi(_guncelKitap);

    // Kullanıcıya işlemin başarılı olduğuna dair ekranın altından çıkan küçük bir siyah/renkli bildirim (SnackBar) gösteriyoruz.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _guncelKitap.oduncAlindiMi
              ? '${_guncelKitap.kitapAdi} ödünç alındı!' // Eğer yeni durum 'true' ise bu mesaj
              : '${_guncelKitap.kitapAdi} rafa geri kondu.', // 'false' ise bu mesaj
        ),
        // SnackBar'ın arka plan rengini de duruma göre (Turuncu/Yeşil) ayarlıyoruz.
        backgroundColor: _guncelKitap.oduncAlindiMi ? Colors.orange.shade700 : Colors.green.shade700,
        duration: const Duration(seconds: 2), // Ekranda kalma süresi
      ),
    );
  }

  // --- MD DOSYASINDA İSTENEN MODAL BOTTOM SHEET (Aşağıdan Açılan Onay Penceresi) ---
  // Kullanıcı butona bastığında doğrudan işlemi yapmak yerine bu pencereyi açıp onay istiyoruz.
  void _altPencereyiGoster() {
    showModalBottomSheet(
      context: context,
      // Pencerenin sadece üst (top) köşelerini kavisli (yuvarlak) yaparak şık bir görünüm elde ediyoruz.
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            // Sadece içindeki butonlar ve yazılar kadar yer kaplasın, ekranı boydan boya doldurmasın.
            mainAxisSize: MainAxisSize.min,
            children: [
              // Üstte görünen küçük yatay çekme çizgisi (Tamamen tasarım amaçlı)
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade600,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const Text(
                'İşlem Onayı',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              // Duruma göre değişen onay sorusu (Ternary mantığı ile "ödünç almak" veya "iade etmek" yazıyor)
              Text(
                '${_guncelKitap.kitapAdi} isimli kitabı ${_guncelKitap.oduncAlindiMi ? 'iade etmek' : 'ödünç almak'} istediğinize emin misiniz?',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 32),

              // Yan yana duran İptal ve Onay butonları
              Row(
                children: [
                  // İPTAL BUTONU
                  Expanded(
                    child: OutlinedButton(
                      // Navigator.pop(context): Sadece bu açılan alt pencereyi kapatır, sayfada kalır.
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('İptal', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // ONAY BUTONU
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Kullanıcı onaylarsa: Önce alt pencereyi ekrandan kaldır.
                        Navigator.pop(context);
                        // Hemen ardından yukarıda yazdığımız asıl işlem motorunu çalıştır.
                        _oduncDurumunuDegistir();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _guncelKitap.oduncAlindiMi ? Colors.orange.shade700 : Colors.indigo.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Evet, Onayla', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10), // Alt çentik/klavye boşluğu için
            ],
          ),
        );
      },
    );
  }

  // --- SAYFANIN GENEL GÖRÜNÜMÜ (Tasarım Alanı) ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Sayfanın üst çubuğu
      appBar: AppBar(
        title: const Text('Kitap Detayı', style: TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      // Sayfa içindeki metin çok uzun olursa taşmayı engellemek için kaydırılabilir alan (ScrollView)
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center, // Her şeyi ortala
          children: [
            // --- KİTAP KAPAK GÖRSELİ VE ANİMASYON ---
            // Ana sayfadaki resmin büyüterek buraya uçmasını sağlayan Hero animasyonu
            Hero(
              tag: 'kitap_resim_${_guncelKitap.id}', // Ana sayfadaki tag ile AYNISI olmalı
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16), // Resmin köşelerini yuvarlat
                child: Image.network(
                  _guncelKitap.kapakGorseliUrl,
                  height: 280,
                  fit: BoxFit.cover,
                  // İnternet yoksa veya resim bozuksa gösterilecek gri yedek alan
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 280, width: 180, color: Colors.grey.shade800,
                    child: const Icon(Icons.menu_book, size: 60, color: Colors.grey),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // --- KİTAP VE YAZAR BİLGİLERİ ---
            Text(_guncelKitap.kitapAdi, textAlign: TextAlign.center, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(_guncelKitap.yazar, textAlign: TextAlign.center, style: TextStyle(fontSize: 18, color: Colors.grey.shade400, fontStyle: FontStyle.italic)),
            const SizedBox(height: 24),

            // --- YAN YANA BİLGİ KUTUCUKLARI (Kategori, Sayfa Sayısı, Durum) ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Eşit aralıklarla dağıt
              children: [
                // En aşağıda oluşturduğumuz küçük yardımcı widget (_bilgiKutusu) ile tasarımı temizliyoruz.
                _bilgiKutusu(ikon: Icons.category, baslik: 'Kategori', deger: _guncelKitap.kategori.gorunenAd),
                _bilgiKutusu(ikon: Icons.pages, baslik: 'Sayfa', deger: '${_guncelKitap.sayfaSayisi}'),
                // Üçüncü kutucuğa ise kendi özel 'OduncDurumRozeti' widget'ımızı koyuyoruz.
                Column(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.grey),
                    const SizedBox(height: 8),
                    OduncDurumRozeti(oduncAlindiMi: _guncelKitap.oduncAlindiMi),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),

            // --- KİTAP ÖZETİ BÖLÜMÜ ---
            const Align(alignment: Alignment.centerLeft, child: Text('Kitap Hakkında', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
            const SizedBox(height: 12),
            Align(alignment: Alignment.centerLeft, child: Text(_guncelKitap.ozet, style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.white70))),
            const SizedBox(height: 40),

            // --- EN ALTTAKİ İŞLEM BUTONU ---
            SizedBox(
              width: double.infinity, // Butonun ekranı yatayda tamamen kaplamasını sağlar
              height: 55,
              child: ElevatedButton.icon(
                // DİKKAT: Butona basıldığında doğrudan işlemi YAPIYORUZ, onun yerine onay için ALT PENCEREYİ açıyoruz.
                onPressed: _altPencereyiGoster,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade800,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                icon: const Icon(Icons.touch_app),
                label: const Text(
                  'İşlem Yap (Ödünç/İade)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 20), // Sayfanın en altıyla buton arasında boşluk
          ],
        ),
      ),
    );
  }

  // Tasarım kodunu kalabalıktan kurtarmak için oluşturulmuş özel bir yardımcı fonksiyon.
  // Kategori ve sayfa sayısı kutucuklarının görselini çizer.
  Widget _bilgiKutusu({required IconData ikon, required String baslik, required String deger}) {
    return Column(
      children: [
        Icon(ikon, color: Colors.grey),
        const SizedBox(height: 8),
        Text(baslik, style: TextStyle(fontSize: 12, color: Colors.grey.shade400)),
        const SizedBox(height: 4),
        Text(deger, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }
}