import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Conversor de Divisas',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ConversorScreen(),
    );
  }
}

class ConversorScreen extends StatefulWidget {
  const ConversorScreen({super.key});

  @override
  State<ConversorScreen> createState() => _ConversorScreenState();
}

class _ConversorScreenState extends State<ConversorScreen> {
  String monedaOrigen = 'USD';
  String monedaDestino = 'CNY';
  String montoOrigen = '140.00';
  String montoDestino = '1014.902';

  void _intercambiarMonedas() {
    setState(() {
      final tempMoneda = monedaOrigen;
      final tempMonto = montoOrigen;
      monedaOrigen = monedaDestino;
      montoOrigen = montoDestino;
      monedaDestino = tempMoneda;
      montoDestino = tempMonto;
    });
  }

  void _agregarNumero(String numero) {
    setState(() {
      if (montoOrigen == '140.00' || montoOrigen == '0') {
        montoOrigen = numero;
      } else {
        montoOrigen += numero;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            // Header con hora y estados
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '9:41',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.signal_cellular_4_bar, color: Colors.grey[600], size: 16),
                  const SizedBox(width: 4),
                  Icon(Icons.wifi, color: Colors.grey[600], size: 16),
                  const SizedBox(width: 4),
                  Icon(Icons.battery_full, color: Colors.grey[600], size: 16),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Información superior
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Between Accounts',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'No commission',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Tarjeta de origen
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildMoneyCard(
                monto: montoOrigen,
                balance: '\$150.56',
                moneda: monedaOrigen,
                bandera: _getFlagEmoji(monedaOrigen),
              ),
            ),
            const SizedBox(height: 16),
            // Botón de intercambio
            Center(
              child: GestureDetector(
                onTap: _intercambiarMonedas,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.swap_vert,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Tarjeta de destino
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildMoneyCard(
                monto: montoDestino,
                balance: '¥246.63',
                moneda: monedaDestino,
                bandera: _getFlagEmoji(monedaDestino),
              ),
            ),
            const SizedBox(height: 24),
            // Teclado numérico
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: _buildNumericKeyboard(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoneyCard({
    required String monto,
    required String balance,
    required String moneda,
    required String bandera,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Selector de moneda
          Row(
            children: [
              Text(
                bandera,
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 8),
              Text(
                moneda,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.expand_more,
                color: Colors.grey[600],
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Monto
          Text(
            monto,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          // Balance
          Text(
            'Balance: $balance',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumericKeyboard() {
    return Column(
      children: [
        // Fila 1
        Row(
          children: [
            _buildKeyboardButton('1'),
            const SizedBox(width: 12),
            _buildKeyboardButton('2'),
            const SizedBox(width: 12),
            _buildKeyboardButton('3'),
          ],
        ),
        const SizedBox(height: 12),
        // Fila 2
        Row(
          children: [
            _buildKeyboardButton('4'),
            const SizedBox(width: 12),
            _buildKeyboardButton('5'),
            const SizedBox(width: 12),
            _buildKeyboardButton('6'),
          ],
        ),
        const SizedBox(height: 12),
        // Fila 3
        Row(
          children: [
            _buildKeyboardButton('7'),
            const SizedBox(width: 12),
            _buildKeyboardButton('8'),
            const SizedBox(width: 12),
            _buildKeyboardButton('9'),
          ],
        ),
        const SizedBox(height: 12),
        // Fila 4
        Row(
          children: [
            Expanded(
              child: _buildKeyboardButton('.'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildKeyboardButton('0'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    if (montoOrigen.length > 1) {
                      montoOrigen = montoOrigen.substring(0, montoOrigen.length - 1);
                    } else {
                      montoOrigen = '0';
                    }
                  });
                },
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.backspace,
                    color: Colors.black87,
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKeyboardButton(String numero) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _agregarNumero(numero),
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              numero,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getFlagEmoji(String moneda) {
    switch (moneda) {
      case 'USD':
        return '🇺🇸';
      case 'CNY':
        return '🇨🇳';
      case 'EUR':
        return '🇪🇺';
      case 'GBP':
        return '🇬🇧';
      case 'JPY':
        return '🇯🇵';
      default:
        return '🌍';
    }
  }
}