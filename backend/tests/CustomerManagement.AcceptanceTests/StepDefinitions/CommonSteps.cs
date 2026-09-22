using CustomerManagement.AcceptanceTests.Support;
using TechTalk.SpecFlow;
using Xunit;

namespace CustomerManagement.AcceptanceTests.StepDefinitions;

[Binding]
public sealed class CommonSteps
{
    private readonly ScenarioState _state;

    public CommonSteps(ScenarioState state) => _state = state;

    [Then(@"the response status is (\d+)")]
    public void ThenTheResponseStatusIs(int expectedStatus)
    {
        Assert.NotNull(_state.Response);
        Assert.Equal(expectedStatus, (int)_state.Response!.StatusCode);
    }
}
