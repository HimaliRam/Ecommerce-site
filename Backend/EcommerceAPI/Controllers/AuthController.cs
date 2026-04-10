using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using System;
using System.Data;
using System.Linq;

[ApiController]
[Route("api/auth")]
public class AuthController : ControllerBase
{
    private readonly DbHelper _db;

    public AuthController(DbHelper db)
    {
        _db = db;
    }

    [HttpPost("register")]
    public IActionResult Register(RegisterDTO dto)
    {
        var result = _db.Execute("sp_RegisterUser", new[]
        {
            new SqlParameter("@Name", dto.Name),
            new SqlParameter("@Email", dto.Email),
            new SqlParameter("@Password", dto.Password)
        });

        var message = result.Rows[0]["Message"].ToString();

        return Ok(new
        {
            message = message
        });
    }

    [HttpPost("login")]
    public IActionResult Login(LoginDTO dto)
    {
        var result = _db.Execute("sp_LoginUser", new[]
        {
            new SqlParameter("@Email", dto.Email),
            new SqlParameter("@Password", dto.Password)
        });

        if (result.Rows.Count == 0)
            return Unauthorized("Invalid Email or Password");

        var user = result.AsEnumerable().Select(row => new {
            id = Convert.ToInt32(row["Id"]),
            name = row["Name"].ToString(),
            email = row["Email"].ToString()
        }).FirstOrDefault();

        return Ok(user);
    }

    [HttpPost("forgot-password")]
    public IActionResult ForgotPassword(ForgotPasswordDTO dto)
    {
        var result = _db.Execute("sp_GenerateOtp", new[]
        {
        new SqlParameter("@Email", dto.Email)
    });

        var message = result.Rows[0]["Message"].ToString();

        if (message == "Email not registered")
            return BadRequest(new { message });

        var otp = result.Rows[0]["Otp"].ToString();

        return Ok(new
        {
            message = "OTP sent",
            otp = otp   // ? SEND OTP TO FRONTEND
        });
    }

    [HttpPost("verify-otp")]
    public IActionResult VerifyOtp(VerifyOtpDTO dto)
    {
        var result = _db.Execute("sp_VerifyOtp", new[]
        {
        new SqlParameter("@Email", dto.Email),
        new SqlParameter("@Otp", dto.Otp)
    });

        var message = result.Rows[0]["Message"].ToString();

        if (message != "Valid")
            return BadRequest(new { message = message });

        return Ok(new { message = "OTP Verified" }); // ? FIXED
    }

    [HttpPost("reset-password")]
    public IActionResult ResetPassword(ResetPasswordDTO dto)
    {
        var result = _db.Execute("sp_ResetPassword", new[]
        {
        new SqlParameter("@Email", dto.Email),
        new SqlParameter("@Password", dto.Password)
    });

        return Ok(new { message = "Password reset successful" });
    }
}