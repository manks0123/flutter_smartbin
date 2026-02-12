import 'dart:math';

class MockAIService {
  static final _random = Random();

  static String predict() {
    final results = ['Plastic', 'Paper', 'Metal', 'Organic'];
    return results[_random.nextInt(results.length)];
  }
}
