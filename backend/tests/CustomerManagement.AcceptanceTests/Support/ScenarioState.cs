using System.Net.Http;

namespace CustomerManagement.AcceptanceTests.Support;

/// <summary>
/// Holds the HTTP response for the current scenario. Injected into every step
/// class that needs to read or assert on the response, so that shared steps
/// (e.g. status-code assertions) can live in one place without duplication.
/// SpecFlow's built-in DI creates one instance per scenario.
/// </summary>
public sealed class ScenarioState
{
    public HttpResponseMessage? Response { get; set; }
}
