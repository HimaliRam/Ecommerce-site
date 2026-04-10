using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using EcommerceAPI.Models;

[Route("api/[controller]")]
[ApiController]
public class OrderController : ControllerBase
{
    private readonly IConfiguration _config;

    public OrderController(IConfiguration config)
    {
        _config = config;
    }

    [HttpPost("place")]
    public IActionResult PlaceOrder(OrderDto dto)
    {
        var connStr = _config.GetConnectionString("DefaultConnection");

        if (string.IsNullOrEmpty(connStr))
        {
            return StatusCode(500, "Connection string is missing!");
        }

        using (SqlConnection con = new SqlConnection(connStr))
        {
            SqlCommand cmd = new SqlCommand("sp_PlaceOrder", con);
            cmd.CommandType = CommandType.StoredProcedure;

            cmd.Parameters.AddWithValue("@UserId", dto.UserId);
            cmd.Parameters.AddWithValue("@ProductId", dto.ProductId);
            cmd.Parameters.AddWithValue("@Quantity", dto.Quantity);

            con.Open();
            cmd.ExecuteNonQuery();
        }

        return Ok(new { message = "Order placed successfully" });
    }
    [HttpGet("{userId}")]
    public IActionResult GetOrders(int userId)
    {
        try
        {
            using (SqlConnection con = new SqlConnection(_config.GetConnectionString("DefaultConnection")))
            {
                SqlCommand cmd = new SqlCommand("sp_GetOrders", con);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@UserId", userId);

                con.Open();

                SqlDataReader reader = cmd.ExecuteReader();

                var ordersDict = new Dictionary<int, dynamic>();

                while (reader.Read())
                {
                    int orderId = Convert.ToInt32(reader["Id"]);

                    if (!ordersDict.ContainsKey(orderId))
                    {
                        ordersDict[orderId] = new
                        {
                            id = orderId,
                            orderDate = reader["OrderDate"],
                            totalAmount = reader["TotalAmount"],
                            items = new List<object>()
                        };
                    }

                    ((List<object>)ordersDict[orderId].items).Add(new
                    {
                        productId = reader["ProductId"],
                        name = reader["Name"],
                        imageUrl = reader["ImageUrl"],
                        quantity = reader["Quantity"],
                        price = reader["Price"]
                    });
                }

                return Ok(ordersDict.Values);
            }
        }
        catch (Exception ex)
        {
            return StatusCode(500, ex.Message);
        }
    }
}