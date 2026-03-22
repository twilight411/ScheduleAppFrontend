/// 远程 AI 聊天一次调用的结果（含可选的新建日程）
class AIChatResult {
  const AIChatResult({
    required this.reply,
    this.createdTasks = const [],
  });

  final String reply;
  /// 与后端 `Task.toJson` / `Task.fromJson` 字段一致
  final List<Map<String, dynamic>> createdTasks;
}
