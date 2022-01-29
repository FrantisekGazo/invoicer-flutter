import 'package:flutter/foundation.dart';

class SafeValueNotifier<T> extends ValueNotifier<T> {
  SafeValueNotifier(T value) : super(value);

  @override
  void notifyListeners() {
    try {
      super.notifyListeners();
    } catch (_) {
      // can fail if the notifier was disposed
      // because _listeners!.isEmpty is called on null
    }
  }

  @override
  void addListener(void Function() listener) {
    try {
      super.addListener(listener);
    } catch (_) {
      // can fail if the notifier was disposed
      // because _listeners!.isEmpty is called on null
    }
  }

  @override
  void removeListener(void Function() listener) {
    try {
      super.removeListener(listener);
    } catch (_) {
      // can fail if the notifier was disposed
      // because _listeners!.isEmpty is called on null
    }
  }
}

class SafeChangeNotifier extends ChangeNotifier {
  SafeChangeNotifier() : super();

  @override
  void notifyListeners() {
    try {
      super.notifyListeners();
    } catch (_) {
      // can fail if the notifier was disposed
      // because _listeners!.isEmpty is called on null
    }
  }

  @override
  void addListener(void Function() listener) {
    try {
      super.addListener(listener);
    } catch (_) {
      // can fail if the notifier was disposed
      // because _listeners!.isEmpty is called on null
    }
  }

  @override
  void removeListener(void Function() listener) {
    try {
      super.removeListener(listener);
    } catch (_) {
      // can fail if the notifier was disposed
      // because _listeners!.isEmpty is called on null
    }
  }
}

extension ValueListenableExt<T> on ValueListenable<T> {
  ValueNotifier<R> map<R>({
    required R initialValue,
    required ValueMapper<T, R> map,
  }) =>
      MappedValueNotifier<T, R>(
        initialValue: initialValue,
        notifier: this,
        map: map,
      );
}

///
/// Combines multiple [T] values a value of type [R].
///
typedef ValueCombinator<T, R> = R Function(List<T> values);

///
/// Combines multiple [ValueListenable]<T>s to a different [ValueListenable]<R>.
///
class CombinedValueNotifier<T, R> extends SafeChangeNotifier
    implements ValueNotifier<R> {
  final List<ValueListenable<T>> _notifiers = [];
  final ValueCombinator<T, R> _valueCombinator;
  late R _value;

  CombinedValueNotifier({
    Iterable<ValueListenable<T>> notifiers = const [],
    required ValueCombinator<T, R> combinator,
    required R initialValue,
  }) : this._valueCombinator = combinator {
    _value = initialValue;
    _addNotifiers(notifiers);
    _updateValue();
  }

  /// The current value stored in this notifier.
  ///
  /// When the value is replaced with something that is not equal to the old
  /// value as evaluated by the equality operator ==, this class notifies its
  /// listeners.
  @override
  R get value => _value;

  @override
  set value(R newValue) {
    throw UnsupportedError('value cannot be set to CombinedValueNotifier');
  }

  void _setValue(R newValue) {
    if (_value != newValue) {
      _value = newValue;
      notifyListeners();
    }
  }

  void _updateValue() {
    final values = _notifiers.map((notifier) => notifier.value).toList();
    _setValue(_valueCombinator(values));
  }

  void setNotifiers(Iterable<ValueListenable<T>> notifiers) {
    _clearNotifiers();
    _addNotifiers(notifiers);
    _updateValue();
  }

  void _addNotifiers(Iterable<ValueListenable<T>> notifiers) {
    for (final notifier in notifiers) {
      _notifiers.add(notifier);
      notifier.addListener(_updateValue);
    }
  }

  void _clearNotifiers() {
    for (final notifier in _notifiers) {
      notifier.removeListenerIfPossible(_updateValue);
    }
    _notifiers.clear();
  }

  @override
  void dispose() {
    _clearNotifiers();
    super.dispose();
  }
}

///
/// Maps value of type [T] a value of type [R].
///
typedef ValueMapper<T, R> = R Function(T value);

///
/// Maps a [ValueListenable]<T> to a different [ValueListenable]<R>.
///
class MappedValueNotifier<T, R> extends SafeChangeNotifier
    implements ValueNotifier<R> {
  final ValueMapper<T, R> _valueMapper;
  ValueListenable<T>? _notifier;
  late R _value;

  /// Either [initialValue] or [notifier] must be specified.
  MappedValueNotifier({
    required R initialValue,
    ValueListenable<T>? notifier,
    required ValueMapper<T, R> map,
  }) : this._valueMapper = map {
    _value = initialValue;
    if (notifier != null) {
      setNotifier(notifier);
    }
  }

  /// The current value stored in this notifier.
  ///
  /// When the value is replaced with something that is not equal to the old
  /// value as evaluated by the equality operator ==, this class notifies its
  /// listeners.
  @override
  R get value => _value;

  @override
  set value(R newValue) {
    throw UnsupportedError('value cannot be set to MappedValueNotifier');
  }

  void _setValue(R newValue) {
    if (_value != newValue) {
      _value = newValue;
      notifyListeners();
    }
  }

  void _updateValue() {
    final notifier = _notifier;
    if (notifier != null) {
      _setValue(_valueMapper(notifier.value));
    }
  }

  void setNotifier(ValueListenable<T> notifier) {
    _clearNotifier();
    _setNotifier(notifier);
    _updateValue();
  }

  void _setNotifier(ValueListenable<T> notifier) {
    _notifier = notifier;
    notifier.addListener(_updateValue);
  }

  void _clearNotifier() {
    _notifier?.removeListenerIfPossible(_updateValue);
  }

  @override
  void dispose() {
    _clearNotifier();
    super.dispose();
  }
}

///
/// Combines values of type [T1] and [T2] to value of type [R].
///
typedef ValueCombinator2<T1, T2, R> = R Function(T1 value1, T2 value2);

///
/// Combines [ValueListenable]<T1> and [ValueListenable]<T2> into [ValueListenable]<R>.
///
class CombinedValueNotifier2<T1, T2, R> extends SafeChangeNotifier
    implements ValueNotifier<R> {
  ValueListenable<T1>? _notifier1;
  ValueListenable<T2>? _notifier2;
  final ValueCombinator2<T1, T2, R> _valueCombinator;
  late R _value;

  CombinedValueNotifier2({
    required ValueCombinator2<T1, T2, R> combinator,
    ValueListenable<T1>? notifier1,
    ValueListenable<T2>? notifier2,
    required R initialValue,
  }) : this._valueCombinator = combinator {
    _value = initialValue;
    if (notifier1 != null && notifier2 != null) {
      setNotifiers(notifier1, notifier2);
    }
  }

  @override
  R get value => _value;

  @override
  set value(R newValue) {
    throw UnsupportedError('value cannot be set to CombinedValueNotifier2');
  }

  void _setValue(R newValue) {
    if (_value != newValue) {
      _value = newValue;
      notifyListeners();
    }
  }

  void _updateValue() {
    final notifier1 = _notifier1;
    final notifier2 = _notifier2;
    if (notifier1 != null && notifier2 != null) {
      _setValue(_valueCombinator(notifier1.value, notifier2.value));
    }
  }

  void setNotifiers(
    ValueListenable<T1> notifier1,
    ValueListenable<T2> notifier2,
  ) {
    _clearNotifier();
    _setNotifiers(notifier1, notifier2);
    _updateValue();
  }

  void _setNotifiers(
    ValueListenable<T1> notifier1,
    ValueListenable<T2> notifier2,
  ) {
    _notifier1 = notifier1;
    _notifier2 = notifier2;
    notifier1.addListener(_updateValue);
    notifier2.addListener(_updateValue);
  }

  void _clearNotifier() {
    _notifier1?.removeListenerIfPossible(_updateValue);
    _notifier2?.removeListenerIfPossible(_updateValue);
  }

  @override
  void dispose() {
    _clearNotifier();
    super.dispose();
  }
}

///
/// Combines values of type [T1], [T2] and [T3] to value of type [R].
///
typedef ValueCombinator3<T1, T2, T3, R> = R Function(
    T1 value1, T2 value2, T3 value3);

///
/// Combines [ValueListenable]<T1> and [ValueListenable]<T2> and [ValueListenable]<T3> into [ValueListenable]<R>.
///
class CombinedValueNotifier3<T1, T2, T3, R> extends SafeChangeNotifier
    implements ValueNotifier<R> {
  ValueListenable<T1>? _notifier1;
  ValueListenable<T2>? _notifier2;
  ValueListenable<T3>? _notifier3;
  final ValueCombinator3<T1, T2, T3, R> _valueCombinator;
  late R _value;

  CombinedValueNotifier3({
    required ValueCombinator3<T1, T2, T3, R> combinator,
    ValueListenable<T1>? notifier1,
    ValueListenable<T2>? notifier2,
    ValueListenable<T3>? notifier3,
    required R initialValue,
  }) : this._valueCombinator = combinator {
    _value = initialValue;
    if (notifier1 != null && notifier2 != null && notifier3 != null) {
      _setNotifiers(notifier1, notifier2, notifier3);
    }
    _updateValue();
  }

  @override
  R get value => _value;

  @override
  set value(R newValue) {
    throw UnsupportedError('value cannot be set to CombinedValueNotifier3');
  }

  void _setValue(R newValue) {
    if (_value != newValue) {
      _value = newValue;
      notifyListeners();
    }
  }

  void _updateValue() {
    final notifier1 = _notifier1;
    final notifier2 = _notifier2;
    final notifier3 = _notifier3;
    if (notifier1 != null && notifier2 != null && notifier3 != null) {
      _setValue(
        _valueCombinator(notifier1.value, notifier2.value, notifier3.value),
      );
    }
  }

  void setNotifiers(
    ValueListenable<T1> notifier1,
    ValueListenable<T2> notifier2,
    ValueListenable<T3> notifier3,
  ) {
    _clearNotifier();
    _setNotifiers(notifier1, notifier2, notifier3);
    _updateValue();
  }

  void _setNotifiers(
    ValueListenable<T1> notifier1,
    ValueListenable<T2> notifier2,
    ValueListenable<T3> notifier3,
  ) {
    _notifier1 = notifier1;
    _notifier2 = notifier2;
    _notifier3 = notifier3;
    notifier1.addListener(_updateValue);
    notifier2.addListener(_updateValue);
    notifier3.addListener(_updateValue);
  }

  void _clearNotifier() {
    _notifier1?.removeListenerIfPossible(_updateValue);
    _notifier2?.removeListenerIfPossible(_updateValue);
    _notifier3?.removeListenerIfPossible(_updateValue);
  }

  @override
  void dispose() {
    _clearNotifier();
    super.dispose();
  }
}

///
/// Keeps the initial value and does not allow it to be changed.
///
class ImmutableValueNotifier<T> extends ValueNotifier<T> {
  ImmutableValueNotifier(value) : super(value);

  @override
  set value(T val) {
    // do nothing
  }
}

///
/// This class is used to mark that the notifier was created locally
/// and needs to be dismissed when no longer needed.
///
class LocalValueNotifier<T> extends ValueNotifier<T> {
  LocalValueNotifier(T value) : super(value);
}

extension ValueNotifierExtLocal<T> on ValueNotifier<T> {
  void disposeIfLocal() {
    if (this is LocalValueNotifier) {
      this.dispose();
    }
  }
}

extension _ValueListenableRemoveListenerExt<T> on ValueListenable<T> {
  void removeListenerIfPossible(VoidCallback listener) {
    try {
      this.removeListener(listener);
    } catch (e) {
      // this throw an error if notifier was disposed first, which is fine
    }
  }
}
