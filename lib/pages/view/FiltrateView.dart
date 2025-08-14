import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FiltrateView extends StatefulWidget {
  final ValueChanged<SortType> onSortNameChanged;
  final ValueChanged<SortType> onSortVolumeChanged;
  final ValueChanged<SortType> onSortPriceChanged;
  final ValueChanged<SortType> onSortLimitsChanged;

  const FiltrateView({Key? key,
    required this.onSortNameChanged,
    required this.onSortVolumeChanged,
    required this.onSortPriceChanged,
    required this.onSortLimitsChanged}) : super(key: key);


  @override
  _FiltrateViewState createState() => _FiltrateViewState();
}

extension SortTypeExtension on SortType {
  SortType get next {
    return switch (this) {
      SortType.defaultSort => SortType.ascending,
      SortType.ascending => SortType.descending,
      SortType.descending => SortType.defaultSort,
    };
  }
}

class _FiltrateViewState extends State<FiltrateView> {
  SortType _currentNameSort = SortType.defaultSort;
  SortType _currentVolumeSort = SortType.defaultSort;
  SortType _currentPriceSort = SortType.defaultSort;
  SortType _currentLimitsSort = SortType.defaultSort;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 8.h),
      color: Colors.white,
      child: Row(
        children: [
          GestureDetector(
            onTap: ()=>{
              _toggleNameSort()
            },
            child: Row(
              children: [
                Text(
                  '名额',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),
                SizedBox(width: 3.w,),
                _buildSortIcon(_currentNameSort),
              ],
            ),
          ),
          SizedBox(width: 20.w,),
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: ()=>{
                _toggleVolumeSort()
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '24小时交易额',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                  ),
                  SizedBox(width: 3.w,),
                  _buildSortIcon(_currentVolumeSort),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: ()=>{
                _togglePriceSort()
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '最新价格',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                  ),
                  SizedBox(width: 3.w,),
                  Image.asset('assets/images/ic_home_sort_default.png',width: 8.5.w,height: 10.h,)
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: ()=>{
                _toggleLimitsSort()
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '24小时涨跌',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                  ),
                  SizedBox(width: 3.w,),
                  Image.asset('assets/images/ic_home_sort_default.png',width: 8.5.w,height: 10.h,)
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortIcon(SortType _currentSort) {
    switch (_currentSort) {
      case SortType.ascending:
        return ColorFiltered(
          colorFilter: ColorFilter.mode(Colors.green, BlendMode.srcIn),
          child: Image.asset('assets/images/ic_home_sort_default.png',width: 8.5.w,height: 10.h,),
        );
      case SortType.descending:
        return ColorFiltered(
          colorFilter: ColorFilter.mode(Colors.red, BlendMode.srcIn),
          child: Image.asset('assets/images/ic_home_sort_default.png',width: 8.5.w,height: 10.h,),
        );
      case SortType.defaultSort:
      default:
        return Image.asset('assets/images/ic_home_sort_default.png',width: 8.5.w,height: 10.h,);
    }
  }


  void _toggleNameSort() {
    setState(() {
      _currentNameSort = _currentNameSort.next;
      widget.onSortNameChanged(_currentNameSort);
    });
  }

  void _toggleVolumeSort() {
    setState(() {
      _currentVolumeSort = _currentVolumeSort.next;
      widget.onSortVolumeChanged(_currentVolumeSort);
    });
  }

  void _togglePriceSort() {
    setState(() {
      _currentPriceSort = _currentVolumeSort.next;
      widget.onSortPriceChanged(_currentPriceSort);
    });
  }

  void _toggleLimitsSort() {
    setState(() {
      _currentLimitsSort = _currentLimitsSort.next;
      widget.onSortLimitsChanged(_currentLimitsSort);
    });
  }

}


enum SortType {
  defaultSort, // 默认排序
  ascending,   // 升序
  descending,  // 降序
}