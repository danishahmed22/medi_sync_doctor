import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:medisync_doctor/features/auth_onboarding/presentation/providers/auth_provider.dart';

/// Provider that manages a local cache of frequently used medicines.
final medicineSuggestionsProvider = StateNotifierProvider<MedicineIntelligenceNotifier, List<String>>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return MedicineIntelligenceNotifier(prefs);
});

class MedicineIntelligenceNotifier extends StateNotifier<List<String>> {
  MedicineIntelligenceNotifier(this._prefs) : super([]) {
    _loadSuggestions();
  }

  final SharedPreferences _prefs;
  static const String _key = 'medisync_medicine_freq';

  void _loadSuggestions() {
    final raw = _prefs.getString(_key);
    if (raw != null) {
      final List<dynamic> list = jsonDecode(raw);
      state = list.cast<String>();
    } else {
      // Default initial suggestions for medical context
      state = ['Paracetamol', 'Amoxicillin', 'Cetirizine', 'Ibuprofen', 'Pantoprazole'];
    }
  }

  /// Adds a medicine to the frequent list (keeps top 20).
  void trackMedicineUsage(String name) {
    if (name.isEmpty) return;
    
    final current = List<String>.from(state);
    if (current.contains(name)) {
      current.remove(name);
    }
    current.insert(0, name); // Move to top
    
    if (current.length > 20) current.removeLast();
    
    state = current;
    _prefs.setString(_key, jsonEncode(current));
  }
}
