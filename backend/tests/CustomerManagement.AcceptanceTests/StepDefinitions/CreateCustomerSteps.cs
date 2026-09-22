using System.Net.Http.Json;
using CustomerManagement.Api.Models;
using CustomerManagement.AcceptanceTests.Support;
using TechTalk.SpecFlow;
using Xunit;

namespace CustomerManagement.AcceptanceTests.StepDefinitions;

[Binding]
public sealed class CreateCustomerSteps
{
    private readonly ScenarioWorld _world;
    private readonly ScenarioState _state;

    public CreateCustomerSteps(ScenarioWorld world, ScenarioState state)
    {
        _world = world;
        _state = state;
    }

    [Given(@"a customer with the following details")]
    public void GivenACustomerWithTheFollowingDetails(Table table)
    {
        var row = table.Rows[0];
        _world.Request = new AddCustomerRequest
        {
            FirstName = row["FirstName"],
            LastName = row["LastName"],
            Email = row["Email"]
        };
    }

    [When(@"the customer is submitted to POST /customers")]
    public async Task WhenTheCustomerIsSubmittedToPostCustomers()
    {
        Assert.NotNull(_world.Request);
        _state.Response = await _world.Client.PostAsJsonAsync("/customers", _world.Request);
    }

    [Then(@"the created customer should match the submitted details")]
    public async Task ThenTheCreatedCustomerShouldMatchTheSubmittedDetails()
    {
        var created = await ReadCreatedCustomerAsync();
        Assert.Equal(_world.Request!.FirstName, created.FirstName);
        Assert.Equal(_world.Request.LastName, created.LastName);
        Assert.Equal(_world.Request.Email, created.Email);
    }

    [Then(@"the created customer should have a generated id")]
    public async Task ThenTheCreatedCustomerShouldHaveAGeneratedId()
    {
        var created = await ReadCreatedCustomerAsync();
        Assert.True(created.Id > 0);
    }

    private async Task<Customer> ReadCreatedCustomerAsync()
    {
        Assert.NotNull(_state.Response);

        // The response content stream can only be read once, so cache the
        // parsed customer for any subsequent steps in the same scenario.
        if (_world.CreatedCustomer is null)
        {
            var created = await _state.Response!.Content.ReadFromJsonAsync<Customer>();
            Assert.NotNull(created);
            _world.CreatedCustomer = created;
        }

        return _world.CreatedCustomer!;
    }
}
