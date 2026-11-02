import 'package:libtrack/models/kitap_kategorisi.dart';

import '../models/kitap.dart';
import 'i_kitap_servisi.dart';

class MockKitapServisi implements IKitapServisi{
  final List<Kitap> _kitapDeposu = const [
    Kitap(
        id: "1",
        kitapAdi: 'Flutter ile Mobil Geliştirme',
        yazar: 'Cihan Ürtekin',
        sayfaSayisi: 350,
        ozet: 'Flutter ve Dart kullanarak baştan sona profesyonel mobil uygulamalar geliştirme rehberi.',
        kapakGorseliUrl: 'https://cdn.seckin.com.tr/f/seckin/kitap/347635484587634/9789750294167.jpg',
        oduncAlindiMi: false,
        kategori: KitapKategorisi.yazilim),
    Kitap(
        id: "2",
        kitapAdi: 'Suç ve Ceza',
        yazar: 'Fyodor Dostoyevski',
        sayfaSayisi: 672,
        ozet: 'Fakir bir gencin, vicdanı ve toplum kuralları arasında verdiği amansız psikolojik savaş.',
        kapakGorseliUrl: 'https://www.iskultur.com.tr/dosyalar/2006/11/suc-ve-ceza-5.jpg',
        oduncAlindiMi: true,
        kategori: KitapKategorisi.roman),
    Kitap(
        id: "3",
        kitapAdi: 'Sapiens',
        yazar: 'Yuval Noah Harari',
        sayfaSayisi: 400,
        ozet: 'İnsan türünün ortaya çıkışından bugünkü teknolojik devrime kadar uzanan kısa bir tarihi.',
        kapakGorseliUrl: 'https://m.media-amazon.com/images/I/713jIoMO3UL.jpg',
        oduncAlindiMi: false,
        kategori: KitapKategorisi.tarih),
    Kitap(
        id: "4",
        kitapAdi: 'Lavinia - Aşk Şiirleri',
        yazar: 'Özdemir Asaf',
        sayfaSayisi: 80,
        ozet: "İki kişi arasında yaşanabilecek en özel duyguları anlatan dizeleri okumak ister misiniz? O hâlde Türk şiirinin önemli örneklerini kaleme alan Özdemir Asaf'ın pek çok aşk şiirini bulabileceğiniz Lavinia - Aşk Şiirleri sizi bekliyor. Asaf'ın özgün ve yalın ifadeleri tekrar tekrar okumak isteyeceğiniz bir kitaba dönüşüyor. Gelin, duygularınıza tercüman olan ve bilmediğiniz aşkları anlatan bu eserde sizleri nelerin beklediğinden kısaca bahsedelim.",
        kapakGorseliUrl: 'https://img.kitapyurdu.com/v1/getImage/fn:1012150/wi:800/wh:1658eca12',
        oduncAlindiMi: true,
        kategori: KitapKategorisi.siir),
  ];

  @override
  Future<List<Kitap>> tumKitaplariGetir() async{
    // Sanki internetten geliyormuş gibi 1.5 saniye (1500 ms) bekletme simülasyonu
    await Future.delayed(const Duration(milliseconds: 1500));
    return List.from(_kitapDeposu);
  }

  @override
  Future<Kitap?> kitapGetirById(String id) async{
    // Sanki sunucuda arıyormuş gibi yarım saniye bekle
    await Future.delayed(const Duration(milliseconds: 500));

    // Verilen ID'ye sahip kitabı depoda bulmaya çalış, bulamazsan null dön.
    try{
      return _kitapDeposu.firstWhere((kitap)=> kitap.id == id);
    } catch (e){
      return null; //Eğer aranan kitap listede yoksa firstWhere hata fırlatır, biz de null döneriz.
    }
  }
}