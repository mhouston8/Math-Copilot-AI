import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  static const Color _brandIndigo = Color(0xFF4F46E5);

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
    if (currentValue == null || _firstOperand == null || _operator == null) {
      return;
    }

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

  Widget _buildDisplay(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isError = _display == 'Error';

    return Container(
      width: double.infinity,
      alignment: Alignment.bottomRight,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        _display,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 42,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.6,
          height: 1.1,
          color: isError ? colorScheme.error : colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildKeyboard(BuildContext context) {
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

  @override
  Widget build(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    final colorScheme = Theme.of(context).colorScheme;
    final bottomPad = MediaQuery.paddingOf(context).bottom;

    final content = Padding(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 8 + bottomPad),
      child: Column(
        children: [
          Expanded(child: _buildDisplay(context)),
          const SizedBox(height: 12),
          _buildKeyboard(context),
        ],
      ),
    );

    if (isIOS) {
      return CupertinoTheme(
        data: CupertinoTheme.of(context).copyWith(primaryColor: _brandIndigo),
        child: Scaffold(
          backgroundColor: colorScheme.surface,
          body: CustomScrollView(
            physics: const ClampingScrollPhysics(),
            slivers: [
              const CupertinoSliverNavigationBar(
                heroTag: 'calculator-large-title-nav-bar',
                largeTitle: Text('Calculator'),
              ),
              SliverFillRemaining(
                hasScrollBody: false,
                child: content,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    color: _brandIndigo,
                    tooltip: 'Back',
                  ),
                  Expanded(
                    child: Text(
                      'Calculator',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(child: content),
        ],
      ),
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

  static const List<Color> _gradient = [
    Color(0xFFC83BFF),
    Color(0xFF3F8CFF),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (isOperator) {
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: SizedBox(
            height: 68,
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(16),
                child: Ink(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: _gradient,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x553F8CFF),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      text,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    if (isFunction) {
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: SizedBox(
            height: 68,
            child: Material(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(16),
                child: Center(
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: text == '⌫' ? 22 : 20,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: SizedBox(
          height: 68,
          child: Material(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            elevation: 0,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(16),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.55),
                  ),
                ),
                child: Center(
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
