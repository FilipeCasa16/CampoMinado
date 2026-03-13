import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const CampoMinadoApp());
}

class CampoMinadoApp extends StatelessWidget {
  const CampoMinadoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CampoMinadoPage(),
    );
  }
}

class Cell {
  bool bomb = false;
  bool revealed = false;
  int around = 0;
}

class CampoMinadoPage extends StatefulWidget {
  const CampoMinadoPage({super.key});

  @override
  State<CampoMinadoPage> createState() => _CampoMinadoPageState();
}

class _CampoMinadoPageState extends State<CampoMinadoPage> {

  static const int size = 12;
  static const int bombs = 8;

  late List<List<Cell>> board;
  bool gameOver = false;

  @override
  void initState() {
    super.initState();
    createGame();
  }

  void createGame() {
    board = List.generate(size, (_) => List.generate(size, (_) => Cell()));
    gameOver = false;

    placeBombs();
    calculateNumbers();
  }

  void placeBombs() {

    Random rand = Random();
    int placed = 0;

    while (placed < bombs) {

      int r = rand.nextInt(size);
      int c = rand.nextInt(size);

      if (!board[r][c].bomb) {
        board[r][c].bomb = true;
        placed++;
      }

    }
  }

  void calculateNumbers() {

    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {

        if (board[r][c].bomb) continue;

        int count = 0;

        for (int i = -1; i <= 1; i++) {
          for (int j = -1; j <= 1; j++) {

            int nr = r + i;
            int nc = c + j;

            if (nr >= 0 &&
                nr < size &&
                nc >= 0 &&
                nc < size &&
                board[nr][nc].bomb) {
              count++;
            }

          }
        }

        board[r][c].around = count;

      }
    }
  }

  void reveal(int r, int c) {

    if (gameOver) return;
    if (board[r][c].revealed) return;

    if (board[r][c].bomb) {

      setState(() {
        gameOver = true;
        revealAll();
      });

      showGameOver();
      return;
    }

    openArea(r, c);

    if (checkVictory()) {
      gameOver = true;
      showVictory();
    }

    setState(() {});
  }

  void openArea(int r, int c) {

    if (r < 0 || r >= size || c < 0 || c >= size) return;
    if (board[r][c].revealed) return;

    board[r][c].revealed = true;

    if (board[r][c].around != 0) return;

    for (int i = -1; i <= 1; i++) {
      for (int j = -1; j <= 1; j++) {
        openArea(r + i, c + j);
      }
    }

  }

  bool checkVictory() {

    int revealed = 0;

    for (var row in board) {
      for (var cell in row) {

        if (cell.revealed && !cell.bomb) {
          revealed++;
        }

      }
    }

    return revealed == (size * size - bombs);
  }

  void revealAll() {

    for (var row in board) {
      for (var cell in row) {
        cell.revealed = true;
      }
    }

  }

  void showGameOver() {

    Future.delayed(const Duration(milliseconds: 200), () {

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Game Over"),
          content: const Text("Você encontrou uma bomba."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  createGame();
                });
              },
              child: const Text("Reiniciar"),
            )
          ],
        ),
      );

    });
  }

  void showVictory() {

    Future.delayed(const Duration(milliseconds: 200), () {

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("🎉 Vitória!"),
          content: const Text("Você abriu todas as casas seguras."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  createGame();
                });
              },
              child: const Text("Jogar novamente"),
            )
          ],
        ),
      );

    });
  }

  Widget buildCell(int r, int c) {

    Cell cell = board[r][c];

    return GestureDetector(
      onTap: () => reveal(r, c),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          color: cell.revealed ? Colors.grey[300] : Colors.grey[600],
        ),
        child: Center(
          child: cell.revealed
              ? cell.bomb
                  ? const Text("💣")
                  : Text(
                      cell.around == 0 ? "" : cell.around.toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    )
              : const SizedBox(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Campo Minado"),
        centerTitle: true,
      ),

      body: Center(
        child: AspectRatio(
          aspectRatio: 1,
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: size,
            ),
            itemCount: size * size,
            itemBuilder: (context, index)  {

              int r = index ~/ size;
              int c = index % size;

              return buildCell(r, c);
            },
          ),
        ),
      ),
    );
  }
}