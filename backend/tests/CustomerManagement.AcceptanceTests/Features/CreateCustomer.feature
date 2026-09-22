Feature: Create customer
    As an API consumer
    I want to create customers via POST /customers
    So that new customers are persisted and returned

Scenario: Create a customer with valid details
    Given a customer with the following details
        | FirstName | LastName | Email           |
        | Ada       | Lovelace | ada@example.com |
    When the customer is submitted to POST /customers
    Then the response status is 201
    And the created customer should match the submitted details
    And the created customer should have a generated id

Scenario: Reject a customer with a missing required field
    Given a customer with the following details
        | FirstName | LastName | Email           |
        |           | Lovelace | ada@example.com |
    When the customer is submitted to POST /customers
    Then the response status is 400
