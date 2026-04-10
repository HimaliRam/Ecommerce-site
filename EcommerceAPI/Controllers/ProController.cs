using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;

[ApiController]
[Route("api/[controller]")]
public class ProController : ControllerBase
{
    private readonly IConfiguration _config;

    public ProController(IConfiguration config)
    {
        _config = config;
    }

    [HttpGet("by-category/{id}")]
    public IActionResult GetByCategory(int id)
    {
        List<object> products = new List<object>();

        // ? CORRECT WAY
        using (SqlConnection con = new SqlConnection(_config.GetConnectionString("DefaultConnection")))
        {
            string query = "SELECT * FROM Pro WHERE CategoryId = @id";

            SqlCommand cmd = new SqlCommand(query, con);
            cmd.Parameters.AddWithValue("@id", id);

            con.Open();
            SqlDataReader reader = cmd.ExecuteReader();

            while (reader.Read())
            {
                products.Add(new
                {
                    id = reader["Id"],
                    name = reader["Name"]?.ToString(),
                    price = reader["Price"],
                    image = reader["ImageUrl"]?.ToString(),
                    desc = reader["Description"]?.ToString()
                });
            }
        }

        return Ok(products);
    }
    [HttpGet("search/{query}")]
    public IActionResult SearchProducts(string query)
    {
        List<object> products = new List<object>();

        using (SqlConnection con = new SqlConnection(_config.GetConnectionString("DefaultConnection")))
        {
            string sql = "SELECT * FROM Pro WHERE Name LIKE @query";

            SqlCommand cmd = new SqlCommand(sql, con);
            cmd.Parameters.AddWithValue("@query", "%" + query + "%");

            con.Open();
            SqlDataReader reader = cmd.ExecuteReader();

            while (reader.Read())
            {
                products.Add(new
                {
                    id = reader["Id"],
                    name = reader["Name"]?.ToString(),
                    price = reader["Price"],
                    image = reader["ImageUrl"]?.ToString(),
                    description = reader["Description"]?.ToString()
                });
            }
        }

        return Ok(products);
    }
}