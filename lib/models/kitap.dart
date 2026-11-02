import 'kitap_kategorisi.dart';

class Kitap{ //class (Sınıf): Bir şablondur. Bilgisayara "Benim uygulamamda Kitap diye bir kavram var, içinde de bu özellikler bulunur" dersin.
  final String id; //final (Kesin/Son): Güvenlik mührüdür. "Bu kitaba bir kez isim, yazar veya sayfa sayısı verildiğinde, bu değerler bir daha asla kazara değiştirilemesin" demektir.
  final String kitapAdi;
  final String yazar;
  final int sayfaSayisi;
  final String ozet;
  final String kapakGorseliUrl;
  final bool oduncAlindiMi;
  final KitapKategorisi kategori;

  //yeni bir Kitap oluşturmak istediğinde bu metot çalışır.
  const Kitap({
    required this.id, //required (Zorunlu): Bilgisayara "Bana bir Kitap nesnesi üreteceksen, bu bilgileri eksiksiz vermek ZORUNDASIN, boş geçemezsin" der.
    required this.kitapAdi,
    required this.yazar,
    required this.sayfaSayisi,
    required this.ozet,
    required this.kapakGorseliUrl,
    required this.oduncAlindiMi,
    required this.kategori,
});

  //İnternetten (API) gelen veriler genelde JSON formatındadır. Yani {"title": "Yüzüklerin Efendisi", "pages": 1000} gibi bir metin yığınıdır. Bilgisayar bunun bir "Kitap" olduğunu anlamaz.
  //factory (Fabrika): Normal kurucudan farkı şudur: İçeride biraz matematik, biraz hesap kitap yapıp, en sonunda sana hazır bir Kitap nesnesi teslim eder.
  //Map<String, dynamic> json: Gelen kargo paketidir. String etiketi (örneğin "title"), dynamic ise içindeki veriyi (isim, sayı, liste vb.) temsil eder.

  factory Kitap.fromJson(Map<String, dynamic> json){
    final coverId =json['cover_i']; //JSON paketinin içinden 'cover_i' (kapak ID'si) bilgisini alıyoruz.
    final String resimUrl = coverId != null //(Eğer ID boş gelmediyse) -> Açık kütüphanenin web adresinin sonuna $coverId ekleyerek tam bir resim linki oluştur.
      ? 'https://covers.openlibrary.org/b/id/$coverId-M.jpg'
      : ''; //(Eğer ID boş geldiyse) -> Uygulama çökmesin diye resim linkini boş bir metin ('') olarak kaydet.

    final yazarlar = json['author_name'] as List<dynamic>?; //JSON'dan 'author_name' (yazar isimleri) listesini çekiyoruz. Kitabın birden fazla yazarı olabileceği için API bunu bize bir Liste olarak gönderiyor.
    final String ilkYazar =(yazarlar != null && yazarlar.isNotEmpty) //"Eğer yazar listesi boş (null) değilse VE içinde gerçekten bir eleman varsa..."
      ? yazarlar.first.toString() //"...bu listenin sadece ilk elemanını (first) al ve metne çevir."
      : 'Bilinmeyen Yazar'; //"Eğer liste boş geldiyse, ekranda çirkin bir hata görünmesin, varsayılan olarak 'Bilinmeyen Yazar' yaz."

    final ilkCumle = json['first_sentence'] as List<dynamic>?;
    final String kitapOzeti =(ilkCumle != null && ilkCumle.isNotEmpty)
      ? ilkCumle.first.toString()
      : 'Bu kitap için henüz bir özet bulunmuyor.';

    final konular = json['subject'] as List<dynamic>?; //Bu listenin sadece ilk konusunu yakalayıp metin olarak (gelenTurMetni) kenara ayırmak. Bunu az sonra bizim akıllı Enum kalkanımıza göndereceğiz. (Küçük bir not: 1. satırda as List<dynamic>; yerine sonuna soru işareti koyarak as List<dynamic>?; yazmak daha güvenlidir, çünkü alt satırda konular != null diyerek null olup olmadığını kontrol ediyoruz).
    final String gelenTurMetni = (konular != null && konular.isNotEmpty)
      ? konular.first.toString()
      : '';

    return Kitap(
      id: json['key']?.toString() ?? '',
      kitapAdi: json['title'] as String? ?? 'İsimsiz Kitap',
      yazar: ilkYazar,
      sayfaSayisi: (json['number_of_pages_median'] as num?)?.toInt() ?? 249,
      ozet: kitapOzeti,
      kapakGorseliUrl: resimUrl,
      oduncAlindiMi: false, //İnternetten yeni aratılıp bulunmuş bir kitap, bizim kütüphanemizde henüz ödünç alınmamış demektir. Bu yüzden durumu doğrudan false (Hayır) olarak başlatıyoruz.
      kategori:KitapKategorisiExtension.apiMetnindenUret(gelenTurMetni),

    );
  }

  Kitap copyWith({ //copyWith (Bununla Kopyala) fonksiyonu bu kilidi kırmadan, kitabın bilgilerini güncellememizi sağlayan zekice bir fotokopi makinesidir.
    String? id,
    String? kitapAdi,
    String? yazar,
    int? sayfaSayisi,
    String? ozet,
    String? kapakGorseliUrl,
    bool? oduncAlindiMi,
    KitapKategorisi? kategori,
    //Bu değer verilmeyebilir, boş (null) bırakılabilir" demektir. Yani bu makineye bir kitap gönderdiğinde, sadece değiştirmek istediğin özellikleri yazarsın.
  }) {
    return Kitap( //Makine çalıştıktan sonra dışarıya yepyeni, sıfır kilometre bir Kitap nesnesi veriyoruz. Eskisini değiştirmiyoruz, onun kopyasını üretiyoruz.
      id: id ?? this.id,
      kitapAdi: kitapAdi ?? this.kitapAdi,
      yazar: yazar ?? this.yazar,
      sayfaSayisi: sayfaSayisi ?? this.sayfaSayisi,
      ozet: ozet ?? this.ozet,
      kapakGorseliUrl: kapakGorseliUrl ?? this.kapakGorseliUrl,
      oduncAlindiMi: oduncAlindiMi ?? this.oduncAlindiMi,
      kategori: kategori ?? this.kategori,
      // Eğer bana yeni bir değer verildiyse onu kullan, verilmediyse eski (mevcut) değeri aynen koru.
    );
  }
}