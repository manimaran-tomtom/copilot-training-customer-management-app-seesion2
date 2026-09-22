using CustomerManagement.Api.Models;

namespace CustomerManagement.AcceptanceTests.Support;

/// <summary>
/// Per-scenario state shared between step definitions via SpecFlow's context
/// injection. It owns the in-memory API host and HTTP client, and carries the
/// request that was built and the response that came back. SpecFlow creates one
/// instance per scenario and disposes it afterwards.
/// </summary>
public sealed class ScenarioWorld : IDisposable
{
    public ScenarioWorld()
    {
        Factory = new CustomerApiFactory();
        Client = Factory.CreateClient();
    }

    public CustomerApiFactory Factory { get; }

    public HttpClient Client { get; }

    public AddCustomerRequest? Request { get; set; }

    public Customer? CreatedCustomer { get; set; }

    public void Dispose()
    {
        Client.Dispose();
        Factory.Dispose();
    }
}
