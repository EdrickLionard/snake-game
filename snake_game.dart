import 'dart:io';
import 'dart:math';
import 'dart:async';

void main() {
  final game = KadalGame();
  game.start();
}

class Node {
  Point<int> position;
  Node? next;

  Node(this.position);
}

class KadalGame {
  static const int width = 40; // Lebar diperbesar menjadi 40
  static const int height = 20; // Tinggi diperbesar menjadi 20
  static const Duration frameRate =
      Duration(milliseconds: 300); // Tingkatkan interval frame

  Node? head;
  int length = 1;
  Point<int> food = const Point(0, 0);
  Point<int> direction = const Point(1, 0);

  KadalGame() {
    head = Node(const Point(5, 5));
  }

  void start() {
    generateFood();
    Timer.periodic(frameRate, (timer) {
      update();
      render();
      if (isGameOver()) {
        print('Game Over! Skor: ${length - 1}');
        timer.cancel();
        exit(0);
      }
    });
  }

  void update() {
    final newHead = Node(Point(
      (head!.position.x + direction.x + width) % width,
      (head!.position.y + direction.y + height) % height,
    ));

    if (newHead.position == food) {
      newHead.next = head;
      head = newHead;
      length++;
      generateFood();
    } else {
      newHead.next = head;
      head = newHead;
      removeLastNode();
    }

    // Logika untuk mengarahkan kadal ke makanan
    if (food.x < head!.position.x)
      direction = const Point(-1, 0);
    else if (food.x > head!.position.x)
      direction = const Point(1, 0);
    else if (food.y < head!.position.y)
      direction = const Point(0, -1);
    else if (food.y > head!.position.y) direction = const Point(0, 1);
  }

  void removeLastNode() {
    if (head?.next == null) return;
    var current = head;
    while (current!.next!.next != null) {
      current = current.next;
    }
    current.next = null;
  }

  void render() {
    // Sembunyikan kursor
    stdout.write('\x1B[?25l');

    // Alih-alih membersihkan seluruh layar, pindahkan kursor ke awal
    print(
        '\x1B[0;0H'); // Hanya pindahkan kursor ke atas, tanpa membersihkan layar penuh

    print('╔' + '═' * width + '╗');

    List<List<String>> grid = List.generate(
      height,
      (_) => List.filled(width, ' '),
    );

    // Render makanan
    grid[food.y][food.x] = '•';

    // Render kadal dengan 4 kaki
    var current = head;
    int i = 0;
    while (current != null) {
      var segment = current.position;
      if (i == 0) {
        // Kepala kadal
        grid[segment.y][segment.x] = '◼';
      } else {
        // Badan kadal
        grid[segment.y][segment.x] = '█';
      }

      // Menambahkan 4 kaki
      if (length >= 5) {
        if (i == 1 || i == length - 2) {
          var prevSegment = i > 0 ? current.next!.position : head!.position;
          var nextSegment =
              current.next != null ? current.next!.position : segment;

          // Menentukan arah kaki berdasarkan arah badan
          if (prevSegment.x != nextSegment.x) {
            // Horizontal
            if (segment.y > 0) grid[segment.y - 1][segment.x] = '╨';
            if (segment.y < height - 1) grid[segment.y + 1][segment.x] = '╥';
          } else {
            // Vertical
            if (segment.x > 0) grid[segment.y][segment.x - 1] = '╢';
            if (segment.x < width - 1) grid[segment.y][segment.x + 1] = '╟';
          }
        }
      } else if (length > 1) {
        // Jika panjang kadal kurang dari 5, tambahkan kaki di segmen kedua
        if (i == 1) {
          if (segment.y > 0) grid[segment.y - 1][segment.x] = '╨';
          if (segment.y < height - 1) grid[segment.y + 1][segment.x] = '╥';
          if (segment.x > 0) grid[segment.y][segment.x - 1] = '╢';
          if (segment.x < width - 1) grid[segment.y][segment.x + 1] = '╟';
        }
      }

      current = current.next;
      i++;
    }

    // Menampilkan grid
    for (var row in grid) {
      stdout.write('║');
      for (var cell in row) {
        stdout.write(cell);
      }
      stdout.write('║\n');
    }

    print('╚' + '═' * width + '╝');
    print('Skor: ${length - 1}');

    // Tampilkan kembali kursor setelah selesai menggambar
    stdout.write('\x1B[?25h');
  }

  void generateFood() {
    do {
      food = Point(Random().nextInt(width), Random().nextInt(height));
    } while (containsPoint(food));
  }

  bool containsPoint(Point<int> point) {
    var current = head;
    while (current != null) {
      if (current.position == point) return true;
      current = current.next;
    }
    return false;
  }

  bool isGameOver() {
    var current = head!.next;
    while (current != null) {
      if (current.position == head!.position) return true;
      current = current.next;
    }
    return false;
  }
}
