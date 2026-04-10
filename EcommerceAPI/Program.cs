var builder = WebApplication.CreateBuilder(args);

// ? Add services
builder.Services.AddControllers();
builder.Services.AddSingleton<DbHelper>();

// ? Swagger
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// ? CORS (MUST be before build)
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll",
        policy => policy.AllowAnyOrigin()
                        .AllowAnyMethod()
                        .AllowAnyHeader());
});

var app = builder.Build();

// ? Middleware
app.UseCors("AllowAll");

// ? Swagger middleware
app.UseSwagger();
app.UseSwaggerUI();

// ? Optional root test
app.MapGet("/", () => "API is running...");

// ? Map controllers
app.MapControllers();

app.Run();