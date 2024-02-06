import 'package:flutter/material.dart';

class CustomCarousel extends StatefulWidget {
  const CustomCarousel({
    super.key,
    required this.slides,
  });

  final List<Widget> slides;
  
  @override
  State<CustomCarousel> createState() => _CustomCarouselState();
}

class _CustomCarouselState extends State<CustomCarousel> {
  List<Widget> indicators(imagesLength, currentIndex, pageController) {
    return List<Widget>.generate(imagesLength, (index) {
      return InkWell(
        onTap: (){
          pageController.jumpToPage(index);
        },
        child: Container(
          margin: EdgeInsets.all(3),
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: currentIndex == index ? Color(0xff1862f0) : Colors.black26,
            shape: BoxShape.circle,
          ),
        ),
      );
    });
  }

  AnimatedContainer slider(slides, pagePosition, active) {
    double margin = active ? 0 : 15;
    return AnimatedContainer(
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic,
      margin: EdgeInsets.all(margin),
      child: slides[pagePosition],
    );
  }

  int activePage = 0;

  List<Widget> get slides => widget.slides; 

  @override
  Widget build(BuildContext context) {
    PageController pageController =
        PageController(viewportFraction: 0.8, initialPage: 0);


    
    return Container(
      height: 600.0,
      child: Column(
        children: [
          Expanded(
            child: Container(
              child: PageView.builder(
                  itemCount: slides.length,
                  pageSnapping: true,
                  controller: pageController,
                  onPageChanged: (page) {
                    setState(() {
                      activePage = page;
                    });
                  },
                  itemBuilder: (context, pagePosition) {
                    bool active = pagePosition == activePage;
                    return slider(slides, pagePosition, active);
                  }),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: indicators(slides.length, activePage, pageController),
          ),
          const SizedBox(
            height: 40.0,
          ),
        ],
      ),
    );
  }
}
