using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Web;
using System.Web.Mvc;

namespace AKStore.Models
{
    public class ProductModel
    {
        public int Id { get; set; }

        [Required(AllowEmptyStrings = false, ErrorMessage = "Product Name is required")]
        [RegularExpression(@"^.*\S.*$", ErrorMessage = "Product Name is required")]
        public string Name { get; set; }
        public string CompanyName { get; set; }
        public string CategoryName { get; set; }

        [Required(AllowEmptyStrings = false, ErrorMessage = "Please select company")]
        public int? CompanyId { get; set; }

        [Required(AllowEmptyStrings =false,ErrorMessage ="Price is required")]
        [Range(0.000001,10000000,ErrorMessage ="Please enter valid price")]
        public decimal Price { get; set; } 

        
        [Range(0,10000000,ErrorMessage = "Please enter valid quantity")]
        [Required(AllowEmptyStrings = false, ErrorMessage="Please enter quantity")]
        public int? Quantity { get; set; }


        [MaxLength(100,ErrorMessage = "Description length should be maximum up to 100 characters.")]
        public string Description { get; set; }

        public DateTime? InsertedDate { get; set; }
        public DateTime? UpdatedDate { get; set; }
        public HttpPostedFileBase file { get; set; }
        public string FilePath { get; set; }


        public SelectList Company { get; set; }

    }
}
