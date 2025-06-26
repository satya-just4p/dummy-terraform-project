using DummyAPI.Data;
using Microsoft.EntityFrameworkCore;
using Amazon.Lambda.AspNetCoreServer.Hosting;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.

builder.Services.AddControllers();

// Making this project as Lambda Compatible
builder.Services.AddAWSLambdaHosting(LambdaEventSource.HttpApi);

// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Injecting connection string stored in appsettings.json

//builder.Services.AddDbContext<dummyDbContext>(options =>
//options.UseSqlServer(builder.Configuration.GetConnectionString("DummyDBConnectionStrings")));

// Connection Strings modified for TerraForm Deployment and Local Environment
var connectionString = Environment.GetEnvironmentVariable("DB_CONNECTION_STRING")
    ?? builder.Configuration.GetConnectionString("DummyDBConnectionStrings");

builder.Services.AddDbContext<dummyDbContext>(options =>
options.UseSqlServer(connectionString));

// CORS definition goes here
//builder.Services.AddCors(options =>
//{
//    options.AddPolicy("AllowdummyCors",
//        builder =>
//        {
//            builder.WithOrigins("http://localhost:4200", "https://localhost:4200")
//            .AllowAnyHeader()
//            .AllowAnyMethod();
//        });

//});

// CORS definition modified for TerramForm Deployment and Local Environment

var allowOrigins = Environment.GetEnvironmentVariable("CORS_ALLOWED_ORIGINS")
    ?? "http://localhost:4200,https://localhost:4200";

var allowOriginsArray = allowOrigins.Split(',',StringSplitOptions.RemoveEmptyEntries);

builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowdummyCors",
        builder =>
        {
            builder.WithOrigins(allowOriginsArray)
            .AllowAnyHeader()
            .AllowAnyMethod();
        });
});

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

app.UseCors("AllowdummyCors");

app.UseAuthorization();

app.MapControllers();

app.MapGet("/",() => "Dummy Project welcomes you");

app.Run();
