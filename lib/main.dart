import 'package:flutter/material.dart';
// Az önce yazdığımız ana liste ekranını içe aktarıyoruz
import 'screens/kitap_listesi_ekrani.dart';

void main() {
  // Uygulamanın çalışmasını başlatan ana tetikleyici
  runApp(const KutuphaneUygulamasi());
}

class KutuphaneUygulamasi extends StatelessWidget {
  const KutuphaneUygulamasi({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Uygulamanın arka plandaki (işletim sistemindeki) adı
      title: 'LibTrack',
      // Sağ üst köşedeki o çirkin kırmızı 'DEBUG' şeridini kaldırır
      debugShowCheckedModeBanner: false,

      // Kendi tasarım zevkine tam uyan Material Design 3 Karanlık Teması
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        // Projedeki mavi/indigo detaylar (fiyat, butonlar) için ana vurgu rengi
        colorSchemeSeed: Colors.indigo,
      ),

      // Uygulama açıldığında kullanıcının göreceği ilk ekran (Ana Sayfa)
      home: const KitapListesiEkrani(),
    );
  }
}