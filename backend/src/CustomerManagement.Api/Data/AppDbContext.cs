using CustomerManagement.Api.Models;
using Microsoft.EntityFrameworkCore;

namespace CustomerManagement.Api.Data;

// The EF Core database context. It exposes the Customers table and
// is configured to use SQLite in Program.cs.
public class AppDbContext : DbContext
{
    public AppDbContext(DbContextOptions<AppDbContext> options)
        : base(options)
    {
    }

    public DbSet<Customer> Customers => Set<Customer>();
}
