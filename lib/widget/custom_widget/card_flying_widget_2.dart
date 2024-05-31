import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// 示例数据模型类 MediaFileData
class MediaFileData {
  final String name;

  MediaFileData(this.name);
}

class CardFlyingController2 extends CardFlyingController<MediaFileData> {
  @override
  List<MediaFileData> loadData() {
    datas = List<MediaFileData>.generate(
        1000, (index) => MediaFileData('Media $index'));
    return datas;
  }
}

abstract class CardFlyingController<M> extends GetxController
    with GetSingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<Offset> animation;
  final Random random = Random();
  bool isAnimating = true;
  int cardNum = 10;

  late List<M> datas;

  final List<Offset> cardPositions = [];
  final List<M> currentDisplayData = [];

  void toggleAnimation() {
    if (isAnimating) {
      animationController.stop();
    } else {
      animationController.repeat(reverse: false);
    }
    isAnimating = !isAnimating;
    update(); // 更新状态
  }

  List<M> loadData();

  @override
  void onInit() {
    super.onInit();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20), // 调整滚动速度，增加动画持续时间
    );

    animation = Tween<Offset>(
      begin: Offset(1.0, 0.0),
      end: Offset(-2.0, 0.0), // 改变动画范围
    ).animate(animationController);

    animationController.repeat(reverse: false);
    animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        updateCurrentDisplayData();
        animationController.forward(from: 0.0);
      }
    });
    updateCurrentDisplayData();
  }

  void updateCurrentDisplayData() {
    cardPositions.clear();
    currentDisplayData.clear();
    for (int i = 0; i < cardNum; i++) {
      int randomIndex = random.nextInt(datas.length);
      currentDisplayData.add(datas[randomIndex]);
    }
    update(); // 更新状态以刷新UI
  }

  @override
  void onClose() {
    animationController.dispose();
    super.onClose();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  Offset getRandomPosition(double maxHeight, double maxWidth) {
    const double cardWidth = 100;
    const double cardHeight = 150;
    const int maxAttempts = 100; // 最大尝试次数
    Offset position;

    bool isOverlapping(Offset pos) {
      for (var cardPosition in cardPositions) {
        if ((pos.dx < cardPosition.dx + cardWidth &&
            pos.dx + cardWidth > cardPosition.dx &&
            pos.dy < cardPosition.dy + cardHeight &&
            pos.dy + cardHeight > cardPosition.dy)) {
          return true;
        }
      }
      return false;
    }

    int attempts = 0;
    do {
      double yOffset = random.nextDouble() * maxHeight;
      double xOffset = random.nextDouble() * maxWidth;
      position = Offset(xOffset, yOffset);
      attempts++;
    } while (isOverlapping(position) && attempts < maxAttempts);

    // 如果超过最大尝试次数，则返回一个默认位置
    if (attempts >= maxAttempts) {
      position = Offset(
          random.nextDouble() * maxWidth, random.nextDouble() * maxHeight);
    }

    cardPositions.add(position);
    return position;
  }
}

Widget buildCardFlyingWidget<T, C extends CardFlyingController<T>>(
    {required Widget Function(T item, int index) itemBuilder,
    Function(T item, int index)? onItemClick,
    Function(T item, int index)? onItemLongPress,
    String? tag}) {
  C controller = Get.find(tag: tag);
  final double maxHeight = MediaQuery.of(Get.context!).size.height -
      150; // 150 is the card height to ensure cards stay in view
  final double maxWidth = MediaQuery.of(Get.context!).size.width -
      100; // 100 is the card width to ensure cards stay in view
  return Stack(
    children: List.generate(controller.currentDisplayData.length, (index) {
      if (controller.cardPositions.length < controller.cardNum) {
        controller.cardPositions
            .add(controller.getRandomPosition(maxHeight, maxWidth));
      }
      Offset position = controller.cardPositions[index];
      T data = controller.currentDisplayData[index];
      return AnimatedBuilder(
        animation: controller.animationController,
        builder: (context, child) {
          double screenWidth = MediaQuery.of(context).size.width;
          double cardPositionX =
              (controller.animation.value.dx * screenWidth + position.dx) %
                      (screenWidth + 100) -
                  100;
          return Transform.translate(
              offset: Offset(cardPositionX, position.dy),
              child: itemBuilder(controller.currentDisplayData[index], index));
        },
      );
    }),
  );
}

class CardFlyingPage2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final CardFlyingController2 cardController =
        Get.put(CardFlyingController2());
    return Scaffold(
      appBar: AppBar(
        title: Text('Animated Cards'),
        actions: [
          IconButton(
            icon: Icon(
                cardController.isAnimating ? Icons.pause : Icons.play_arrow),
            onPressed: () {
              cardController.toggleAnimation();
            },
          ),
        ],
      ),
      body: GetBuilder<CardFlyingController2>(
        builder: (controller) {
          return buildCardFlyingWidget(itemBuilder: (data, index) {
            return Card(
              color: Colors.blue[(index % 9 + 1) * 100],
              child: SizedBox(
                width: 100,
                height: 150,
                child: Center(
                  child: Text(
                    'Card ${index + 1}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            );
          });
        },
      ),
    );
  }
}
