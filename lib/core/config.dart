// Mission Control DB path - points to main Mission Control SQLite
class DbConfig {
  // Path to the Mission Control SQLite database
  static const String dbPath = '/Users/qbot/.openclaw/workspace/mission-control/data/mission-control.db';
  
  // API base URL (Mission Control Next.js server)
  static const String apiBase = 'http://localhost:3001/api';
  
  // App settings
  static const String appName = 'Mission Control';
  static const String appVersion = '1.0.0';
}
