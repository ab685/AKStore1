using System.ComponentModel.DataAnnotations;

namespace AKStore.Models
{
    public class UpdateProfileModel
    {
        [Required(AllowEmptyStrings = false, ErrorMessage = "First Name is required")]
        [RegularExpression(@"^.*\S.*$", ErrorMessage = "First Name is required")]
        public string FirstName { get; set; }

        [Required(AllowEmptyStrings = false, ErrorMessage = "Last Name is required")]
        [RegularExpression(@"^.*\S.*$", ErrorMessage = "Last Name is required")]
        public string LastName { get; set; }

        [Required(AllowEmptyStrings = false, ErrorMessage = "Phone No is required")]
        [MaxLength(10, ErrorMessage = "Enter valid number")]
        [RegularExpression(@"[0-9]{10}", ErrorMessage = "Not a valid phone number")]
        public string PhNo1 { get; set; }

        [MaxLength(10, ErrorMessage = "Enter valid number")]
        [RegularExpression(@"[0-9]{10}", ErrorMessage = "Not a valid phone number")]
        public string PhNo2 { get; set; }

        [Required(AllowEmptyStrings = false, ErrorMessage = "Address is required")]
        [RegularExpression(@"^.*\S.*$", ErrorMessage = "Address is required")]
        public string Address { get; set; }

        [Required(AllowEmptyStrings = false, ErrorMessage = "Postal code is required")]
        [RegularExpression(@"^.*\S.*$", ErrorMessage = "Postal code is required")]
        public string PostalCode { get; set; }
    }
}