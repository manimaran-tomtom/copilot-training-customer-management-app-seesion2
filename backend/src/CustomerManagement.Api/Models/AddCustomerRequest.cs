using System.ComponentModel.DataAnnotations;

namespace CustomerManagement.Api.Models;

/// <summary>
/// The request body for <c>POST /customers</c>.
/// All fields are required. Data annotations provide simple, built-in validation with no extra libraries.
/// </summary>
public class AddCustomerRequest
{
    /// <summary>The customer's first name. Required.</summary>
    /// <example>Ada</example>
    [Required]
    public string FirstName { get; set; } = string.Empty;

    /// <summary>The customer's last name. Required.</summary>
    /// <example>Lovelace</example>
    [Required]
    public string LastName { get; set; } = string.Empty;

    /// <summary>The customer's email address. Required and must be a valid email format.</summary>
    /// <example>ada@example.com</example>
    [Required]
    [EmailAddress]
    public string Email { get; set; } = string.Empty;
}
