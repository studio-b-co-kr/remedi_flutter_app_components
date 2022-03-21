part of 'mvvm.dart';

/// [IViewModelView] ViewModelView 는 상태 변경이 많고 여러 가지 데이터 혹은,
/// 복잡한 데이터를 표시할 때 사용한다.
/// [ViewModel] 에 의해서 상태 및 데이터에 접근한다.
/// 주로 Page를 만들 때 사용한다.
/// [VM]이 updateUi()를 하면 UI를 업데이트하고, updateAction(action) 시에는 UI 없데이트 없이
/// action 을 View에 전달한다.
/// AppModel
abstract class IViewModelView<VM extends IViewModel> extends StatefulWidget {
  final VM viewModel;

  const IViewModelView({Key? key, required this.viewModel}) : super(key: key);

  @override
  _ViewModelViewState<VM> createState() => _ViewModelViewState<VM>();

  Widget build(BuildContext context, VM viewModel);

  void onActionChanged(BuildContext context, VM viewModel, dynamic action) {
    AppLog.log('onActionChanged: action = $action', name: toString());
  }

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return '${super.toString(minLevel: minLevel)}.$hashCode';
  }
}

class _ViewModelViewState<VM extends IViewModel>
    extends State<IViewModelView<VM>> {
  @override
  void initState() {
    _initialise();
    AppLog.log('initState.isMounted = $mounted', name: toString());
    super.initState();
  }

  @override
  void didChangeDependencies() {
    AppLog.log('didChangeDependencies', name: toString());
    AppLog.log('didChangeDependencies.isMounted = $mounted', name: toString());
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant IViewModelView<VM> oldWidget) {
    AppLog.log('didUpdateWidget', name: toString());
    AppLog.log('didUpdateWidget.isMounted = $mounted', name: toString());
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    AppLog.log('build', name: toString());
    if (mounted) {
      _appModels(context, viewModel);
    }

    if (viewModel.isDisposed) {
      throw Exception('You cannot reuse a disposed ViewModel again.\n\n'
          'If you want to use the ViewModel as a singleton instance,\n'
          'please make a constructor of the ViewModel as below.\n\n'
          'class ContentsViewModel extends IViewModel {\n'
          ' static ContentsViewModel? _instance;\n\n'
          ' ContentsViewModel._();\n\n'
          ' static ContentsViewModel get instance {\n'
          '   if (_instance?.isDisposed ?? true) {\n'
          '     _instance = null;\n'
          '     _instance = ContentsViewModel._();\n'
          '   }\n'
          '   return _instance!;\n'
          ' }\n\n'
          ' @override\n'
          ' initialise() {}\n'
          '}\n');
    }

    return ChangeNotifierProvider<VM>(
      create: (context) {
        AppLog.log('ChangeNotifierProvider.create()', name: toString());
        return viewModel;
      },
      child: Consumer<VM>(
        builder: (context, vm, child) {
          AppLog.log('Consumer.builder()', name: toString());
          return widget.build(context, vm);
        },
      ),
    );
  }

  StreamSubscription? subscription;

  _initialise() {
    subscription = viewModel.stream.listen((action) {
      if (mounted) {
        AppLog.log('onActionChanged:action = $action',
            name: viewModel.toString());
        widget.onActionChanged(context, viewModel, action);
      }
    });
    viewModel._init();
  }

  void _appModels(BuildContext context, VM viewModel) {
    viewModel.linkAppModels(context);
  }

  VM get viewModel => widget.viewModel;

  Stream get actionStream => widget.viewModel.stream;

  @override
  void dispose() {
    subscription?.cancel();
    viewModel.dispose();
    super.dispose();
  }

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return '${super.toString(minLevel: minLevel)}.$hashCode';
  }
}
