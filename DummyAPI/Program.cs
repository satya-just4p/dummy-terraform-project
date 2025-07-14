using DummyAPI.Data;
using Microsoft.EntityFrameworkCore;
using Amazon.Lambda.AspNetCoreServer.Hosting;
using DummyAPI.Services;

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
// When using Lambda Environment Variable DB_CONNECTION_STRING for storing and retrieving the db credentials,
// the below code can be used
/*
var connectionString = Environment.GetEnvironmentVariable("DB_CONNECTION_STRING")
    ?? builder.Configuration.GetConnectionString("DummyDBConnectionStrings");
*/

// Below is the code when using AWS Systems Manager Parameter Store to store and retrieve DB Credentials
string connectionString = "";

/*
 * The below variable returns TRUE when the .Net Application is running inside the lambda function, because
 * AWS automatically sets the environment variable AWS_LAMBDA_FUNCTION_NAME to the name of the lmabda function.
 * FALSE when running locally or outside of Lambda, because this enviroment variable will be null or empty in this context.
 */

bool isLambda = !string.IsNullOrEmpty(Environment.GetEnvironmentVariable("AWS_LAMBDA_FUNCTION_NAME"));

if (isLambda)
{
    var dbService = new DbCredentialsService();
	connectionString = await dbService.GetConnectionStringAsync();

}
else
{
	connectionString = builder.Configuration.GetConnectionString("DummyDBConnectionStrings");
}

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
