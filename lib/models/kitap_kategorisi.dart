// enum: "Bir kitabın türü sadece bu dördünden biri olabilir. Başka hiçbir kelimeyi kabul etme." Bu sayede birisi yanlışlıkla Yazlım yazdığında sistem çökmez, çünkü en baştan izin vermiyoruz.

//enumlara: extension (eklenti) kullanarak bu düz kelimelere yetenekler kazandırıyoruz

enum KitapKategorisi {
  hepsi,
  yazilim,
  roman,
  tarih,
  siir,
}

extension KitapKategorisiExtension on KitapKategorisi{ //"Ben bir eklenti hazırladım ve bu eklenti sadece KitapKategorisi üzerinde (on) çalışacak." Başka bir enum veya sınıf bu özellikleri kullanamaz.
  String get gorunenAd{ //get: Bu bir fonksiyondur ama parantez aç-kapa yapmadan sanki bir değişkenmiş gibi (kategori.gorunenAd) kullanılmasını sağlar.
    switch(this){ //this: "O anki seçili kategori" demektir.
      // switch: Bilgisayara "Şimdi sana bir veri vereceğim, bu verinin ne olduğuna bak ve uygun yola gir" demektir.
      case KitapKategorisi.hepsi: //case: switch bir karar merkeziyse, case o merkeze gelen seçeneklerdir.
        return "Tümü";
      case KitapKategorisi.yazilim:
        return "Yazılım";
      case KitapKategorisi.roman:
        return "Roman";
      case KitapKategorisi.tarih:
        return "Tarih";
      case KitapKategorisi.siir:
        return "Şiir";
        //return: Bir fonksiyonun (fabrikadaki bir makine gibi düşün) işini bitirip çıktıyı sana teslim ettiği andır. return kelimesini gören kod, "İşim bitti, cevabı buldum, artık aşağıdaki satırları okumama gerek yok" der ve o anki bloğu terk eder.
    }
  }

  static KitapKategorisi apiMetnindenUret(String apiMetni){ //elimizde henüz bir kategori yok. Kategori üretmek için bu fonksiyonu sınıfın kendisine sorarak çağırırız
    switch(apiMetni.toLowerCase().trim()){ //.toLowerCase(): gelen karmaşık bir metni önce tamamen küçük harfe çevirir. .trim(): metnin sağındaki solundaki boşlukları budar
      case "yazilim":
      case "programming":
      case "computers":
        return KitapKategorisi.yazilim;
      case "roman":
      case "fiction":
      case "novel":
        return KitapKategorisi.roman;
      case "tarih":
      case "history":
        return KitapKategorisi.tarih;
      case "siir":
      case "poetry":
        return KitapKategorisi.siir;
        default:
          return KitapKategorisi.yazilim; // default: Beklenmeyen veya boş veri gelirse devreye giren güvenli varsayılan durum

    }
  }
}