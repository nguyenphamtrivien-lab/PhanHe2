using System;
using System.Data;
using Oracle.ManagedDataAccess.Client;

namespace QLBV.DAL
{
    public class OracleDataProvider : IDisposable
    {
        private static OracleDataProvider _instance;
        public static OracleDataProvider Instance
        {
            get
            {
                if (_instance == null)
                    throw new InvalidOperationException("ChÆ°a thiáº¿t láº­p káº¿t ná»‘i.");
                return _instance;
            }
        }

        private const string DEFAULT_HOST = "localhost";
        private const int DEFAULT_PORT = 1521;
        private const string DEFAULT_SERVICE = "ORCLPDB";

        private readonly string _connectionString;
        private OracleConnection _connection;
        private bool _disposed = false;

        public string CurrentUser { get; private set; }

        public OracleDataProvider(string username, string password,
            string host = DEFAULT_HOST, int port = DEFAULT_PORT,
            string serviceName = DEFAULT_SERVICE)
        {
            CurrentUser = username;
            _connectionString = new OracleConnectionStringBuilder
            {
                UserID = username,
                Password = password,
                DataSource = $"(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST={host})(PORT={port}))(CONNECT_DATA=(SERVICE_NAME={serviceName})))",
                Pooling = true,
                MinPoolSize = 1,
                MaxPoolSize = 10,
                ConnectionTimeout = 30
            }.ConnectionString;
        }

        public OracleConnection GetConnection()
        {
            if (_connection == null) _connection = new OracleConnection(_connectionString);
            if (_connection.State != ConnectionState.Open) _connection.Open();
            return _connection;
        }

        public void CloseConnection()
        {
            if (_connection != null && _connection.State == ConnectionState.Open)
                _connection.Close();
        }

        public bool TestConnection()
        {
            try { using var conn = new OracleConnection(_connectionString); conn.Open(); return true; }
            catch { return false; }
        }

        public DataTable ExecuteQuery(string sql, OracleParameter[] parameters = null)
        {
            var dataTable = new DataTable();
            using var cmd = new OracleCommand(sql, GetConnection());
            if (parameters != null) cmd.Parameters.AddRange(parameters);
            using var adapter = new OracleDataAdapter(cmd);
            adapter.Fill(dataTable);
            return dataTable;
        }

        public int ExecuteNonQuery(string sql, OracleParameter[] parameters = null)
        {
            using var cmd = new OracleCommand(sql, GetConnection());
            if (parameters != null) cmd.Parameters.AddRange(parameters);
            return cmd.ExecuteNonQuery();
        }

        public static OracleDataProvider CreateSession(string username, string password)
        {
            _instance?.Dispose();
            _instance = new OracleDataProvider(username, password);
            return _instance;
        }

        public static void DestroySession()
        {
            _instance?.Dispose();
            _instance = null;
        }

        public void Dispose()
        {
            if (!_disposed) { CloseConnection(); _connection?.Dispose(); _connection = null; _disposed = true; }
            GC.SuppressFinalize(this);
        }
    }
}
