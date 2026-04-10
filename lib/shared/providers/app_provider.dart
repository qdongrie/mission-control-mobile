import 'package:flutter/foundation.dart';
import '../../core/services/mission_control_db.dart';
import '../models/task_model.dart';
import '../models/approval_model.dart';
import '../models/agent_activity_model.dart';
import '../models/lead_model.dart';

class AppProvider extends ChangeNotifier {
  // Stats
  int _pendingApprovals = 0;
  int _activeAgents = 0;
  int _todoTasks = 0;
  int _newLeads = 0;

  // Data
  List<TaskModel> _tasks = [];
  List<ApprovalModel> _approvals = [];
  List<ApprovalModel> _pendingApprovalsList = [];
  List<AgentActivityModel> _agentActivity = [];
  List<AgentActivityModel> _activeAgentsList = [];
  List<LeadModel> _leads = [];
  List<Map<String, dynamic>> _memoryEvents = [];

  // Loading states
  bool _isLoading = false;
  String? _error;

  // Getters
  int get pendingApprovals => _pendingApprovals;
  int get activeAgents => _activeAgents;
  int get todoTasks => _todoTasks;
  int get newLeads => _newLeads;
  List<TaskModel> get tasks => _tasks;
  List<ApprovalModel> get approvals => _approvals;
  List<ApprovalModel> get pendingApprovalsList => _pendingApprovalsList;
  List<AgentActivityModel> get agentActivity => _agentActivity;
  List<AgentActivityModel> get activeAgentsList => _activeAgentsList;
  List<LeadModel> get leads => _leads;
  List<Map<String, dynamic>> get memoryEvents => _memoryEvents;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadDashboard() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final stats = await MissionControlDb.getDashboardStats();
      _pendingApprovals = stats['pending_approvals'] ?? 0;
      _activeAgents = stats['active_agents'] ?? 0;
      _todoTasks = stats['todo_tasks'] ?? 0;
      _newLeads = stats['new_leads'] ?? 0;
      
      _activeAgentsList = await MissionControlDb.getActiveAgents();
      _memoryEvents = await MissionControlDb.getMemoryEvents(limit: 20);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadApprovals() async {
    try {
      _approvals = await MissionControlDb.getApprovals();
      _pendingApprovalsList = _approvals.where((a) => a.isPending).toList();
      _pendingApprovals = _pendingApprovalsList.length;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadTasks({String? status}) async {
    try {
      _tasks = await MissionControlDb.getTasks(status: status);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadLeads({String? status}) async {
    try {
      _leads = await MissionControlDb.getLeads(status: status);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadAgentActivity() async {
    try {
      _agentActivity = await MissionControlDb.getAgentActivity(limit: 50);
      _activeAgentsList = await MissionControlDb.getActiveAgents();
      _activeAgents = _activeAgentsList.length;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> approveItem(int id) async {
    try {
      await MissionControlDb.updateApprovalStatus(id, 'approved');
      await loadApprovals();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> rejectItem(int id, {String? reason}) async {
    try {
      await MissionControlDb.updateApprovalStatus(id, 'rejected', reason: reason);
      await loadApprovals();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateTaskStatus(int id, String status) async {
    try {
      await MissionControlDb.updateTaskStatus(id, status);
      await loadTasks();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateLeadStatus(int id, String status) async {
    try {
      await MissionControlDb.updateLeadStatus(id, status);
      await loadLeads();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> createTask(TaskModel task) async {
    try {
      await MissionControlDb.createTask(task);
      await loadTasks();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> refreshAll() async {
    await Future.wait([
      loadDashboard(),
      loadApprovals(),
      loadTasks(),
      loadLeads(),
      loadAgentActivity(),
    ]);
  }
}
