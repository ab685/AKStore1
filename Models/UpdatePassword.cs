using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;

namespace AKStore.Models
{
    public class UpdatePassword
    {
        [Required(AllowEmptyStrings = false, ErrorMessage = "Old Password is required")]
        [RegularExpression(@"^.*\S.*$", ErrorMessage = "Old Password is required")]
        public string OldPassword { get; set; }

        [DataType(DataType.Password)]
        [MinLength(6,ErrorMessage = "Password length must be more than 6 character")]
        [Required(AllowEmptyStrings = false, ErrorMessage = "New Password is required")]
        [RegularExpression(@"^.*\S.*$", ErrorMessage = "New Password is required")]
        public string NewPassword { get; set; }

        [DataType(DataType.Password)]
        [Required(AllowEmptyStrings = false, ErrorMessage = "Confirm Password is required")]
        [RegularExpression(@"^.*\S.*$", ErrorMessage = "Confirm Password is required")]
        [Compare("NewPassword", ErrorMessage = "Confirm Password is not matching with new password")]
        public string ConfirmPassword { get; set; }
    }
}