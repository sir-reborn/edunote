import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:edunote/utils/colour.dart';

class CustomCard extends StatefulWidget {
  final Size size;
  final Icon icon;
  final String title, statusOn, statusOff;

  const CustomCard({
    super.key,
    required this.size,
    required this.icon,
    required this.title,
    required this.statusOn,
    required this.statusOff,
  });

  @override
  State<CustomCard> createState() => _CustomCardState();
}

class _CustomCardState extends State<CustomCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Alignment> _animation;
  bool isChecked = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 350),
    );

    _animation =
        Tween<Alignment>(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.linear,
            reverseCurve: Curves.easeInBack,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      //height: 140,
      width: widget.size.width * 0.35,
      decoration: BoxDecoration(
        color: Colour.kBgColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(3, 3)),
          BoxShadow(color: Colors.white, blurRadius: 0, offset: Offset(-3, -3)),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                widget.icon,
                GestureDetector(
                  onTap: () {
                    setState(() {
                      if (_animationController.isCompleted) {
                        _animationController.reverse();
                      } else {
                        _animationController.forward();
                      }
                      isChecked = !isChecked;
                    });
                  },
                  child: AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Container(
                        height: 40,
                        width: 25,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.grey.shade50,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade200,
                              blurRadius: 0,
                              offset: Offset(3, 3),
                            ),
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 5,
                              offset: Offset(-3, -3),
                            ),
                          ],
                        ),
                        child: Align(
                          alignment: _animation.value,
                          child: Container(
                            height: 15,
                            width: 15,
                            margin: EdgeInsets.symmetric(
                              vertical: 2,
                              horizontal: 1,
                            ),
                            decoration: BoxDecoration(
                              color: isChecked
                                  ? Colors.grey.shade300
                                  : Colour.blue,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(
              widget.title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black.withOpacity(0.7),
              ),
            ),
            Text(
              isChecked ? widget.statusOff : widget.statusOn,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isChecked ? Colors.grey.withOpacity(0.6) : Colour.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
