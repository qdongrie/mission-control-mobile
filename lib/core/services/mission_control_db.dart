import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;
import '../../shared/models/task_model.dart';
import '../../shared/models/approval_model.dart';
import '../../shared/models/agent_activity_model.dart';
import '../../shared/models/lead_model.dart';

class MissionControlDb {
  static Database? _db;
  static const String _dbPath = '/Users/qbot/.openclaw/workspace/mission-control/data/mission-control.db';

  static Future<Database> get db async {
    if (_db != null) return _db!;
    // Check if file exists first
    final file = File(_dbPath);
    if (!await file.exists()) {
      throw Exception('Mission Control DB not found at $_dbPath');
    }
    _db = await openDatabase(_dbPath);
    return _db!;
  }

  // Tasks
  static Future<List<TaskModel>> getTasks({String? status}) async {
    final database = await db;
    final List<Map<String, dynamic>> maps = status != null
        ? await database.query('tasks', where: 'status = ?', whereArgs: [status], orderBy: 'updated_at DESC')
        : await database.query('tasks', orderBy: 'updated_at DESC');
    return maps.map((m) => TaskModel.fromMap(m)).toList();
  }

  static Future<void> updateTaskStatus(int id, String status) async {
    final database = await db;
    await database.update('tasks', {'status': status, 'updated_at': DateTime.now().toIso8601String()},
        where: 'id = ?', whereArgs: [id]);
  }

  static Future<int> createTask(TaskModel task) async {
    final database = await db;
    return await database.insert('tasks', task.toMap());
  }

  static Future<void> deleteTask(int id) async {
    final database = await db;
    await database.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  // Approvals
  static Future<List<ApprovalModel>> getApprovals({String? status}) async {
    final database = await db;
    final List<Map<String, dynamic>> maps = status != null
        ? await database.query('approvals', where: 'status = ?', whereArgs: [status], orderBy: 'created_at DESC')
        : await database.query('approvals', orderBy: 'created_at DESC');
    return maps.map((m) => ApprovalModel.fromMap(m)).toList();
  }

  static Future<void> updateApprovalStatus(int id, String status, {String? reason}) async {
    final database = await db;
    await database.update('approvals',
        {'status': status, 'reason': reason, 'updated_at': DateTime.now().toIso8601String()},
        where: 'id = ?', whereArgs: [id]);
  }

  // Agent Activity
  static Future<List<AgentActivityModel>> getAgentActivity({int limit = 20}) async {
    final database = await db;
    final List<Map<String, dynamic>> maps = await database.query(
        'agent_activity', orderBy: 'started_at DESC', limit: limit);
    return maps.map((m) => AgentActivityModel.fromMap(m)).toList();
  }

  static Future<List<AgentActivityModel>> getActiveAgents() async {
    final database = await db;
    final List<Map<String, dynamic>> maps = await database.query(
        'agent_activity', where: 'status = ?', whereArgs: ['working'], orderBy: 'started_at DESC');
    return maps.map((m) => AgentActivityModel.fromMap(m)).toList();
  }

  // Leads
  static Future<List<LeadModel>> getLeads({String? status}) async {
    final database = await db;
    final List<Map<String, dynamic>> maps = status != null
        ? await database.query('leads', where: 'status = ?', whereArgs: [status], orderBy: 'score DESC')
        : await database.query('leads', orderBy: 'score DESC');
    return maps.map((m) => LeadModel.fromMap(m)).toList();
  }

  static Future<void> updateLeadStatus(int id, String status) async {
    final database = await db;
    await database.update('leads', {'status': status}, where: 'id = ?', whereArgs: [id]);
  }

  static Future<int> createLead(LeadModel lead) async {
    final database = await db;
    return await database.insert('leads', lead.toMap());
  }

  // Memory Events
  static Future<List<Map<String, dynamic>>> getMemoryEvents({int limit = 50}) async {
    final database = await db;
    return await database.query('memory_events', orderBy: 'timestamp DESC', limit: limit);
  }

  // Stats
  static Future<Map<String, int>> getDashboardStats() async {
    final database = await db;
    
    final pendingApprovals = Sqflite.firstIntValue(
        await database.rawQuery("SELECT COUNT(*) FROM approvals WHERE status = 'pending'")) ?? 0;
    final activeAgents = Sqflite.firstIntValue(
        await database.rawQuery("SELECT COUNT(*) FROM agent_activity WHERE status = 'working'")) ?? 0;
    final todoTasks = Sqflite.firstIntValue(
        await database.rawQuery("SELECT COUNT(*) FROM tasks WHERE status IN ('todo','in_progress')")) ?? 0;
    final newLeads = Sqflite.firstIntValue(
        await database.rawQuery("SELECT COUNT(*) FROM leads WHERE status = 'new'")) ?? 0;
    
    return {
      'pending_approvals': pendingApprovals,
      'active_agents': activeAgents,
      'todo_tasks': todoTasks,
      'new_leads': newLeads,
    };
  }
}
