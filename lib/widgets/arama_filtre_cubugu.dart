import 'package:flutter/material.dart';
import '../models/kitap_kategorisi.dart';

// Sadece ekrana çizim yapan, kendi içinde hafızası olmayan (Stateless) bir widget (görsel parça) oluşturuyoruz.
class AramaFiltreCubugu extends StatelessWidget {

  // Kullanıcı arama kutusuna her harf yazdığında üst katmana haber verecek olan postacı fonksiyon.
  final Function(String) onAramaDegisti;

  // Kullanıcı aşağıdaki kategori butonlarına tıkladığında hangi kategoriye tıklandığını haber verecek fonksiyon.
  final Function(KitapKategorisi) onKategoriSecildi;

  // O an ekranda hangi butonun renkli/seçili olarak durması gerektiğini tutan bilgi.
  final KitapKategorisi seciliKategori;

  // Widget'ın üretim şablonu (Constructor). Bu paneli kullanmak isteyen kişi, bu üç bilgiyi (required) kesinlikle vermek zorundadır.
  const AramaFiltreCubugu({
    super.key, // Widget'ın kimlik numarası (Flutter kendi arka planında kullanır).
    required this.onAramaDegisti,
    required this.onKategoriSecildi,
    required this.seciliKategori,
  });

  // Ekrana şekillerin çizildiği asıl fabrikamız burası.
  @override
  Widget build(BuildContext context) {
    // Ekranda alt alta dizilim yapmak için "Column" (Sütun) kullanıyoruz. (Üstte arama, altta filtreler)
    return Column(
      children: [

        // --- 1. ARAMA KUTUSU BÖLÜMÜ ---

        // Arama kutusuna sağdan-soldan 16, alttan-üstten 8 birim nefes alma boşluğu (Padding) veriyoruz.
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

          // Kullanıcının metin girebildiği arama kutusu
          child: TextField(
            // Kutudaki metin HER değiştiğinde (harf harf), bu metni al ve postacı fonksiyonumuzla haber ver.
            onChanged: onAramaDegisti,

            // Kutunun dış görünüş ayarları
            decoration: InputDecoration(
              // Kutu boşken arkada silik görünen yol gösterici metin
              hintText: 'Kitap veya yazar ara...',
              // Kutunun en sol başına konulan büyüteç ikonu
              prefixIcon: const Icon(Icons.search),
              // Kutunun dış çerçevesi ve köşelerinin ne kadar yuvarlak (30) olacağı
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              // Kutunun içinin renkli olmasını aktifleştiriyoruz
              filled: true,
              // Kutu rengi (Kullanıcının telefon temasına uygun kart rengini otomatik alır)
              fillColor: Theme.of(context).cardColor,
            ),
          ),
        ),

        // --- 2. KATEGORİ BUTONLARI BÖLÜMÜ ---

        // Kaydırılabilir listenin yüksekliğini 50 birim olarak kilitliyoruz ki çok yer kaplamasın.
        SizedBox(
          height: 50,

          // İçindeki eleman sayısına göre kendini çizen dinamik bir liste oluşturuyoruz.
          child: ListView.builder(
            // Listenin aşağı doğru değil, sağa-sola (yatay) kaydırılmasını sağlıyoruz.
            scrollDirection: Axis.horizontal,
            // Listenin iç kısmından sağa ve sola 12 birim boşluk veriyoruz.
            padding: const EdgeInsets.symmetric(horizontal: 12),

            // Listede kaç tane buton olacak? -> Kategorilerimiz kaç taneyse (Hepsi, Roman, Tarih vs. = 5)
            itemCount: KitapKategorisi.values.length,

            // Sırayla (index numarasıyla) butonları çizmeye başlıyoruz.
            itemBuilder: (context, index) {

              // O an çizilmekte olan kategoriyi (Örn: Roman) alıyoruz.
              final kategori = KitapKategorisi.values[index];

              // O an çizilen kategori, kullanıcının seçtiği kategoriyle eşleşiyor mu? (Cevap true veya false)
              final seciliMi = seciliKategori == kategori;

              // Butonlar yan yana yapışmasın diye aralarına 4 birim boşluk koyuyoruz.
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),

                // Seçilip seçilmeme özelliği olan, "hap" tasarımlı hazır Flutter butonu.
                child: ChoiceChip(
                  // Butonun içindeki yazı. (İlk konularda yazdığımız Enum eklentisi 'gorunenAd' sayesinde şık duruyor)
                  label: Text(kategori.gorunenAd),

                  // Buton koyu renk mi (seçili mi) olacak, yoksa soluk mu? (Yukarıdaki seciliMi'ye göre)
                  selected: seciliMi,

                  // Kullanıcı bu butona dokunduğunda çalışacak kod...
                  onSelected: (bool selected) {
                    // Eğer dokunulan buton aktif hale geldiyse...
                    if (selected) {
                      // Hangi kategoriye dokunulduğunu üst katmana (merkeze) haber ver ki ekran güncellensin.
                      onKategoriSecildi(kategori);
                    }
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}