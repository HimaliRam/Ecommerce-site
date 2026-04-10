using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using System;
using System.Data;
using System.Linq;

[ApiController]
[Route("api/[controller]")]
public class ProductController : ControllerBase
{
    private readonly DbHelper _db;

    public ProductController(DbHelper db)
    {
        _db = db;
    }

    // ? HOME PAGE PRODUCTS (LIMIT 12)

    [HttpGet]
    public IActionResult GetAllProducts()
    {
        try
        {
            var dt = _db.Execute(@"
 SELECT *
FROM (
    SELECT 
        Id,
        Name,
        Price,
        ImageUrl,
        Description,
        CategoryId,
        ROW_NUMBER() OVER (PARTITION BY CategoryId ORDER BY Id DESC) AS rn
    FROM Pro
    WHERE CategoryId != 11
) t
WHERE t.rn <= 2   -- ? ONLY 2 PRODUCTS PER CATEGORY
ORDER BY t.CategoryId, t.Id DESC
", new SqlParameter[] { });

            var products = dt.AsEnumerable().Select(row => new
            {
                id = Convert.ToInt32(row["Id"]),
                name = row["Name"]?.ToString(),
                price = Convert.ToDecimal(row["Price"]),
                image = row["ImageUrl"]?.ToString(),
                description = row["Description"]?.ToString(),
                categoryId = Convert.ToInt32(row["CategoryId"])
            }).Take(22).ToList(); // ? LIMIT 12

            return Ok(products);
        }
        catch (Exception ex)
        {
            return BadRequest(ex.Message);
        }
    }
}