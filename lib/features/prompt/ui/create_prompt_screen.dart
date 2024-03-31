import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

import '../bloc/prompt_bloc.dart';

class CreatePromptScreen extends StatefulWidget {
  const CreatePromptScreen({super.key});

  @override
  State<CreatePromptScreen> createState() => _CreatePromptScreenState();
}

class _CreatePromptScreenState extends State<CreatePromptScreen> {
  TextEditingController controller = TextEditingController();
  final PromptBloc promptBloc = PromptBloc();

  bool _keyboardIsVisible = false;

  @override
  void initState() {
    promptBloc.add(PromptInitialEvent());
    super.initState();
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
                            width: MediaQuery.of(context).size.width / 2,
                            height: 10,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
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
                      ],
                    ),
                  ),
                );

              case PromptGeneratingImageErrorState:
                return const Center(
                  child: Text("Something Went Wrong"),
                );

              case PromptGeneratingImageSuccessState:
                final successState =
                state as PromptGeneratingImageSuccessState;
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.width,
                        width: double.maxFinite,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            fit: BoxFit.fitWidth,
                            image: MemoryImage(successState.uint8list),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).viewInsets.bottom,
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height-MediaQuery.of(context).size.width,
                        color: Colors.grey.shade900,
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Enter your Prompt : "),
                            const SizedBox(height: 20),
                            TextField(
                              controller: controller,
                              maxLines: calculateMaxLines(context),
                              decoration: InputDecoration(
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
                                  backgroundColor:
                                  MaterialStateProperty.all(
                                      Colors.deepPurple),
                                ),
                                onPressed: () {
                                  if (controller.text.isNotEmpty) {
                                    promptBloc.add(PromptEnteredEvent(
                                        prompt: controller.text));
                                  }
                                },
                                icon: const Icon(
                                    Icons.generating_tokens_outlined),
                                label: const Text("Generate Image"),
                              ),
                            )
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
    double screenHeight = MediaQuery.of(context).size.height;
    double estimatedLineHeight = 130.0;
    int maxLines = (screenHeight / estimatedLineHeight).floor();
    return maxLines;
  }
}
