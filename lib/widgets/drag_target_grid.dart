part of draggable_grid_view;

class DragTargetGrid extends StatefulWidget {
  final int index;
  final VoidCallback voidCallback;
  final Widget? feedback;
  final Widget? childWhenDragging;
  final PlaceHolderWidget? placeHolder;
  final DragCompletion dragCompletion;

  const DragTargetGrid({
    Key? key,
    required this.index,
    required this.voidCallback,
    this.feedback,
    this.childWhenDragging,
    this.placeHolder,
    required this.dragCompletion,
  }) : super(key: key);

  @override
  _DragTargetGridState createState() => _DragTargetGridState();
}

class _DragTargetGridState extends State<DragTargetGrid> {


  @override
  Widget build(BuildContext context) {
    return DragTarget(
      onAccept: (data) => setState(() {
        onDragComplete(widget.index);
      }),
      onLeave: (details) {
        // print('onLeave: $details');
      },
      onWillAccept: (details) {
        return true;
      },
      onMove: (details) {
        setState(() {
          setDragStartedData(details, widget.index);
          checkIndexesAreSame(details, widget.index);
          widget.voidCallback();
        });
      },
      builder: (
        BuildContext context,
        List<dynamic> accepted,
        List<dynamic> rejected,
      ) {
        /// [isOnlyLongPress] is true then set the 'LongPressDraggableGridView' class or else set 'PressDraggableGridView' class.
        return (_isOnlyLongPress)
            ? LongPressDraggableGridView(
                index: widget.index,
                feedback: widget.feedback,
                childWhenDragging: widget.childWhenDragging,
              )
            : PressDraggableGridView(
                index: widget.index,
                feedback: widget.feedback,
                childWhenDragging: widget.childWhenDragging,
                onDragCancelled: () {
                  onDragComplete(_lastIndex);
                },
              );
      },
    );
  }

  void setDragStartedData(DragTargetDetails details, int index) {
    if (_dragStarted) {
      _dragStarted = false;
      _draggedIndexRemoved = false;
      _draggedIndex = details.data;
      _draggedChild = EmptyItem();
      _lastIndex = _draggedIndex;
    }
  }

  void checkIndexesAreSame(DragTargetDetails details, int index) {
    if (_draggedIndex != -1 && index != _lastIndex) {
      _list.removeWhere((element) {
        return (widget.placeHolder != null)
            ? element is PlaceHolderWidget
            : element is EmptyItem;
      });
      _lastIndex = index;

      if (_draggedIndex > _lastIndex) {
        _draggedChild = _orgList[_draggedIndex - 1];
      } else {
        _draggedChild = _orgList[(_draggedIndex + 1 >= _list.length)
            ? _draggedIndex
            : _draggedIndex + 1];
      }
      if (_draggedIndex == _lastIndex) {
        _draggedChild = widget.placeHolder ?? EmptyItem();
      }
      if (!_draggedIndexRemoved) {
        _draggedIndexRemoved = true;
        _list.removeAt(_draggedIndex);
      }
      _list.insert(
        _lastIndex,
        widget.placeHolder ?? EmptyItem(),
      );
    }
  }


  void onDragComplete(int index){
    _list.removeAt(index);
    _list.insert(
      index,
      _orgList[_draggedIndex],
    );
    _orgList = [..._list];
    _dragStarted = false;
    _draggedIndex = -1;
    widget.voidCallback();
    widget.dragCompletion.onDragAccept(_orgList);
  }

}
