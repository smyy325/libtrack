import 'package:flutter/material.dart';
import '../models/kitap.dart';
import '../models/kitap_kategorisi.dart';
import '../services/i_kitap_servisi.dart';
import '../services/api_kitap_servisi.dart';
import '../widgets/kitap_karti.dart';
import '../widgets/arama_filtre_cubugu.dart';
import 'kitap_detay_ekrani.dart';
import '../services/mock_kitap_servisi.dart';
import 'yeni_kitap_ekle_ekrani.dart';

// Uygulamanın ana ekranı. İnternetten veri çekip, listeyi süzüp (arama)
// ekranda göstereceği için, yani 'Hafızası / Durumu' sürekli değişeceği için StatefulWidget kullanıyoruz.
class KitapListesiEkrani extends StatefulWidget {
  const KitapListesiEkrani({super.key});

  @override
  State<KitapListesiEkrani> createState() => _KitapListesiEkraniState();
}

class _KitapListesiEkraniState extends State<KitapListesiEkrani> {


  // --- 1. VERİ KAYNAĞI SEÇİMİ (Dependency Injection - Bağımlılık Enjeksiyonu) ---
  // Uygulama internete bağlanıp gerçek API'yi mi kullanacak,
  // yoksa internetsiz çalışıp sahte (mock) kitapları mı gösterecek?
  // Sadece başındaki yorum satırını (//) kaldırarak tüm uygulamanın motorunu değiştirebilirsin.
  final IKitapServisi _kitapServisi = MockKitapServisi(); // Şu an sahte veri kullanılıyor
  //final IKitapServisi _kitapServisi = ApiKitapServisi(); // Gerçek internet API'si (şimdi pasif)

  // --- 2. DEĞİŞKENLER (State) ---

  // _tumKitaplar: İnternetten gelen 100 kitabın hepsini tuttuğumuz ANA DEPO.
  List<Kitap> _tumKitaplar = [];

  // _gosterilenKitaplar: Arama yapıldığında veya kategori seçildiğinde ekranda
  // gösterilecek 5-10 kitabı tuttuğumuz VİTRİN.
  List<Kitap> _gosterilenKitaplar = [];

  // İnternetten veri çekilirken dönecek olan o yuvarlak yükleme animasyonunu (true/false) yönetir.
  bool _yukleniyorMu = true;

  // Eğer internet kesilirse ekranda gösterilecek hata metni.
  String _hataMesaji = '';

  // O an ekranda hangi kategorinin/filtrelemenin aktif olduğu (Varsayılan: Tümü)
  KitapKategorisi _seciliKategori = KitapKategorisi.hepsi;

  // Kullanıcının arama kutusuna yazdığı harfler (Örn: "Yüzük")
  String _aramaMetni = '';

  // --- 3. SAYFA İLK AÇILDIĞINDA ÇALIŞACAK MOTOR ---
  @override
  void initState() {
    super.initState();
    // Sayfa açılır açılmaz gidip internetten / sahte servisten kitapları çekmeye başla.
    _verileriGetir();
  }

  // --- 4. VERİ ÇEKME İŞLEMİ (Asenkron Metot) ---
  // Future ve async: "Bu işlem (internetten indirme) biraz sürecek, sen diğer işlerine bak,
  // bitince ben sana haber vereceğim (await)" demektir. Uygulamayı dondurmaz.
  Future<void> _verileriGetir() async {
    setState(() {
      _yukleniyorMu = true; // Yükleme animasyonunu başlat
      _hataMesaji = ''; // Varsa eski hata mesajlarını temizle
    });

    try {
      // Servise "Bana kitapları getir" diyoruz ve gelene kadar (await) bekliyoruz.
      final gelenKitaplar = await _kitapServisi.tumKitaplariGetir();

      setState(() {
        _tumKitaplar = gelenKitaplar; // Ana depoyu doldur
        _gosterilenKitaplar = gelenKitaplar; // Vitrini de ana depoyla aynı yap (ilk başta hepsi görünür)
        _yukleniyorMu = false; // Yükleme bitti, yuvarlak animasyonu durdur
      });
    } catch (e) {
      // Eğer kablo koparsa, internet yoksa (hata fırlatılırsa) buraya düşer
      setState(() {
        _hataMesaji = e.toString(); // Gelen hatayı ekrana yazdıracağız
        _yukleniyorMu = false; // Yüklemeyi durdur
      });
    }
  }

  // --- 5. ARAMA VE FİLTRELEME MOTORU ---
  // Kullanıcı her harf yazdığında veya kategori seçtiğinde bu motor çalışır.
  void _listeyiGuncelle() {
    setState(() {

      // ADIM 1: Önce kategoriyi kontrol et (Tarih, Roman vs. seçilmiş mi?)
      // Eğer "Hepsi" seçiliyse ana deponun hepsini al. Değilse sadece o kategoriye uyanları (where) çek.
      var filtrelenmisListe = _seciliKategori == KitapKategorisi.hepsi
          ? _tumKitaplar
          : _tumKitaplar.where((k) => k.kategori == _seciliKategori).toList();

      // ADIM 2: Sonra arama kutusunu kontrol et (Kutuda bir şey yazıyor mu?)
      if (_aramaMetni.trim().isNotEmpty) {
        // Büyük/küçük harf duyarlılığını kaldırmak için aranan metni küçük harfe çevir.
        final aranan = _aramaMetni.toLowerCase();

        // Yukarıda kategoriden süzülmüş listeyi BİR KEZ DAHA arama metnine göre süz (where)
        filtrelenmisListe = filtrelenmisListe.where((kitap) {
          final adUyarMi = kitap.kitapAdi.toLowerCase().contains(aranan);
          final yazarUyarMi = kitap.yazar.toLowerCase().contains(aranan);
          // Kitap adında VEYA (||) yazar adında geçiyorsa bunu listeye dahil et.
          return adUyarMi || yazarUyarMi;
        }).toList();
      }

      // Süzme işlemi bitti, temizlenmiş listeyi vitrine koy ve ekranı yenile.
      _gosterilenKitaplar = filtrelenmisListe;
    });
  }

  // --- 6. TASARIM / EKRAN ÇİZİMİ (build) ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Sayfanın en üstündeki başlık çubuğu
      appBar: AppBar(
        title: const Text('LIBTRACK', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            // Başlığın sağına şık bir kitap logosu ekliyoruz
            child: Icon(Icons.auto_stories, color: Colors.indigo.shade300),
          ),
        ],
      ),
      body: Column(
        children: [
          // Sayfanın en üstünde, daha önce kodladığımız 'AramaFiltreCubugu' widget'ı duruyor.
          AramaFiltreCubugu(
            seciliKategori: _seciliKategori,

            // Eğer kutuya yazı yazılırsa, bu fonksiyon tetiklenir,
            // biz de yeni harfi _aramaMetni'ne atayıp yukarıdaki motoru (_listeyiGuncelle) çalıştırırız.
            onAramaDegisti: (metin) {
              _aramaMetni = metin;
              _listeyiGuncelle();
            },

            // Aynı şekilde kategori butonuna tıklanırsa bu tetiklenir, motor çalışır.
            onKategoriSecildi: (kategori) {
              _seciliKategori = kategori;
              _listeyiGuncelle();
            },
          ),

          // Arama çubuğunun altında kalan TÜM boş alanı ana listeye (vitrine) tahsis et (Expanded).
          Expanded(
            child: _anaIcerigiOlustur(), // Liste tasarımını kod kalabalığı olmasın diye aşağıya ayırdık.
          ),
        ],
      ),

      // --- 7. YENİ KİTAP EKLEME BUTONU (Floating Action Button) ---
      // Ekranın sağ alt köşesinde havada duran artı (+) butonu
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.indigo.shade600,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        onPressed: () async {

          // Navigator.push ve "await": Kullanıcıyı "Yeni Ekle" sayfasına gönder ve
          // oradan GELECEK OLAN (await) paketi (yeni kitabı) bekle.
          final yeniKitap = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const YeniKitapEkleEkrani(),
            ),
          );

          // Kullanıcı form sayfasından "Geri/İptal" yapıp dönmüş olabilir (veri null olur).
          // Eğer gerçekten elinde bir Kitap nesnesiyle (dolu) döndüyse:
          if (yeniKitap != null && yeniKitap is Kitap) {
            setState(() {
              // Ana deponun en başına (index 0) bu yepyeni kitabı ekle.
              _tumKitaplar.insert(0, yeniKitap);
              // Listeyi tekrar süzgeçten geçirip güncel vitrini oluştur.
              _listeyiGuncelle();
            });

            // Ekranın altından yeşil renkli "Başarıyla eklendi!" mesajı çıkar.
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${yeniKitap.kitapAdi} başarıyla eklendi!'),
                backgroundColor: Colors.green.shade700,
              ),
            );
          }
        },
      ),
    );
  }

  // --- 8. VİTRİNİN ÇİZİLDİĞİ YER (Ana İçerik Widget'ı) ---
  Widget _anaIcerigiOlustur() {
    // 1. DURUM: Veri internetten çekiliyorsa (yukleniyorMu == true)
    if (_yukleniyorMu) {
      return const Center(child: CircularProgressIndicator()); // Dönen animasyon göster.
    }

    // 2. DURUM: İnternet yoksa veya çekerken hata çıktıysa (hataMesaji doluysa)
    if (_hataMesaji.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: Colors.redAccent), // Kırmızı hata ikonu
              const SizedBox(height: 16),
              Text(
                'Bağlantı Kurulamadı:\n$_hataMesaji', // Hatayı yazdır
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              // Kullanıcı interneti açtıysa tekrar denemesi için buton koy.
              // Basınca en yukarıdaki _verileriGetir tekrar çalışır.
              ElevatedButton.icon(
                onPressed: _verileriGetir,
                icon: const Icon(Icons.refresh),
                label: const Text('Tekrar Dene'),
              ),
            ],
          ),
        ),
      );
    }

    // 3. DURUM: Arama yaptık ama saçma sapan bir şey yazdık, liste boş kaldı.
    if (_gosterilenKitaplar.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 60, color: Colors.grey.shade600),
            const SizedBox(height: 16),
            Text(
              'Aradığınız kritere uygun kitap bulunamadı.',
              style: TextStyle(color: Colors.grey.shade400, fontSize: 16),
            ),
          ],
        ),
      );
    }

    // 4. DURUM: Her şey harika! Vitrinde kitaplar var, listeyi çizebiliriz.
    return ListView.builder(
      // Listenin en altındaki kitap, sağ alttaki yuvarlak "Ekle" butonunun (FAB)
      // arkasında kalıp görünmez olmasın diye alttan 80 piksel ekstra boşluk bırakıyoruz.
      padding: const EdgeInsets.only(bottom: 80),

      // Listede kaç eleman olacak? Vitrindeki eleman sayısı kadar.
      itemCount: _gosterilenKitaplar.length,

      itemBuilder: (context, index) {
        final oAnkiKitap = _gosterilenKitaplar[index];

        // Daha önce yazdığımız o şık "KitapKarti" widget'ına kitabı verip ekrana çizdiriyoruz.
        return KitapKarti(
          kitap: oAnkiKitap,

          // Karta Tıklanınca Ne Olacak? (onTap)
          onTap: () {
            // Navigator.push: Tıklanan kitabın Detay Sayfasına git (üzerine aç)
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => KitapDetayEkrani(
                  kitap: oAnkiKitap,

                  // Detay sayfasında kullanıcı "Ödünç Al/İade Et" yaparsa (veri değişirse),
                  // Detay sayfası bu kablodan o yeni halini (yeniGuncelKitap) bize yollayacak.
                  onKitapGuncellendi: (yeniGuncelKitap) {
                    setState(() {
                      // Bize gelen kitabın ID'sini, ana depomuzdaki (_tumKitaplar) kitaplar arasında arıyoruz.
                      final guncellenecekIndex = _tumKitaplar.indexWhere((k) => k.id == yeniGuncelKitap.id);

                      // Eğer kitabı depoda bulduysak (index -1 değilse), depodaki eski kitabı çöpe at,
                      // detay sayfasından gelen YENİ (ödünç alınmış/bırakılmış) kitabı o sıraya koy.
                      if (guncellenecekIndex != -1) {
                        _tumKitaplar[guncellenecekIndex] = yeniGuncelKitap;
                      }

                      // Depoyu güncelledik, şimdi vitrini (arama vs varsa) tekrar toparlamak için motoru çalıştırıyoruz.
                      _listeyiGuncelle();
                    });
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}