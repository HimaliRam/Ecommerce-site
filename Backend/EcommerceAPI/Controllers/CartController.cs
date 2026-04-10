using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using System;
using System.Data;
using System.Linq;

[ApiController]
[Route("api/cart")]
public class CartController : ControllerBase
{
    private readonly DbHelper _db;

    public CartController(DbHelper db)
    {
        _db = db;
    }

    // ? ADD TO CART (QUERY PARAM VERSION)
    [HttpPost("add")]
    public IActionResult AddToCart([FromBody] AddCartDto dto)
    {
        if (dto == null || dto.UserId <= 0 || dto.ProductId <= 0)
        {
            return BadRequest("Invalid data");
        }

        try
        {
            _db.Execute("sp_AddToCart", new[]
            {
            new SqlParameter("@UserId", dto.UserId),
            new SqlParameter("@ProductId", dto.ProductId),
            new SqlParameter("@Quantity", dto.Quantity),
            new SqlParameter("@ProductType", "PRO") // ? IMPORTANT
        });

            return Ok(new { message = "Added to cart" });
        }
        catch (Exception ex)
        {
            // ?? LOG ACTUAL ERROR
            return BadRequest(new { error = ex.Message });
        }
    }
    // ? GET CART
    [HttpGet("{userId}")]
    public IActionResult GetCart(int userId)
    {
        var dt = _db.Execute("sp_GetCart", new[]
        {
        new SqlParameter("@UserId", userId)
    });

        var cart = dt.AsEnumerable().Select(row => new
        {
            id = Convert.ToInt32(row["Id"]),
            productId = Convert.ToInt32(row["ProductId"]),
            name = row["Name"].ToString(),
            price = Convert.ToDecimal(row["Price"]),
            image = row["Image"].ToString(),
            quantity = Convert.ToInt32(row["Quantity"])
        }).ToList();

        return Ok(cart);
    }
    // ? UPDATE QUANTITY
    [HttpPut("update")]
    public IActionResult UpdateQty([FromBody] UpdateCartDto dto)
    {
        try
        {
            if (dto == null)
                return BadRequest("Invalid data");

            _db.Execute("sp_UpdateCartQty", new[]
            {
            new SqlParameter("@CartId", dto.CartId),
            new SqlParameter("@Quantity", dto.Quantity)
        });

            return Ok(new { message = "Updated successfully" });
        }
        catch (Exception ex)
        {
            return StatusCode(500, ex.Message);
        }
    }

    // ? DELETE
    [HttpDelete("{cartId}")]
    public IActionResult Delete(int cartId)
    {
        _db.Execute("sp_DeleteCartItem", new[]
        {
            new SqlParameter("@CartId", cartId)
        });

        return Ok();
    }
}