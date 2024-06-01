import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

abstract class CardFlyingController<M> extends GetxController with GetSingleTickerProviderStateMixin {
  late AnimationController animationController;
  final Random random = Random();
  bool isAnimating = true;
  int cardNum = 15;
  late List<M> datas;
  final List<Offset> cardPositions = [];
  final List<M> currentDisplayData = [];

  void toggleAnimation() {
    if (isAnimating) {
      animationController.stop();
    } else {
      animationController.repeat();
    }
    isAnimating = !isAnimating;
    update();
  }

  void stopAnimation() {
    animationController.stop();
    isAnimating = false;
    update();
  }

  void startAnimation() {
    animationController.repeat();
    isAnimating = true;
    update();
  }

  Future<List<M>> loadData();

  @override
  Future<void> onInit() async {
    super.onInit();
    List<M> loadedDatas = await loadData();
    loadedDatas.shuffle();
    datas = loadedDatas;

    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(() {
      for (int i = 0; i < cardPositions.length; i++) {
        double newX = cardPositions[i].dx - 0.5;
        if (newX < -160) {
          cardPositions[i] = getRandomPosition();
          currentDisplayData[i] = datas[random.nextInt(datas.length)];
        } else {
          cardPositions[i] = Offset(newX, cardPositions[i].dy);
        }
      }
      update();
    });

    updateCurrentDisplayData();
    animationController.repeat();
  }

  void updateCurrentDisplayData() {
    cardPositions.clear();
    currentDisplayData.clear();
    for (int i = 0; i < cardNum; i++) {
      int randomIndex = random.nextInt(datas.length);
      currentDisplayData.add(datas[randomIndex]);
      cardPositions.add(getRandomPosition());
    }
    update();
  }

  Offset getRandomPosition() {
    const double cardWidth = 160;
    const double cardHeight = 120;
    const int maxAttempts = 100;
    final double maxHeight = MediaQuery.of(Get.context!).size.height - cardHeight;
    final double maxWidth = MediaQuery.of(Get.context!).size.width + cardWidth;
    Offset position;
    int attempts = 0;

    bool isOverlapping(Offset pos) {
      for (var cardPosition in cardPositions) {
        if (pos.dx < cardPosition.dx + cardWidth &&
            pos.dx + cardWidth > cardPosition.dx &&
            pos.dy < cardPosition.dy + cardHeight &&
            pos.dy + cardHeight > cardPosition.dy) {
          return true;
        }
      }
      return false;
    }

    do {
      double yOffset = random.nextDouble() * maxHeight;
      double xOffset = random.nextDouble() * maxWidth;
      position = Offset(xOffset, yOffset);
      attempts++;
    } while (isOverlapping(position) && attempts < maxAttempts);

    if (attempts >= maxAttempts) {
      position = Offset(
          random.nextDouble() * maxWidth, random.nextDouble() * maxHeight);
    }

    return position;
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
}

Widget buildCardFlyingWidget<T, C extends CardFlyingController<T>>({
  required Widget Function(T item, int index) itemBuilder,
  Function(T item, int index)? onItemClick,
  Function(T item, int index)? onItemLongPress,
  String? tag,
}) {
  C controller = Get.find(tag: tag);
  return GetBuilder<C>(
    builder: (_) {
      return Stack(
        children: List.generate(controller.currentDisplayData.length, (index) {
          Offset position = controller.cardPositions[index];
          T data = controller.currentDisplayData[index];
          return Positioned(
            left: position.dx,
            top: position.dy,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                controller.stopAnimation();
                onItemClick?.call(controller.currentDisplayData[index], index);
              },
              onLongPress: () {
                controller.stopAnimation();
                onItemLongPress?.call(controller.currentDisplayData[index], index);
              },
              child: Container(
                width: 160,
                height: 120,
                color: Colors.transparent,
                child: itemBuilder(controller.currentDisplayData[index], index),
              ),
            ),
          );
        }),
      );
    },
  );
}
