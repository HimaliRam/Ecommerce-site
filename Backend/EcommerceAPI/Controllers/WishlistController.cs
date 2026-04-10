using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using System;
using System.Data;
using System.Linq;

[ApiController]
[Route("api/wishlist")]
public class WishlistController : ControllerBase
{
    private readonly DbHelper _db;

    public WishlistController(DbHelper db)
    {
        _db = db;
    }

    // ? ADD
    [HttpPost("add")]
    public IActionResult Add(int userId, int productId)
    {
        if (userId <= 0)
            return Unauthorized("Login required");

        _db.Execute("sp_AddToWishlist", new[]
        {
            new SqlParameter("@UserId", userId),
            new SqlParameter("@ProductId", productId)
        });

        return Ok(new { message = "Added to wishlist" });
    }

    // ? GET
    [HttpGet("{userId}")]
    public IActionResult Get(int userId)
    {
        var dt = _db.Execute("sp_GetWishlist", new[]
        {
            new SqlParameter("@UserId", userId)
        });

        var data = dt.AsEnumerable().Select(row => new
        {
            id = Convert.ToInt32(row["Id"]),
            productId = Convert.ToInt32(row["ProductId"]),
            name = row["Name"].ToString(),
            price = Convert.ToDecimal(row["Price"]),
            image = row["Image"].ToString()
        }).ToList();

        return Ok(data);
    }

    // ? DELETE
    [HttpDelete("remove")]
    public IActionResult Remove(int userId, int productId)
    {
        try
        {
            if (userId <= 0)
                return Unauthorized("Login required");

            _db.Execute("sp_DeleteWishlist", new[]
            {
            new SqlParameter("@UserId", userId),
            new SqlParameter("@ProductId", productId)
        });

            return Ok(new { message = "Removed from wishlist" });
        }
        catch (Exception ex)
        {
            return StatusCode(500, ex.Message);
        }
    }
}