import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../logic/cubit/game_cubit.dart';

class NumberPad extends StatelessWidget {
  const NumberPad({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<GameCubit>();

    return Container(
      padding: const EdgeInsets.all(8),
      child: GridView.count(
        shrinkWrap: true,
        crossAxisCount: 9,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,

        children: [
          // Numbers 1-9
          for (int i = 1; i <= 9; i++)
            TextButton(
              onPressed: () => cubit.setNumber(i),
              child: Text(i.toString(), style: const TextStyle(fontSize: 20)),
            ),
        ],
      ),
    );
  }
}
