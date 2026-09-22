using System.Net;
using System.Net.Http.Json;
using CustomerManagement.Api.Data;
using CustomerManagement.Api.Models;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.Data.Sqlite;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.DependencyInjection.Extensions;
using Microsoft.Extensions.Hosting;

namespace CustomerManagement.UnitTests;

public class AddCustomerTests
{
    [Fact]
    public async Task PostCustomers_WithValidRequest_CreatesCustomerAndReturnsId()
    {
        // Arrange: start the real API in memory, but swap the SQLite database
        // for a throwaway in-memory one so the test never touches customers.db.
        await using var factory = new CustomerApiFactory();
        var client = factory.CreateClient();

        var request = new AddCustomerRequest
        {
            FirstName = "Ada",
            LastName = "Lovelace",
            Email = "ada@example.com"
        };

        // Act
        var response = await client.PostAsJsonAsync("/customers", request);

        // Assert
        Assert.Equal(HttpStatusCode.Created, response.StatusCode);

        var created = await response.Content.ReadFromJsonAsync<Customer>();
        Assert.NotNull(created);
        Assert.True(created!.Id > 0);
        Assert.Equal("Ada", created.FirstName);
        Assert.Equal("Lovelace", created.LastName);
        Assert.Equal("ada@example.com", created.Email);
    }
}

// Boots the API for testing and replaces the SQLite file database with an
// in-memory SQLite connection that lives only for the duration of the test.
internal sealed class CustomerApiFactory : WebApplicationFactory<Program>
{
    private readonly SqliteConnection connection = new("DataSource=:memory:");

    protected override void ConfigureWebHost(IWebHostBuilder builder)
    {
        // Program.cs applies migrations and enables Swagger only in Development.
        builder.UseEnvironment("Development");

        connection.Open();

        builder.ConfigureServices(services =>
        {
            services.RemoveAll<DbContextOptions<AppDbContext>>();
            services.AddDbContext<AppDbContext>(options => options.UseSqlite(connection));
        });
    }

    protected override void Dispose(bool disposing)
    {
        base.Dispose(disposing);
        if (disposing)
        {
            connection.Dispose();
        }
    }
}
