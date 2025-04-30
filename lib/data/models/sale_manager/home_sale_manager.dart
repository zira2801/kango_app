import 'dart:convert';

class HomeSaleManager {
  final int status;
  final Charts charts;
  final Dashboard dashboard;
  final Sale sale;
  final List<Menu> menus;

  HomeSaleManager({
    required this.status,
    required this.charts,
    required this.dashboard,
    required this.sale,
    required this.menus,
  });

  factory HomeSaleManager.fromJson(Map<String, dynamic> json) {
    return HomeSaleManager(
      status: json['status'],
      charts: Charts.fromJson(json['charts']),
      dashboard: Dashboard.fromJson(json['dashboard']),
      sale: Sale.fromJson(json['sale']),
      menus: List<Menu>.from(json['menus'].map((x) => Menu.fromJson(x))),
    );
  }
}

class Charts {
  final List<String> month;
  final List<int> price;
  final List<int> profit;

  Charts({required this.month, required this.price, required this.profit});

  factory Charts.fromJson(Map<String, dynamic> json) {
    return Charts(
      month: List<String>.from(json['month']),
      price: List<int>.from(json['price']),
      profit: List<int>.from(json['profit']),
    );
  }
}

class Dashboard {
  final String managerLeader;
  final String managerSales;
  final String confirmSale;
  final String costFwd;
  final String managerLeaderLinkFwd;
  final String managerSaleLinkFwd;
  final String confirmFwd;

  Dashboard({
    required this.managerLeader,
    required this.managerSales,
    required this.confirmSale,
    required this.costFwd,
    required this.managerLeaderLinkFwd,
    required this.managerSaleLinkFwd,
    required this.confirmFwd,
  });

  factory Dashboard.fromJson(Map<String, dynamic> json) {
    return Dashboard(
      managerLeader: json['manager_leader'],
      managerSales: json['manager_sales'],
      confirmSale: json['confirm_sale'],
      costFwd: json['cost_fwd'],
      managerLeaderLinkFwd: json['manager_leader_link_fwd'],
      managerSaleLinkFwd: json['manager_sale_link_fwd'],
      confirmFwd: json['confirm_fwd'],
    );
  }
}

class Sale {
  final String title;
  final int kind;
  final String name;
  final String model;
  final String positionId;

  Sale({
    required this.title,
    required this.kind,
    required this.name,
    required this.model,
    required this.positionId,
  });

  factory Sale.fromJson(Map<String, dynamic> json) {
    return Sale(
      title: json['title'],
      kind: json['kind'],
      name: json['name'],
      model: json['model'],
      positionId: json['position_id'],
    );
  }
}

class Menu {
  final String name;
  final String key;
  final String icon;
  final String route;
  final dynamic params; // Đổi thành dynamic để xử lý cả List và Map
  final String text;
  final String textStyle;
  final List<String> positionIds;
  final bool isOnlySale;

  Menu({
    required this.name,
    required this.key,
    required this.icon,
    required this.route,
    required this.params,
    required this.text,
    required this.textStyle,
    required this.positionIds,
    required this.isOnlySale,
  });

  factory Menu.fromJson(Map<String, dynamic> json) {
    return Menu(
      name: json['name'],
      key: json['key'],
      icon: json['icon'],
      route: json['route'],
      params:
          json['params'] ?? [], // Giữ nguyên giá trị, có thể là Map hoặc List
      text: json['text'],
      textStyle: json['text-style'],
      positionIds: List<String>.from(json['position_ids']),
      isOnlySale: json['is_only_sale'],
    );
  }
}
