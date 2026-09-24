Feature: Update customer
    As an API consumer
    I want to update customers via PUT /customers/{id}
    So that existing customers can be changed

Scenario: Update an existing customer with valid details
    Given an existing customer with the following details
        | FirstName | LastName | Email           |
        | Ada       | Lovelace | ada@example.com |
    And updated customer details
        | FirstName | LastName | Email             |
        | Grace     | Hopper   | grace@example.com |
    When the customer is submitted to PUT /customers/{id}
    Then the response status is 200
    And the updated customer should match the submitted details
    And the updated customer should keep the same id

Scenario: Return not found when updating a missing customer
    Given updated customer details
        | FirstName | LastName | Email             |
        | Grace     | Hopper   | grace@example.com |
    When the customer is submitted to PUT /customers/9999
    Then the response status is 404

Scenario: Reject update with invalid details
    Given an existing customer with the following details
        | FirstName | LastName | Email           |
        | Ada       | Lovelace | ada@example.com |
    And updated customer details
        | FirstName | LastName | Email        |
        |           | Hopper   | invalid-mail |
    When the customer is submitted to PUT /customers/{id}
    Then the response status is 400
