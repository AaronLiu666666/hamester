import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../tag_manage/model/dto/search_dto.dart';

class MediaSearchProvider extends ChangeNotifier {
  SearchDTO _searchDTO = SearchDTO(); // 初始搜索 DTO

  SearchDTO get searchDTO => _searchDTO;

  void setSearchDTO(SearchDTO searchDTO) {
    _searchDTO = searchDTO;
    notifyListeners(); // 通知听众更新
  }
}