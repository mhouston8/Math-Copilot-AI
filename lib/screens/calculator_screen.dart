import 'package:flutter/material.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _display = '0';
  double? _firstOperand;
  String? _operator;
  bool _shouldResetDisplay = false;

  void _onDigitTap(String digit) {
    setState(() {
      if (_shouldResetDisplay) {
        _display = digit;
        _shouldResetDisplay = false;
        return;
      }

      if (_display == '0') {
        _display = digit;
      } else {
        _display += digit;
      }
    });
  }

  void _onDecimalTap() {
    setState(() {
      if (_shouldResetDisplay) {
        _display = '0.';
        _shouldResetDisplay = false;
        return;
      }

      if (!_display.contains('.')) {
        _display += '.';
      }
    });
  }

  void _onClearTap() {
    setState(() {
      _display = '0';
      _firstOperand = null;
      _operator = null;
      _shouldResetDisplay = false;
    });
  }

  void _onBackspaceTap() {
    setState(() {
      if (_shouldResetDisplay) {
        _display = '0';
        _shouldResetDisplay = false;
        return;
      }

      if (_display.length <= 1) {
        _display = '0';
      } else {
        _display = _display.substring(0, _display.length - 1);
      }
    });
  }

  void _onSignToggleTap() {
    setState(() {
      if (_display == '0') return;
      _display = _display.startsWith('-')
          ? _display.substring(1)
          : '-$_display';
    });
  }

  void _onPercentTap() {
    final value = double.tryParse(_display);
    if (value == null) return;

    setState(() {
      _display = _formatNumber(value / 100);
    });
  }

  void _onOperatorTap(String nextOperator) {
    final currentValue = double.tryParse(_display);
    if (currentValue == null) return;

    setState(() {
      if (_firstOperand == null) {
        _firstOperand = currentValue;
      } else if (_operator != null && !_shouldResetDisplay) {
        final result = _calculate(_firstOperand!, currentValue, _operator!);
        if (result == null) {
          _display = 'Error';
          _firstOperand = null;
          _operator = null;
          _shouldResetDisplay = true;
          return;
        }
        _firstOperand = result;
        _display = _formatNumber(result);
      }

      _operator = nextOperator;
      _shouldResetDisplay = true;
    });
  }

  void _onEqualsTap() {
    final currentValue = double.tryParse(_display);
    if (currentValue == null || _firstOperand == null || _operator == null) return;

    final result = _calculate(_firstOperand!, currentValue, _operator!);

    setState(() {
      if (result == null) {
        _display = 'Error';
      } else {
        _display = _formatNumber(result);
      }
      _firstOperand = null;
      _operator = null;
      _shouldResetDisplay = true;
    });
  }

  double? _calculate(double a, double b, String op) {
    switch (op) {
      case '+':
        return a + b;
      case '-':
        return a - b;
      case '×':
        return a * b;
      case '÷':
        if (b == 0) return null;
        return a / b;
      default:
        return null;
    }
  }

  String _formatNumber(double value) {
    final text = value.toStringAsFixed(12);
    return text
        .replaceFirst(RegExp(r'\.?0+$'), '')
        .replaceAll('-0', '0');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculator'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                alignment: Alignment.bottomRight,
                padding: const EdgeInsets.all(16),
                child: Text(
                  _display,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            _buildKeyboard(),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyboard() {
    return Column(
      children: [
        Row(
          children: [
            _CalcButton(text: 'AC', onTap: _onClearTap, isFunction: true),
            _CalcButton(text: '+/-', onTap: _onSignToggleTap, isFunction: true),
            _CalcButton(text: '%', onTap: _onPercentTap, isFunction: true),
            _CalcButton(
              text: '÷',
              onTap: () => _onOperatorTap('÷'),
              isOperator: true,
            ),
          ],
        ),
        Row(
          children: [
            _CalcButton(text: '7', onTap: () => _onDigitTap('7')),
            _CalcButton(text: '8', onTap: () => _onDigitTap('8')),
            _CalcButton(text: '9', onTap: () => _onDigitTap('9')),
            _CalcButton(
              text: '×',
              onTap: () => _onOperatorTap('×'),
              isOperator: true,
            ),
          ],
        ),
        Row(
          children: [
            _CalcButton(text: '4', onTap: () => _onDigitTap('4')),
            _CalcButton(text: '5', onTap: () => _onDigitTap('5')),
            _CalcButton(text: '6', onTap: () => _onDigitTap('6')),
            _CalcButton(
              text: '-',
              onTap: () => _onOperatorTap('-'),
              isOperator: true,
            ),
          ],
        ),
        Row(
          children: [
            _CalcButton(text: '1', onTap: () => _onDigitTap('1')),
            _CalcButton(text: '2', onTap: () => _onDigitTap('2')),
            _CalcButton(text: '3', onTap: () => _onDigitTap('3')),
            _CalcButton(
              text: '+',
              onTap: () => _onOperatorTap('+'),
              isOperator: true,
            ),
          ],
        ),
        Row(
          children: [
            _CalcButton(text: '0', onTap: () => _onDigitTap('0')),
            _CalcButton(text: '.', onTap: _onDecimalTap),
            _CalcButton(
              text: '⌫',
              onTap: _onBackspaceTap,
              isFunction: true,
            ),
            _CalcButton(text: '=', onTap: _onEqualsTap, isOperator: true),
          ],
        ),
      ],
    );
  }
}

class _CalcButton extends StatelessWidget {
  const _CalcButton({
    required this.text,
    required this.onTap,
    this.isOperator = false,
    this.isFunction = false,
  });

  final String text;
  final VoidCallback onTap;
  final bool isOperator;
  final bool isFunction;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    Color background;
    Color foreground;

    if (isOperator) {
      background = colorScheme.primary;
      foreground = colorScheme.onPrimary;
    } else if (isFunction) {
      background = colorScheme.surfaceContainerHighest;
      foreground = colorScheme.onSurface;
    } else {
      background = colorScheme.surface;
      foreground = colorScheme.onSurface;
    }

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: SizedBox(
          height: 68,
          child: FilledButton(
            onPressed: onTap,
            style: FilledButton.styleFrom(
              backgroundColor: background,
              foregroundColor: foreground,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
