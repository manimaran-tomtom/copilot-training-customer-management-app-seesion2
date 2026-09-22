using CustomerManagement.Api.Data;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.Data.Sqlite;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.DependencyInjection.Extensions;

namespace CustomerManagement.AcceptanceTests.Support;

/// <summary>
/// Boots the API in memory for acceptance testing and replaces the SQLite file
/// database with an in-memory SQLite connection that lives only for the
/// duration of a single scenario, so tests never touch customers.db.
/// </summary>
public sealed class CustomerApiFactory : WebApplicationFactory<Program>
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
