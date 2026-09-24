using System.Net;
using System.Net.Http.Json;
using CustomerManagement.Api.Models;
using CustomerManagement.AcceptanceTests.Support;
using TechTalk.SpecFlow;
using Xunit;

namespace CustomerManagement.AcceptanceTests.StepDefinitions;

[Binding]
public sealed class GetCustomerSteps
{
    private readonly ScenarioWorld _world;
    private readonly ScenarioState _state;
    private Customer? _existingCustomer;

    public GetCustomerSteps(ScenarioWorld world, ScenarioState state)
    {
        _world = world;
        _state = state;
    }

    [Given(@"an existing customer with the following details")]
    public async Task GivenAnExistingCustomerWithTheFollowingDetails(Table table)
    {
        var row = table.Rows[0];
        var request = new AddCustomerRequest
        {
            FirstName = row["FirstName"],
            LastName = row["LastName"],
            Email = row["Email"]
        };

        var createResponse = await _world.Client.PostAsJsonAsync("/customers", request);
        Assert.Equal(HttpStatusCode.Created, createResponse.StatusCode);
        var created = await createResponse.Content.ReadFromJsonAsync<Customer>();
        Assert.NotNull(created);
        _existingCustomer = created;
    }

    [When(@"I request GET /customers for the existing customer id")]
    public async Task WhenIRequestGetCustomersForTheExistingCustomerId()
    {
        Assert.NotNull(_existingCustomer);
        _state.Response = await _world.Client.GetAsync($"/customers/{_existingCustomer!.Id}");
    }

    [When(@"I request GET /customers/(\-?\d+)")]
    public async Task WhenIRequestGetCustomersById(int id)
    {
        _state.Response = await _world.Client.GetAsync($"/customers/{id}");
    }

    [Then(@"the retrieved customer should match the existing customer details")]
    public async Task ThenTheRetrievedCustomerShouldMatchTheExistingCustomerDetails()
    {
        Assert.NotNull(_existingCustomer);
        Assert.NotNull(_state.Response);

        var retrieved = await _state.Response!.Content.ReadFromJsonAsync<Customer>();
        Assert.NotNull(retrieved);
        Assert.Equal(_existingCustomer!.Id, retrieved!.Id);
        Assert.Equal(_existingCustomer.FirstName, retrieved.FirstName);
        Assert.Equal(_existingCustomer.LastName, retrieved.LastName);
        Assert.Equal(_existingCustomer.Email, retrieved.Email);
    }
}
