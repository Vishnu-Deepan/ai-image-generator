import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import '../bloc/prompt_bloc.dart';

class CreatePromptScreen extends StatefulWidget {
  const CreatePromptScreen({Key? key}) : super(key: key);

  @override
  State<CreatePromptScreen> createState() => _CreatePromptScreenState();
}

class _CreatePromptScreenState extends State<CreatePromptScreen> {
  TextEditingController controller = TextEditingController();
  final PromptBloc promptBloc = PromptBloc();

  bool _keyboardIsVisible = false;

  // Google Ad
  late BannerAd _bannerAd;
  late bool isBannerAdLoaded = false;

  @override
  void initState() {
    promptBloc.add(PromptInitialEvent());
    super.initState();
    _initAds();
  }

  void _initAds() {
    _initBannerAd();
  }

  void _initBannerAd() {
    _bannerAd = BannerAd(
      size: AdSize.banner,
      adUnitId: 'ca-app-pub-3940256099942544/6300978111', // Test ad unit ID
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            isBannerAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {},
      ),
      request: const AdRequest(),
    );
    _bannerAd.load();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (_keyboardIsVisible) {
          FocusScope.of(context).unfocus();
        }
      },
      onPanUpdate: (details) {
        if (!_keyboardIsVisible) return;
        setState(() {
          _keyboardIsVisible = false;
        });
      },
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: AppBar(
            actions: [
              IconButton(
                onPressed: () {
                  final currentState = promptBloc.state;
                  if (currentState is PromptGeneratingImageSuccessState) {
                    _saveImageToLocal(context, currentState.uint8list);
                  }
                },
                icon: const Icon(Icons.download),
              ),
            ],
            title: const Text("AI Image Generator"),
            centerTitle: true,
            titleSpacing: 0.0,
            toolbarHeight: 60.0,
          ),
        ),
        body: BlocConsumer<PromptBloc, PromptState>(
          bloc: promptBloc,
          listener: (context, state) {},
          builder: (context, state) {
            switch (state.runtimeType) {
              case PromptGeneratingImageLoadState:
                return Container(
                  color: Colors.black,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Shimmer.fromColors(
                          baseColor: Colors.white10!,
                          highlightColor: Colors.lightGreenAccent!,
                          child: Container(
                            width: MediaQuery
                                .of(context)
                                .size
                                .width / 2,
                            height: 10,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Generating Image...',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Please wait... It may take some time',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[300],
                          ),
                        ),
                        // Banner Ad
                      ],
                    ),
                  ),
                );

              case PromptGeneratingImageErrorState:
                return const Center(
                  child: Text("Something Went Wrong"),
                );

              case PromptGeneratingImageSuccessState:
                final successState = state as PromptGeneratingImageSuccessState;
                return SingleChildScrollView(
                  // Your success UI
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: MediaQuery
                            .of(context)
                            .size
                            .width,
                        width: double.maxFinite,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            fit: BoxFit.fitWidth,
                            image: MemoryImage(successState.uint8list),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery
                            .of(context)
                            .viewInsets
                            .bottom,
                      ),
                      Container(
                        height: MediaQuery
                            .of(context)
                            .size
                            .height -
                            MediaQuery
                                .of(context)
                                .size
                                .width,
                        color: Colors.grey.shade900,
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              //GOOGLE ADS
                              child: isBannerAdLoaded
                                  ? Container(
                                height: _bannerAd.size.height.toDouble(),
                                width: _bannerAd.size.width.toDouble(),
                                child: AdWidget(ad: _bannerAd),
                              )
                                  : const SizedBox(),
                            ),
                            // const SizedBox(height: 20,),
                            // const Text("Enter your Prompt : "),
                            const SizedBox(height: 20),
                            TextField(
                              controller: controller,
                              maxLines: calculateMaxLines(context),
                              decoration: InputDecoration(
                                labelStyle: const TextStyle(
                                  color: Colors.white60,
                                ),
                                labelText: 'Enter your Prompt ',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.maxFinite,
                              height: 55,
                              child: ElevatedButton.icon(
                                style: ButtonStyle(
                                  shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  backgroundColor: MaterialStateProperty.all(
                                      Colors.deepPurple),
                                ),
                                onPressed: () {
                                  if (controller.text.isNotEmpty) {
                                    promptBloc.add(PromptEnteredEvent(
                                      prompt: controller.text,
                                    ));
                                  }
                                },
                                icon: const Icon(
                                  Icons.generating_tokens_outlined,
                                  color: Colors.white,
                                ),
                                label: const Text(
                                  "Generate Image",
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ],
                  ),
                );

              default:
                return const SizedBox();
            }
          },
        ),
      ),
    );
  }

  int calculateMaxLines(BuildContext context) {
    double screenHeight = MediaQuery
        .of(context)
        .size
        .height;
    double estimatedLineHeight = 190.0;
    int maxLines = (screenHeight / estimatedLineHeight).floor();
    return maxLines;
  }

  Future<void> _saveImageToLocal(BuildContext context, Uint8List imageBytes) async {
    try {
      final directory = await getExternalStorageDirectory();
      if (directory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: External storage directory not found.'),
          ),
        );
        return;
      }

      final String storageRootPath = directory.path;
      final String visifyFolderPath = '$storageRootPath/Visify';

      // Create the "Visify" folder if it doesn't exist
      final visifyFolder = Directory(visifyFolderPath);
      if (!await visifyFolder.exists()) {
        await visifyFolder.create();
      }

      final imageFile = File('$visifyFolderPath/generated_image.png');
      await imageFile.writeAsBytes(imageBytes);

      // Save the image to the device's media store
      await GallerySaver.saveImage(imageFile.path);

      print(visifyFolderPath);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Image saved to Visify folder and added to gallery.'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving image: $e'),
        ),
      );
      print(e);

    }
  }

}
