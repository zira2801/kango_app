import 'dart:convert';

MenuResponse menuFromJson(String str) =>
    MenuResponse.fromJson(json.decode(str));

String meuToJson(MenuResponse data) => json.encode(data.toJson());

class MenuResponse {
  final int status;
  final List<MenuCategory> menu;

  MenuResponse({
    required this.status,
    required this.menu,
  });

  factory MenuResponse.fromJson(Map<String, dynamic> json) {
    return MenuResponse(
      status: json['status'] ?? 0,
      menu: (json['menu'] as List)
          .map((category) => MenuCategory.fromJson(category))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'menu': menu.map((category) => category.toJson()).toList(),
    };
  }
}

class MenuCategory {
  final String title;
  final Map<String, MenuItem> menus;

  MenuCategory({
    required this.title,
    required this.menus,
  });

  factory MenuCategory.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> menusJson = json['menus'] ?? {};
    Map<String, MenuItem> menuItems = {};

    menusJson.forEach((key, value) {
      menuItems[key] = MenuItem.fromJson(value);
    });

    return MenuCategory(
      title: json['title'] ?? '',
      menus: menuItems,
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> menusJson = {};
    menus.forEach((key, value) {
      menusJson[key] = value.toJson();
    });

    return {
      'title': title,
      'menus': menusJson,
    };
  }
}

class MenuItem {
  final String primary;
  final String title;
  final String route;
  final String icon;
  final String? tag;
  final bool isShow;

  MenuItem({
    required this.primary,
    required this.title,
    required this.route,
    required this.icon,
    this.tag,
    required this.isShow,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      primary: json['primary'] ?? '',
      title: json['title'] ?? '',
      route: json['route'] ?? '',
      icon: json['icon'] ?? '',
      tag: json['tag'],
      isShow: json['is_show'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'primary': primary,
      'title': title,
      'route': route,
      'icon': icon,
      'tag': tag,
      'is_show': isShow,
    };
  }
}
