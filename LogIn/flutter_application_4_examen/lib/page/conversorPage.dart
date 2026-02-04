import 'package:flutter/material.dart';
import '../widget/CurrencyWidget.dart';
import '../widget/botonWidget.dart';

class ConversorPage extends StatelessWidget {
  const ConversorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              'Between Accounts',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              'No commission',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),
            
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2C2C2C),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Text(
                  '1USD = ¥7.2493 CNY',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Column(
                    children: [
                      const CurrencyWidget(
                        currency: 'USD',
                        flag: '🇺🇸',
                        amount: '140.00',
                        subtitle: 'Balance: \$150.56',
                      ),
                      const SizedBox(height: 20),
                      const CurrencyWidget(
                        currency: 'CNY',
                        flag: '🇨🇳',
                        amount: '1014.902',
                        subtitle: 'Balance: ¥246.63',
                      ),
                    ],
                  ),
                  Positioned(
                    top: 0,
                    bottom: 0,
                    left: 0,
                    right: 0,
                  
                    child: Center(
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2C2C2C),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Transform.rotate(
                          angle: 1.5708, 
                          child: const Icon(Icons.swap_vert, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  _buildFila(['1', '2', '3']),
                  const SizedBox(height: 16),
                  _buildFila(['4', '5', '6']),
                  const SizedBox(height: 16),
                  _buildFila(['7', '8', '9']),
                  const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  BotonWidget(label: '.', onPressed: () {}),
                  BotonWidget(label: '0', onPressed: () {}),
                  BotonWidget(
                    label: '',
                    onPressed: () {
                    },
                    backgroundColor:  const Color.fromARGB(0, 245, 245, 245),
                  ),
                ],
              ),
                ],
              ),
            ),

            const SizedBox(height: 20),

          ]
        ),
      ),
    );
  }

  Widget _buildFila(List<String> numeros) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: numeros.map((n) => BotonWidget(label: n, onPressed: () {})).toList(),
    );
  }
}