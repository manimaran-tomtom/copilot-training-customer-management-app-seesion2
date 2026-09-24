using System.Net;
using System.Net.Http.Json;
using CustomerManagement.Api.Models;

namespace CustomerManagement.UnitTests;

public class UpdateCustomerTests
{
    [Fact]
    public async Task PutCustomers_WithValidRequest_UpdatesCustomerAndReturnsUpdatedRecord()
    {
        await using var factory = new CustomerApiFactory();
        var client = factory.CreateClient();

        var createRequest = new AddCustomerRequest
        {
            FirstName = "Ada",
            LastName = "Lovelace",
            Email = "ada@example.com"
        };

        var createResponse = await client.PostAsJsonAsync("/customers", createRequest);
        var created = await createResponse.Content.ReadFromJsonAsync<Customer>();
        Assert.NotNull(created);

        var updateRequest = new UpdateCustomerRequest
        {
            FirstName = "Grace",
            LastName = "Hopper",
            Email = "grace@example.com"
        };

        var response = await client.PutAsJsonAsync($"/customers/{created!.Id}", updateRequest);

        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        var updated = await response.Content.ReadFromJsonAsync<Customer>();
        Assert.NotNull(updated);
        Assert.Equal(created.Id, updated!.Id);
        Assert.Equal("Grace", updated.FirstName);
        Assert.Equal("Hopper", updated.LastName);
        Assert.Equal("grace@example.com", updated.Email);
    }

    [Fact]
    public async Task PutCustomers_WithUnknownId_ReturnsNotFound()
    {
        await using var factory = new CustomerApiFactory();
        var client = factory.CreateClient();

        var updateRequest = new UpdateCustomerRequest
        {
            FirstName = "Grace",
            LastName = "Hopper",
            Email = "grace@example.com"
        };

        var response = await client.PutAsJsonAsync("/customers/9999", updateRequest);

        Assert.Equal(HttpStatusCode.NotFound, response.StatusCode);
    }

    [Fact]
    public async Task PutCustomers_WithInvalidRequest_ReturnsBadRequestValidationProblem()
    {
        await using var factory = new CustomerApiFactory();
        var client = factory.CreateClient();

        var invalidRequest = new UpdateCustomerRequest
        {
            FirstName = "",
            LastName = "Hopper",
            Email = "not-an-email"
        };

        var response = await client.PutAsJsonAsync("/customers/1", invalidRequest);

        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
        var body = await response.Content.ReadAsStringAsync();
        Assert.Contains("\"errors\"", body);
    }
}
