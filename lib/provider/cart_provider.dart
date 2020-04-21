import 'dart:convert';

import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:jd_app/model/product_detail_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartProvider with ChangeNotifier {
  List<PartData> models = [];
  bool isSelectAll = false;

  Future<void> addToCart(PartData data) async {
    // print(data.toJson());

    SharedPreferences prefs = await SharedPreferences.getInstance();
    // 存入缓存
    // List<String> list = [];
    // list.add(json.encode(data.toJson()));
    // prefs.setStringList("cartInfo", list);

    // 取出缓存
    // list = prefs.getStringList("cartInfo");
    // print(list);

    // 先把缓存里的数据取出来
    List<String> list = [];
    list = prefs.getStringList("cartInfo");
    models.clear();

    // 判断取出来的list有没有东西
    if (list == null) {
      print("缓存里没有任何商品数据");
      // 讲传递过来的数据存到缓存和数组中
      list.add(json.encode(data.toJson()));
      // 存到缓存
      prefs.setStringList("cartInfo", list);
      // 更新本地数据
      models.add(data);
      // 通知听众
      notifyListeners();
    } else {
      print("缓存里有商品数据");
      // 定义临时数组  后面解释
      List<String> tmpList = [];
      // 判断缓存中是否有对象的商品
      bool isUpdated = false;

      // 遍历缓存数组
      for (var i = 0; i < list.length; i++) {
        PartData tmpData = PartData.fromJson(json.decode(list[i]));

        // 判断商品id
        if (tmpData.id == data.id) {
          tmpData.count = data.count;
          isUpdated = true;
        }

        // 放到数组中
        String tmpDataStr = json.encode(tmpData.toJson());
        tmpList.add(tmpDataStr);
        models.add(tmpData);
      }

      // 如果缓存里的数组, 没有现在添加的商品, 那么直接添加
      if (isUpdated == false) {
        String str = json.encode(data.toJson());
        tmpList.add(str);
        models.add(data);
      }

      // 存入缓存
      prefs.setStringList("cartInfo", tmpList);

      // 通知听众
      notifyListeners();
    }
  }

  // 获取购物车商品的数量
  int getAllCount() {
    int count = 0;
    for (PartData data in this.models) {
      count += data.count;
    }
    return count;
  }

  // 获取购物车的商品
  void getCartList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> list = [];
    // 取出缓存
    list = prefs.getStringList("cartInfo");
    if (list != null) {
      for (var i = 0; i < list.length; i++) {
        PartData tmpData = PartData.fromJson(json.decode(list[i]));
        models.add(tmpData);
      }
      notifyListeners();
    }
  }

  // 删除商品
  void removeFromCart(String id) async {
    // 从缓存中删除
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> list = [];
    // 取出缓存
    list = prefs.getStringList("cartInfo");

    // 遍历缓存数据
    for (var i = 0; i < list.length; i++) {
      PartData tmpData = PartData.fromJson(json.decode(list[i]));
      if (tmpData.id == id) {
        list.remove(list[i]);
        break;
      }
    }

    // 遍历本地数据
    for (var i = 0; i < models.length; i++) {
      if (this.models[i].id == id) {
        this.models.remove(this.models[i]);
        break;
      }
    }

    // 缓存重新赋值
    prefs.setStringList("cartInfo", list);
    notifyListeners();
  }

  // 选中状态
  void changeSelectId(String id) {
    int tmpCount = 0;
    // print(id);
    for (var i = 0; i < this.models.length; i++) {
      if (id == this.models[i].id) {
        this.models[i].isSelected = !this.models[i].isSelected;
      }
      if (this.models[i].isSelected) {
        tmpCount++;
      }
    }

    // 如果tmpCount的个数 和models.length一直 那就是全选状态
    if (tmpCount == this.models.length) {
      this.isSelectAll = true;
    } else {
      this.isSelectAll = false;
    }

    notifyListeners();
  }

  // 全选
  void changeSelectAll() {
    isSelectAll = !isSelectAll;
    for (var i = 0; i < this.models.length; i++) {
      this.models[i].isSelected = isSelectAll;
    }
    notifyListeners();
  }

  // 统计合计金额
  String getAmount() {
    String amountStr = "0.00";

    for (var i = 0; i < this.models.length; i++) {
      if (this.models[i].isSelected == true) {
        num price = this.models[i].count *
            NumUtil.getNumByValueStr(this.models[i].price, fractionDigits: 2);
        num amount = NumUtil.getNumByValueStr(amountStr, fractionDigits: 2);
        amountStr = NumUtil.add(amount, price).toString();
      }
    }
    return amountStr;
  }

  // 统计选中商品个数
  int getSelectedCount() {
    int selectedCount = 0;

    for (var i = 0; i < this.models.length; i++) {
      if (this.models[i].isSelected == true) {
        selectedCount++;
      }
    }
    return selectedCount;
  }
}
