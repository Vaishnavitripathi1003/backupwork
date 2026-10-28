enum SubscriptionLevel {
  level1('subcription1'),
  level2('subcription2'),
  level3('subcription3');

  final String value;
  const SubscriptionLevel(this.value);

  static SubscriptionLevel? fromValue(String? value) {
    if (value == null) return null;
    for (final level in SubscriptionLevel.values) {
      if (level.value == value) return level;
    }
    return null;
  }
}
