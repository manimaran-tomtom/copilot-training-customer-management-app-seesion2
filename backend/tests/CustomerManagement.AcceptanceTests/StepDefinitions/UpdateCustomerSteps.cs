using System.Net.Http.Json;
using CustomerManagement.Api.Models;
using CustomerManagement.AcceptanceTests.Support;
using TechTalk.SpecFlow;
using Xunit;

namespace CustomerManagement.AcceptanceTests.StepDefinitions;

[Binding]
public sealed class UpdateCustomerSteps
{
    private readonly ScenarioWorld _world;
    private readonly ScenarioState _state;

    public UpdateCustomerSteps(ScenarioWorld world, ScenarioState state)
    {
        _world = world;
        _state = state;
    }

    [Given(@"an existing customer with the following details")]
    public async Task GivenAnExistingCustomerWithTheFollowingDetails(Table table)
    {
        var row = table.Rows[0];
        var createRequest = new AddCustomerRequest
        {
            FirstName = row["FirstName"],
            LastName = row["LastName"],
            Email = row["Email"]
        };

        var createResponse = await _world.Client.PostAsJsonAsync("/customers", createRequest);
        Assert.Equal(201, (int)createResponse.StatusCode);

        var created = await createResponse.Content.ReadFromJsonAsync<Customer>();
        Assert.NotNull(created);
        _world.CreatedCustomer = created;
    }

    [Given(@"updated customer details")]
    public void GivenUpdatedCustomerDetails(Table table)
    {
        var row = table.Rows[0];
        _world.UpdateRequest = new UpdateCustomerRequest
        {
            FirstName = row["FirstName"],
            LastName = row["LastName"],
            Email = row["Email"]
        };
    }

    [When(@"the customer is submitted to PUT /customers/\{id\}")]
    public async Task WhenTheCustomerIsSubmittedToPutCustomersId()
    {
        Assert.NotNull(_world.CreatedCustomer);
        Assert.NotNull(_world.UpdateRequest);
        _state.Response = await _world.Client.PutAsJsonAsync($"/customers/{_world.CreatedCustomer!.Id}", _world.UpdateRequest);
    }

    [When(@"the customer is submitted to PUT /customers/(\d+)")]
    public async Task WhenTheCustomerIsSubmittedToPutCustomers(int id)
    {
        Assert.NotNull(_world.UpdateRequest);
        _state.Response = await _world.Client.PutAsJsonAsync($"/customers/{id}", _world.UpdateRequest);
    }

    [Then(@"the updated customer should match the submitted details")]
    public async Task ThenTheUpdatedCustomerShouldMatchTheSubmittedDetails()
    {
        var updated = await ReadUpdatedCustomerAsync();
        Assert.Equal(_world.UpdateRequest!.FirstName, updated.FirstName);
        Assert.Equal(_world.UpdateRequest.LastName, updated.LastName);
        Assert.Equal(_world.UpdateRequest.Email, updated.Email);
    }

    [Then(@"the updated customer should keep the same id")]
    public async Task ThenTheUpdatedCustomerShouldKeepTheSameId()
    {
        var updated = await ReadUpdatedCustomerAsync();
        Assert.NotNull(_world.CreatedCustomer);
        Assert.Equal(_world.CreatedCustomer!.Id, updated.Id);
    }

    private async Task<Customer> ReadUpdatedCustomerAsync()
    {
        Assert.NotNull(_state.Response);

        if (_world.UpdatedCustomer is null)
        {
            var updated = await _state.Response!.Content.ReadFromJsonAsync<Customer>();
            Assert.NotNull(updated);
            _world.UpdatedCustomer = updated;
        }

        return _world.UpdatedCustomer!;
    }
}
