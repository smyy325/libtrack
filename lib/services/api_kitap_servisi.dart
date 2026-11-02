import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/kitap.dart';
import 'i_kitap_servisi.dart';

class ApiKitapServisi implements IKitapServisi{

  // Open Library API'den 'flutter' konulu kitapları getiren adres
  static const String _baseUrl = 'https://openlibrary.org/search.json?title=flutter&limit=10';
  // Ağ isteğinin en fazla ne kadar süre yanıt bekleyeceğini belirleyen zaman aşımı süresi
  static const Duration _zamanAsimi = Duration(seconds: 8);

  @override
  Future<List<Kitap>> tumKitaplariGetir() async {
    try {
      final uri = Uri.parse(_baseUrl);
      // Sunucuya HTTP GET isteği gönderir ve 8 saniyelik zaman aşımı koruması uygular
      final yanit = await http.get(uri).timeout(_zamanAsimi);

      if(yanit.statusCode == 200){
        // Türkçe karakterleri bozmadan veriyi çöz
        final cozulmusGovde = utf8.decode(yanit.bodyBytes);
        final Map<String, dynamic> jsonHaritasi = jsonDecode(cozulmusGovde);

        // Open Library listeyi 'docs' içinde gönderir
        final List<dynamic> kitapListesi =jsonHaritasi['docs'] ?? [];

        return kitapListesi
            .map((oge) => Kitap.fromJson(oge as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Sunucu Hatası: HTTP ${yanit.statusCode}');
      }
    } catch (hata) {
      // Hatayı UI katmanının yakalayıp ekranda gösterebilmesi için fırlatır
      rethrow;
    }
  }

  @override
  Future<Kitap?> kitapGetirById(String id) async {
    try{
      // 1. Kitabın kendi ID'sini kullanarak Open Library'de spesifik bir arama yapıyoruz.
      // id değeri Open Library'den "/works/OL..." veya "OL...W" formatında gelebilir.
      // API'de bunu sorgulamak için 'q' (genel arama) parametresine id'yi veriyoruz.
      final String detayUrl = 'https://openlibrary.org/search.json?q=$id&limit=1';
      final uri = Uri.parse(detayUrl);

      // 2. Sunucuya 8 saniyelik zaman aşımı (timeout) korumasıyla istek at
      final yanit = await http.get(uri).timeout(_zamanAsimi);

      // 3. İstek başarılı (200 OK) ise
      if(yanit.statusCode==200){
        // Gelen veriyi UTF-8 bozulmalarına karşı koruyarak çöz
        final cozulmusGovde = utf8.decode(yanit.bodyBytes);
        final Map<String, dynamic> jsonHaritasi = jsonDecode(cozulmusGovde);

        // Arama sonucundaki 'docs' listesini al
        final List<dynamic> kitapListesi = jsonHaritasi['docs'] ?? [];

        // 4. Eğer liste boş değilse (Yani o ID'ye ait kitap bulunduysa)
        if(kitapListesi.isNotEmpty){
          // Listenin ilk elemanını al ve bizim fromJson fabrikasına (tercümana) vererek Kitap nesnesine dönüştür
          return Kitap.fromJson(kitapListesi.first as Map<String, dynamic>);
        } else {
          // Liste boşsa (Kitap bulunamadıysa)
          return null;
        }
      } else {
        // Sunucu 500, 404 gibi bir hata kodu dönerse null dön
        return null;
      }
    } catch (hata) {
      // Ağ kopması veya zaman aşımı durumunda ekranın çökmemesi için güvenle null dön
      return null;
    }
  }
}
