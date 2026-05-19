import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const KarYakitApp());
}

class KarYakitApp extends StatelessWidget {
  const KarYakitApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kâr Yakıt',
      theme: ThemeData(primarySwatch: Colors.indigo, useMaterial3: true),
      home: const HaritaAnalizEkrani(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HaritaAnalizEkrani extends StatefulWidget {
  const HaritaAnalizEkrani({Key? key}) : super(key: key);

  @override
  State<HaritaAnalizEkrani> createState() => _HaritaAnalizEkraniState();
}

class _HaritaAnalizEkraniState extends State<HaritaAnalizEkrani> {
  late GoogleMapController _mapController;

  final TextEditingController _kalkisController = TextEditingController();
  final TextEditingController _varisController = TextEditingController();
  final TextEditingController _litreController = TextEditingController(text: "50");

  bool _isLoading = false;
  String _agentComment = "Analiz başlatılmadı. Şehir ve litre girip butona basın.";
  List<dynamic> _stations = [];
  Set<Marker> _markers = {};
  String _encodedPolyline = "";

  final CameraPosition _initialCameraPosition = const CameraPosition(
    target: LatLng(39.0, 35.0), zoom: 5.0,
  );

  Future<void> _analyzeFuelPrices() async {
    if (_litreController.text.isEmpty || _kalkisController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _agentComment = "Kâr Yakıt Ajanı gerçek istasyonları buluyor ve anlık fiyatları kazıyor...";
      _encodedPolyline = "";
    });

    try {
      final url = Uri.parse('http://10.0.2.2:5000/api/karsilastir');
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json; charset=UTF-8",
          "Accept-Charset": "utf-8"},
        body: jsonEncode({
          'kalkis': _kalkisController.text,
          'varis': _varisController.text,
          'litre': _litreController.text,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> stationData = data['istasyonlar'];
        final double merkezLat = data['merkez_lat'];
        final double merkezLng = data['merkez_lng'];

        Set<Marker> newMarkers = {};
        for (var station in stationData) {
          final bool isBest = station['tasarruf_text'] == "En Ekonomik Seçim";
          newMarkers.add(
            Marker(
              markerId: MarkerId(station['id']),
              position: LatLng(station['lat'], station['lng']),
              infoWindow: InfoWindow(
                title: station['marka'], // Artık gerçek istasyon adı yazacak
                snippet: "${station['litre_fiyati_text']} | Toplam: ${station['toplam_maliyet_text']}",
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                isBest ? BitmapDescriptor.hueGreen : BitmapDescriptor.hueOrange,
              ),
            ),
          );
        }

        setState(() {
          _stations = stationData;
          _markers = newMarkers;
          _agentComment = data['agent_tavsiyesi'];
          _encodedPolyline = data['polyline'] ?? "";
        });

        _mapController.animateCamera(CameraUpdate.newLatLngZoom(LatLng(merkezLat, merkezLng), 10.0));
      }
    } catch (e) {
      setState(() {
        _agentComment = "Bağlantı Hatası: Python sunucusu çalışıyor mu? \n$e";
      });
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kâr Yakıt - Akıllı Asistan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.indigo,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: TextField(controller: _kalkisController, decoration: InputDecoration(labelText: 'Kalkış (Örn: Konya)', prefixIcon: const Icon(Icons.location_on, color: Colors.indigo), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), contentPadding: const EdgeInsets.symmetric(vertical: 0)))),
                    const SizedBox(width: 8),
                    Expanded(child: TextField(controller: _varisController, decoration: InputDecoration(labelText: 'Varış (Örn: Ankara)', prefixIcon: const Icon(Icons.flag, color: Colors.green), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), contentPadding: const EdgeInsets.symmetric(vertical: 0)))),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(flex: 2, child: TextField(controller: _litreController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Litre', prefixIcon: const Icon(Icons.local_gas_station), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), contentPadding: const EdgeInsets.symmetric(vertical: 0)))),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 3,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _analyzeFuelPrices,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                        child: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Canlı Analiz Et', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: _initialCameraPosition,
                  onMapCreated: (controller) => _mapController = controller,
                  markers: _markers,
                  zoomControlsEnabled: true,
                  myLocationEnabled: false,
                  polylines: _encodedPolyline.isEmpty
                      ? {}
                      : {
                    Polyline(
                      polylineId: const PolylineId("rota_cizgisi"),
                      points: _decodePolyline(_encodedPolyline),
                      color: Colors.blueAccent,
                      width: 6,
                    ),
                  },
                ),
                if (_isLoading) const Center(child: CircularProgressIndicator()),
              ],
            ),
          ),
          Container(
            width: double.infinity, margin: const EdgeInsets.all(10), padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.indigo.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.indigo.shade200, width: 2)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(children: [Icon(Icons.auto_awesome, color: Colors.indigo, size: 20), SizedBox(width: 8), Text("Kâr Yakıt AI Ajanı", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo))]),
                const SizedBox(height: 4),
                Text(_agentComment, style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic)),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: ListView.builder(
              itemCount: _stations.length,
              itemBuilder: (context, index) {
                final station = _stations[index];
                final bool isBest = station['tasarruf_text'] == "En Ekonomik Seçim";
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), color: isBest ? Colors.green.shade50 : Colors.white,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    leading: CircleAvatar(backgroundColor: isBest ? Colors.green : Colors.grey, child: const Icon(Icons.local_gas_station, color: Colors.white, size: 20)),
                    // YENİ EKLENEN KISIM: Uzun isimler taşmasın diye maxLines eklendi
                    title: Text(
                      station['marka'],
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text("Litre: ${station['litre_fiyati_text']} | Toplam: ${station['toplam_maliyet_text']}", style: const TextStyle(fontSize: 12)),
                    trailing: Text(station['tasarruf_text'], style: TextStyle(color: isBest ? Colors.green : Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

