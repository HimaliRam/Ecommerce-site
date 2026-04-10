using System.Data;
using Microsoft.Data.SqlClient;
public class DbHelper
{
    private readonly IConfiguration _config;
    private readonly string _connectionString;

    public DbHelper(IConfiguration config)
    {
        _config = config;
        _connectionString = _config.GetConnectionString("DefaultConnection");
    }

    public DataTable Execute(string query, SqlParameter[] parameters)
    {
        using (SqlConnection con = new SqlConnection(_connectionString))
        {
            using (SqlCommand cmd = new SqlCommand(query, con))
            {
                // ? AUTO DETECT QUERY OR SP
                if (query.Trim().StartsWith("SELECT", StringComparison.OrdinalIgnoreCase))
                    cmd.CommandType = CommandType.Text;
                else
                    cmd.CommandType = CommandType.StoredProcedure;

                if (parameters != null)
                    cmd.Parameters.AddRange(parameters);

                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);

                return dt;
            }
        }
    }
}