import 'package:flutter/material.dart';
import '../models/kitap.dart';
import '../models/kitap_kategorisi.dart';

// Kullanıcıdan veri alıp yeni kitap oluşturacağımız ekran.
// Kutulara yazılan yazılar anlık olarak değiştiği ve formun bir 'durumu' olduğu için StatefulWidget kullanıyoruz.
class YeniKitapEkleEkrani extends StatefulWidget {
  const YeniKitapEkleEkrani({super.key});

  @override
  State<YeniKitapEkleEkrani> createState() => _YeniKitapEkleEkraniState();
}

class _YeniKitapEkleEkraniState extends State<YeniKitapEkleEkrani> {
  // --- 1. FORM BİLEŞENLERİ VE HAFIZA ---

  // Formun kurallara uyup uymadığını (boş mu, değil mi?) tek tuşla kontrol etmemizi sağlayan ANAHTAR (Hakem).
  final _formKey = GlobalKey<FormState>();

  // Kullanıcının metin kutularına yazdığı yazıları hafızada tutan ve okumamızı sağlayan kontrolcüler (kamyonlar).
  final _adController = TextEditingController();
  final _yazarController = TextEditingController();
  final _sayfaController = TextEditingController();
  final _ozetController = TextEditingController();
  final _resimController = TextEditingController();

  // Yeni eklenecek kitabın türü. Kullanıcı 'Hepsi' seçemez (yeni kitabın net bir türü olmalı),
  // bu yüzden ekrana ilk girildiğinde varsayılan olarak 'Roman' seçili geliyor.
  KitapKategorisi _seciliKategori = KitapKategorisi.roman;

  // --- 2. KAYDETME İŞLEMİ (Butona Basılınca Çalışır) ---
  void _kitabiKaydet() {
    // Hakeme soruyoruz: "Kullanıcı boş bırakılamaz kurallarını ihlal etmiş mi?" (validate)
    if (_formKey.currentState!.validate()) {

      // Her şey tamamsa (if içine girer), yazılan bilgilerden yepyeni bir Kitap üret (Üretim bandı)
      final yeniKitap = Kitap(
        // Benzersiz ID: O anki zamanı milisaniye cinsinden alıp metne çeviriyoruz (Örn: 1738923481)
        // Böylece aynı isimde iki kitap bile eklense ID'leri farklı olur, karışmaz.
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        kitapAdi: _adController.text.trim(), // trim(): Kazara başa/sona konulan boşlukları temizler
        yazar: _yazarController.text.trim(),

        // Sayfa kutusundaki metni (String), tam sayıya (int) çevirmeyi DENE (tryParse).
        // Eğer adam kazara harf yazdıysa çeviremez, o zaman hata vermesin, varsayılan olarak 0 (sıfır) ata (?? 0).
        sayfaSayisi: int.tryParse(_sayfaController.text.trim()) ?? 0,

        // Kapak görseli kutusu boş bırakıldıysa (?):
        // Rastgele güzel kitap kapakları veren bir servis olan (picsum.photos) linkini ata.
        // Doluysa (:), kullanıcının girdiği resim linkini kullan.
        kapakGorseliUrl: _resimController.text.trim().isEmpty
            ? 'https://picsum.photos/seed/${DateTime.now().millisecondsSinceEpoch}/400/600'
            : _resimController.text.trim(),

        oduncAlindiMi: false, // Yeni kaydedilen bir kitap henüz kimse tarafından alınmamıştır, raftadır.
        kategori: _seciliKategori, // Aşağıdaki açılır menüden (Dropdown) seçilmiş olan güncel kategori
        ozet: _ozetController.text.trim(),
      );

      // Üretilen bu 'yeniKitap' nesnesini kargo paketi gibi al,
      // bu sayfayı kapat (pop) ve bizi bekleyen BİR ÖNCEKİ SAYFAYA (ana sayfaya) teslim et.
      Navigator.pop(context, yeniKitap);
    }
  }

  // --- 3. HAFIZA TEMİZLİĞİ (Çok Önemli) ---
  // Ekran (Widget) kapatılırken / yok edilirken çalışır.
  @override
  void dispose() {
    // Metin kontrolcüleri kendi kendilerine kapanmazlar ve arka planda RAM tüketirler (Hafıza sızıntısı).
    // Ekran kapanırken onları da öldürüyoruz.
    _adController.dispose();
    _yazarController.dispose();
    _sayfaController.dispose();
    _ozetController.dispose();
    _resimController.dispose();
    super.dispose();
  }

  // --- 4. EKRAN TASARIMI ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Kitap Ekle', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),

      // Form: İçindeki tüm TextField'ları 'formKey' ile birbirine bağlayıp topluca kontrol etmemizi sağlayan çatı.
      body: Form(
        key: _formKey,

        // Klavye açıldığında ekranın altında kalan kutulara erişebilmek (kaydırmak) için.
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Sayfanın en altındaki kod kalabalığı önleyen özel şablonumuzu çağırıyoruz
              _buildMetinKutusu(
                kontrolcu: _adController,
                etiket: 'Kitap Adı',
                ikon: Icons.book,
                hataMesaji: 'Lütfen kitap adını girin.',
              ),
              const SizedBox(height: 16),

              _buildMetinKutusu(
                kontrolcu: _yazarController,
                etiket: 'Yazar Adı',
                ikon: Icons.person,
                hataMesaji: 'Lütfen yazar adını girin.',
              ),
              const SizedBox(height: 16),

              // Sayfa Sayısı kutusu ile Kategori (Açılır Menü) kutusunu YAN YANA diziyoruz (Row)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sol Kısım (1 Birim Genişlikte): Sayfa Sayısı
                  Expanded(
                    flex: 1, // Ekranı oranla (1 parça buna)
                    child: _buildMetinKutusu(
                      kontrolcu: _sayfaController,
                      etiket: 'Sayfa',
                      ikon: Icons.pages,
                      klavyeTipi: TextInputType.number, // Sadece rakam klavyesi açılsın
                      hataMesaji: 'Gerekli',
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Sağ Kısım (2 Birim Genişlikte - Daha uzun): Kategori Menüsü
                  Expanded(
                    flex: 2, // Ekranı oranla (2 parça buna)
                    child: DropdownButtonFormField<KitapKategorisi>(
                      value: _seciliKategori, // Ekranda şu an görünen değer
                      decoration: InputDecoration(
                        labelText: 'Kategori',
                        prefixIcon: const Icon(Icons.category),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Theme.of(context).cardColor,
                      ),

                      // items: Seçeneklerin listesi
                      // KitapKategorisi enum'undaki değerleri al, 'Hepsi' olanı filtrele (where ile çıkar),
                      // kalanları açılır menü (DropdownMenuItem) satırlarına çevir (map).
                      items: KitapKategorisi.values
                          .where((k) => k != KitapKategorisi.hepsi)
                          .map((kategori) {
                        return DropdownMenuItem(
                          value: kategori,
                          child: Text(kategori.gorunenAd),
                        );
                      }).toList(),

                      // Kullanıcı yeni bir seçenek seçtiğinde
                      onChanged: (yeniDeger) {
                        if (yeniDeger != null) {
                          setState(() { // Ekranı yeni kategoriye göre güncelle
                            _seciliKategori = yeniDeger;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              _buildMetinKutusu(
                kontrolcu: _resimController,
                etiket: 'Kapak Görseli URL',
                ikon: Icons.image,
                klavyeTipi: TextInputType.url,
                zorunluMu: true,
              ),
              const SizedBox(height: 16),

              _buildMetinKutusu(
                kontrolcu: _ozetController,
                etiket: 'Kitap Özeti',
                ikon: Icons.description,
                satirSayisi: 4, // Yüksekliği artır, 4 satırlık büyük bir metin kutusu yap
                hataMesaji: 'Lütfen özet girin.',
              ),
              const SizedBox(height: 32),

              // --- KAYDET BUTONU ---
              SizedBox(
                width: double.infinity, // Buton ekranı yatayda tamamen kaplasın
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: _kitabiKaydet, // Tıklanınca yukarıdaki kaydetme ve hakem fonksiyonuna git
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  icon: const Icon(Icons.save),
                  label: const Text('Kitabı Kaydet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // --- 5. ÖZEL TASARIM ŞABLONU (Kod Tekrarını Önlemek İçin) ---
  // Yukarıda 5 kere aynı metin kutusu kodunu (renk, çizgi, yuvarlaklık vb.) yazmak yerine,
  // bu şablonu bir kere yazıp, yukarıdan sadece değişen kısımlarını (isim, ikon vb.) parametre olarak yolluyoruz.
  Widget _buildMetinKutusu({
    required TextEditingController kontrolcu, // Hangi hafıza kamyonuna bağlanacak?
    required String etiket, // Kutu boşken ne yazacak? (Örn: 'Kitap Adı')
    required IconData ikon, // Kutunun solundaki simge
    TextInputType klavyeTipi = TextInputType.text, // Varsayılan normal klavye
    int satirSayisi = 1, // Varsayılan 1 satır
    bool zorunluMu = true, // Kutu boş bırakılabilir mi? (Varsayılan: Hayır)
    String? hataMesaji,
  }) {
    return TextFormField(
      controller: kontrolcu,
      keyboardType: klavyeTipi,
      maxLines: satirSayisi,

      // validator: Kaydet butonuna basıldığında FormKey tarafından çağrılan DOĞRULAYICI (Hakem)
      validator: zorunluMu
          ? (deger) { // Kutu ZORUNLU İSE:
        // Kutunun içindeki değer yoksa veya boşluklar silindiğinde geriye hiçbir şey kalmıyorsa (boşsa):
        if (deger == null || deger.trim().isEmpty) {
          return hataMesaji ?? 'Bu alan zorunludur.'; // Kutunun altını kırmızı çizip bu hatayı yaz.
        }
        // Geriye 'null' dönmesi, "Hata yok, her şey kurallara uygun" demektir.
        return null;
      }
          : null, // Kutu ZORUNLU DEĞİLSE, hakemi hiç çalıştırma (null ver).

      // Kutunun makyajı (Renk, köşe kavisleri vs.)
      decoration: InputDecoration(
        labelText: etiket,
        prefixIcon: Icon(ikon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), // 12 kavisli köşeler
        filled: true, // Arka planı boya
        fillColor: Theme.of(context).cardColor, // Koyu temaya uygun renk
      ),
    );
  }
}