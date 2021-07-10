using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace AKStore.Models
{
    public class RetailerDetailsModel : UsersDetailsModel
    {
        public int Id { get; set; }

        [Required(ErrorMessage = "Retailer is required")]
        public int RetailerId { get; set; }

        [Required(AllowEmptyStrings = false, ErrorMessage = "Username is required")]
        [RegularExpression(@"^.*\S.*$", ErrorMessage = "UserName is required")]
        public string UserName { get; set; }


        [Required(AllowEmptyStrings = false, ErrorMessage = "Password is required")]
        [DataType(DataType.Password)]
        [RegularExpression(@"^.*\S.*$", ErrorMessage = "Password is required")]
        [MinLength(6, ErrorMessage = "Password length must be more than 6 character")]
        public string Password { get; set; }


        public int UserId { get; set; }
        public DateTime? InsertedDate { get; set; }
        public int? InsertedByUserId { get; set; }
        public DateTime? UpdatedDate { get; set; }
        public int? UpdatedByUserId { get; set; }

        public SelectList Retailers { get; set; }

        [Required(AllowEmptyStrings = false, ErrorMessage = "Name is required")]
        [RegularExpression(@"^.*\S.*$", ErrorMessage = "Name is required")]
        public string Name { get; set; }
    }
}