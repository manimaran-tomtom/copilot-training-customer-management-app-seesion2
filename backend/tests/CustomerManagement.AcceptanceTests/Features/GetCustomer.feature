Feature: Get customer by id
    As an API consumer
    I want to retrieve a customer via GET /customers/{id}
    So that I can fetch an existing customer record

Scenario: Retrieve an existing customer by id
    Given an existing customer with the following details
        | FirstName | LastName | Email             |
        | Grace     | Hopper   | grace@example.com |
    When I request GET /customers for the existing customer id
    Then the response status is 200
    And the retrieved customer should match the existing customer details

Scenario: Requesting an unknown customer id returns not found
    When I request GET /customers/99999
    Then the response status is 404

Scenario: Requesting a non-positive customer id returns not found
    When I request GET /customers/0
    Then the response status is 404
