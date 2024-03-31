import 'package:flutter/material.dart';

class CreatePromptScreen extends StatefulWidget {
  const CreatePromptScreen({super.key});

  @override
  State<CreatePromptScreen> createState() => _CreatePromptScreenState();
}

class _CreatePromptScreenState extends State<CreatePromptScreen> {
  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0), // Set the preferred height here
        child: AppBar(
          title: const Text("AI Image Generator"),
          centerTitle: true,
          titleSpacing: 0.0,
          toolbarHeight: 60.0, // Set the toolbar height to match the preferredSize
        ),
      ),


      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              child: Container(
            color: Colors.deepPurple,
          )),
          Container(
            color: Colors.grey.shade900,
            width: MediaQuery.of(context).size.width,
            height: 240,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Enter your Prompt : ",),
                const SizedBox(
                  height: 20,
                ),
                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                  width: double.maxFinite,
                  height: 55,
                  child: ElevatedButton.icon(
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              20), // Set border radius to 0 for a rectangular shape
                        ),
                      ),
                      backgroundColor:
                          MaterialStateProperty.all(Colors.deepPurple),
                    ),
                    onPressed: () {},
                    icon: const Icon(Icons.generating_tokens_outlined),
                    label: const Text("Generate Image"),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
