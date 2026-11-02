import '../models/kitap.dart';

// Kitap servisi işlemlerini tanımlayan soyut sözleşme (interface) sınıfı
abstract class IKitapServisi{
  // Tüm kitapların listesini asenkron olarak sunucudan veya bellekten getiren metot
  Future<List<Kitap>> tumKitaplariGetir();

  // Belirli bir ID'ye (veya key'e) sahip tek bir kitabı asenkron olarak getiren metot
  Future<Kitap?> kitapGetirById(String id);
}