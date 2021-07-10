using System;
using System.ComponentModel.DataAnnotations;

namespace AKStore.Models
{
    public class UsersDetailsModel
    {
        [Required(AllowEmptyStrings = false, ErrorMessage = "First Name is required")]
        [RegularExpression(@"^.*\S.*$", ErrorMessage = "First Name is required")]
        public string FirstName { get; set; }

        [Required(AllowEmptyStrings = false, ErrorMessage = "Last Name is required")]
        [RegularExpression(@"^.*\S.*$", ErrorMessage = "Last Name is required")]
        public string LastName { get; set; }

        [Required(AllowEmptyStrings = false, ErrorMessage = "Username is required")]
        [RegularExpression(@"^.*\S.*$", ErrorMessage = "UserName is required")]
        public string UserName { get; set; }

        [Required(AllowEmptyStrings = false, ErrorMessage = "Password is required")]
        [DataType(DataType.Password)]
        [MinLength(6, ErrorMessage = "Password length must be more than 6 character")]
        [RegularExpression(@"^.*\S.*$", ErrorMessage = "Password is required")]
        public string Password { get; set; }

        public bool? IsActive { get; set; }
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

        public DateTime? InsertedDate { get; set; }
        public DateTime? UpdatedDate { get; set; }
    }
}