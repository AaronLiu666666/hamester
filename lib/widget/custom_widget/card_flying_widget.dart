import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CardFlyingController extends GetxController with GetSingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<Offset> animation;
  final Random random = Random();
  bool isAnimating = true;

  void toggleAnimation() {
    if (isAnimating) {
      animationController.stop();
    } else {
      animationController.repeat(reverse: false);
    }
    isAnimating = !isAnimating;
    update(); // 更新状态
  }

  @override
  void onInit() {
    super.onInit();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20), // 调整滚动速度，增加动画持续时间
    );

    animation = Tween<Offset>(
      begin: Offset(1.5, 0.0),
      end: Offset(-1.5, 0.0),
    ).animate(animationController);

    animationController.repeat(reverse: false);
  }

  @override
  void onClose() {
    animationController.dispose();
    super.onClose();
  }

  double getRandomYOffset(double maxHeight, int index, int totalCards) {
    return (index / totalCards) * maxHeight;
  }

  double getRandomXOffset(double maxWidth) {
    return random.nextDouble() * maxWidth;
  }
}

class CardFlyingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final CardFlyingController cardController = Get.put(CardFlyingController());
    final double maxHeight = MediaQuery.of(context).size.height - 150; // 150 is the card height to ensure cards stay in view
    final double maxWidth = MediaQuery.of(context).size.width - 100; // 100 is the card width to ensure cards stay in view

    return Scaffold(
      appBar: AppBar(
        title: Text('Animated Cards'),
        actions: [
          IconButton(
            icon: Icon(Icons.pause),
            onPressed: () {
              cardController.toggleAnimation();
            },
          ),
        ],
      ),
      body: GetBuilder<CardFlyingController>(
        builder: (controller) {
          return Stack(
            children: List.generate(20, (index) {
              double yOffset = controller.getRandomYOffset(maxHeight, index, 20);
              double xOffset = controller.getRandomXOffset(maxWidth);

              return AnimatedBuilder(
                animation: controller.animationController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(controller.animation.value.dx * MediaQuery.of(context).size.width, yOffset),
                    child: Transform.translate(
                      offset: Offset(-xOffset, 0), // 确保卡片从右侧消失后从左侧重新出现
                      child: Card(
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
                      ),
                    ),
                  );
                },
              );
            }),
          );
        },
      ),
    );
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CardFlyingPage(),
    );
  }
}
