-- ~/.config/nvim/lua/local/archflow-nvim/lua/archflow/templates.lua

-- This file holds all template strings internally to avoid file system issues.
local M = {}

M.bloc_bloc = [[
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part '{{featureName}}_event.dart';
part '{{featureName}}_state.dart';

class {{className}}Bloc extends Bloc<{{className}}Event, {{className}}State> {
  {{className}}Bloc() : super(const {{className}}State()) {
    on<Custom{{className}}Event>(_onCustom{{className}}Event);
  }

  void _onCustom{{className}}Event(
    Custom{{className}}Event event,
    Emitter<{{className}}State> emit,
  ) {
    // TODO: implement event handler
  }
}
]]

M.bloc_event = [[
part of '{{featureName}}_bloc.dart';

abstract class {{className}}Event extends Equatable {
  const {{className}}Event();

  @override
  List<Object> get props => [];
}

class Custom{{className}}Event extends {{className}}Event {
  const Custom{{className}}Event();
}
]]

M.bloc_state = [[
part of '{{featureName}}_bloc.dart';

class {{className}}State extends Equatable {
  const {{className}}State();
  
  @override
  List<Object> get props => [];
}
]]

M.bloc_bloc_test = [[
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:{{projectName}}/features/{{featureName}}/presentation/bloc/{{featureName}}_bloc.dart';

void main() {
  group('{{className}}Bloc', () {
    test('initial state is {{className}}State', () {
      expect({{className}}Bloc().state, const {{className}}State());
    });

    blocTest<{{className}}Bloc, {{className}}State>(
      'emits [] when nothing is added',
      build: () => {{className}}Bloc(),
      expect: () => const <{{className}}State>[],
    );
  });
}
]]

M.cubit_cubit = [[
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part '{{featureName}}_state.dart';

class {{className}}Cubit extends Cubit<{{className}}State> {
  {{className}}Cubit() : super(const {{className}}State());

  void updateMessage(String newMessage) {
    emit(state.copyWith(message: newMessage));
  }
}
]]

M.cubit_state = [[
part of '{{featureName}}_cubit.dart';

class {{className}}State extends Equatable {
  final String message;

  const {{className}}State({this.message = 'Initial Message'});

  @override
  List<Object> get props => [message];

  {{className}}State copyWith({
    String? message,
  }) {
    return {{className}}State(
      message: message ?? this.message,
    );
  }
}
]]

M.cubit_cubit_test = [[
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:{{projectName}}/features/{{featureName}}/presentation/cubit/{{featureName}}_cubit.dart';

void main() {
  group('{{className}}Cubit', () {
    test('initial state has initial message', () {
      expect({{className}}Cubit().state, const {{className}}State(message: 'Initial Message'));
    });

    blocTest<{{className}}Cubit, {{className}}State>(
      'emits new state when updateMessage is called',
      build: () => {{className}}Cubit(),
      act: (cubit) => cubit.updateMessage('New Message'),
      expect: () => <{{className}}State>[
        const {{className}}State(message: 'New Message'),
      ],
    );
  });
}
]]

M.provider_provider = [[
import 'package:flutter/material.dart';

class {{className}}Provider extends ChangeNotifier {
  String _message = 'Initial Message';

  String get message => _message;

  void updateMessage(String newMessage) {
    if (_message == newMessage) return;
    _message = newMessage;
    notifyListeners();
  }
}
]]

M.provider_provider_test = [[
import 'package:flutter_test/flutter_test.dart';
import 'package:{{projectName}}/features/{{featureName}}/presentation/provider/{{featureName}}_provider.dart';

void main() {
  group('{{className}}Provider', () {
    test('initial message is correct', () {
      final provider = {{className}}Provider();
      expect(provider.message, 'Initial Message');
    });

    test('updateMessage changes the message and notifies listeners', () {
      final provider = {{className}}Provider();
      int listenerCallCount = 0;
      provider.addListener(() {
        listenerCallCount++;
      });

      const newMessage = 'Updated Message';
      provider.updateMessage(newMessage);

      expect(provider.message, newMessage);
      expect(listenerCallCount, 1);
    });
  });
}
]]

M.riverpod_provider = [[
import 'package:flutter_riverpod/flutter_riverpod.dart';

class {{className}}State {
  final String message;
  {{className}}State({this.message = 'Initial Message'});
}

class {{className}}Notifier extends StateNotifier<{{className}}State> {
  {{className}}Notifier() : super({{className}}State());

  void updateMessage(String newMessage) {
    state = {{className}}State(message: newMessage);
  }
}

final {{featureName}}Provider = StateNotifierProvider<{{className}}Notifier, {{className}}State>((ref) {
  return {{className}}Notifier();
});
]]

M.riverpod_provider_test = [[
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:{{projectName}}/features/{{featureName}}/presentation/provider/{{featureName}}_provider.dart';

void main() {
  group('{{className}}Notifier', () {
    test('initial state is correct', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final state = container.read({{featureName}}Provider);
      expect(state.message, 'Initial Message');
    });

    test('updateMessage changes the state message', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read({{featureName}}Provider.notifier);
      notifier.updateMessage('New Message');
      final newState = container.read({{featureName}}Provider);
      expect(newState.message, 'New Message');
    });
  });
}
]]

M.getx_controller = [[
import 'package:get/get.dart';

class {{className}}Controller extends GetxController {
  var message = 'Initial Message'.obs;

  void updateMessage(String newMessage) {
    message.value = newMessage;
  }
}
]]

M.getx_controller_test = [[
import 'package:flutter_test/flutter_test.dart';
import 'package:{{projectName}}/features/{{featureName}}/presentation/controller/{{featureName}}_controller.dart';

void main() {
  group('{{className}}Controller', () {
    late {{className}}Controller controller;

    setUp(() {
      controller = {{className}}Controller();
    });

    test('initial message is correct', () {
      expect(controller.message.value, 'Initial Message');
    });

    test('updateMessage changes the message value', () {
      controller.updateMessage('New Message');
      expect(controller.message.value, 'New Message');
    });
  });
}
]]

M.mobx_store = [[
import 'package:mobx/mobx.dart';

part '{{featureName}}_store.g.dart';

class {{className}}Store = _{{className}}StoreBase with _${{className}}Store;

abstract class _{{className}}StoreBase with Store {
  @observable
  String message = 'Initial Message';

  @action
  void updateMessage(String newMessage) {
    message = newMessage;
  }
}
]]

M.mobx_store_test = [[
import 'package:flutter_test/flutter_test.dart';
import 'package:{{projectName}}/features/{{featureName}}/presentation/store/{{featureName}}_store.dart';

void main() {
  group('{{className}}Store', () {
    late {{className}}Store store;

    setUp(() {
      store = {{className}}Store();
    });

    test('initial message is correct', () {
      expect(store.message, 'Initial Message');
    });

    test('updateMessage action changes the message', () {
      const newMessage = 'Updated Message';
      store.updateMessage(newMessage);
      expect(store.message, newMessage);
    });
  });
}
]]

return M
