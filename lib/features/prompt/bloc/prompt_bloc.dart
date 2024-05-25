import 'dart:async';
import 'dart:typed_data';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../prompt_repo.dart';
part 'prompt_event.dart';
part 'prompt_state.dart';

class PromptBloc extends Bloc<PromptEvent, PromptState> {
  PromptBloc() : super(PromptInitial()) {
    on<PromptInitialEvent>(promptInitialEvent);
    on<PromptEnteredEvent>(promptEnteredEvent);
  }

  FutureOr<void> promptEnteredEvent(
      PromptEnteredEvent event, Emitter<PromptState> emit) async {

    emit(PromptGeneratingImageLoadState());
    await Future.delayed(Duration(seconds: 5));
    Uint8List? bytes = await PromptRepo.generateImage(event.prompt);
    if (bytes != null) {
      emit(PromptGeneratingImageSuccessState(bytes));
    } else {
      emit(PromptGeneratingImageErrorState());
    }
  }

  FutureOr<void> promptInitialEvent(PromptInitialEvent event, Emitter<PromptState> emit) async {
    // Load the image asset as a ByteData
    ByteData? imageData = await rootBundle.load('assets/file.png');

    if (imageData != null) {
      // Convert ByteData to Uint8List
      Uint8List bytes = imageData.buffer.asUint8List();

      // Emit the success state with the image bytes
      emit(PromptGeneratingImageSuccessState(bytes));
    } else {
      // Handle error state if image asset cannot be loaded
      emit(PromptGeneratingImageErrorState());
    }
  }

}