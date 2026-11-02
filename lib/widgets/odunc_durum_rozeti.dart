import 'package:flutter/material.dart';

// Bir kitabın ödünç alınıp alınmadığını şık bir rozetle gösteren tekrar kullanılabilir widget.
// Kendi içinde bir animasyonu veya durumsal hafızası olmadığı için StatelessWidget kullanıyoruz.
class OduncDurumRozeti extends StatelessWidget {

  // Dışarıdan alacağımız TEK BİLGİ: "Bu kitap ödünç alındı mı?" (true veya false)
  final bool oduncAlindiMi;

  // Fabrika (Constructor). Bu rozeti kim çizdirmek istiyorsa, 'oduncAlindiMi' sorusuna
  // kesinlikle (required) cevap vermek zorundadır.
  const OduncDurumRozeti({
    super.key,
    required this.oduncAlindiMi,
  });

  // Rozetin çizim alanı
  @override
  Widget build(BuildContext context) {

    // Container: Flutter'ın İsviçre çakısıdır. İçine her şeyi koyabileceğin,
    // kenarlarını, renklerini, boşluklarını ayarlayabileceğin bir "kutu" oluşturur.
    return Container(

      // Kutunun içindeki metin kenarlara yapışmasın diye içten boşluk (Padding) veriyoruz.
      // Yatayda (sağ-sol) 8, dikeyde (alt-üst) 4 birimlik nefes alanı.
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),

      // BoxDecoration: Kutunun dış görünüşünü (renk, yuvarlaklık, çizgi) makyajladığımız kısım.
      decoration: BoxDecoration(

        // --- RENK MANTIĞI ---
        // "!oduncAlindiMi" -> Türkçesi: "Eğer ödünç alınma durumu DEĞİL ise (yani kitap raftaysa)"
        // (?) İşareti: "Öyle mi? Öyleyse bunu yap:" -> Açık Yeşil (green.shade50)
        // (:) İşareti: "Yok, alınmış. O zaman bunu yap:" -> Açık Turuncu (orange.shade50)
        color: !oduncAlindiMi ? Colors.green.shade50 : Colors.orange.shade50,

        // Kutunun köşelerini 12 birim kavisli (yuvarlak hatlı) yap.
        borderRadius: BorderRadius.circular(12),

        // Kutunun dışına 1 piksel kalınlığında ince bir sınır çizgisi (border) çek.
        border: Border.all(
          // Çizgi rengi: Yine aynı mantık. Raftaysa (false ise) yeşil, alınmışsa (true ise) turuncu çizgi çek.
          color: !oduncAlindiMi ? Colors.green.shade300 : Colors.orange.shade300,
          width: 1, // Çizgi kalınlığı
        ),
      ),

      // Kutunun içine konulacak şey (Text yani Metin)
      child: Text(

        // --- YAZI MANTIĞI ---
        // Yine ünlem işareti ile: "Eğer ödünç alınMADIYSA" -> 'Rafta (Müsait)' yaz
        // Aksi takdirde (alındıysa) -> 'Ödünç Alındı' yaz
        !oduncAlindiMi ? 'Rafta (Müsait)' : 'Ödünç Alındı',

        // Yazının dış görünüşü (Stili)
        style: TextStyle(
          fontSize: 11, // Çok büyük durmaması için 11 punto (Biraz küçük bir font)
          fontWeight: FontWeight.w600, // Yazıyı hafif kalın (bold'a yakın) yap.

          // Yazı rengi: Kutu arka planı açık renkti, yazının okunması için koyu bir renk seçiyoruz.
          // Raftaysa Koyu Yeşil (800), alınmışsa Koyu Turuncu (800).
          color: !oduncAlindiMi ? Colors.green.shade800 : Colors.orange.shade800,
        ),
      ),
    );
  }
}