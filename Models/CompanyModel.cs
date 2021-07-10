using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Web;
using System.Web.Mvc;

namespace AKStore.Models
{
    public class CompanyModel
    {
        public int Id { get; set; }
        public int DistributorId { get; set; }

        [Required(AllowEmptyStrings = false, ErrorMessage = "Category  is required")]
        public int CategoryId { get; set; }
        public string CategoryName { get; set; }

        [Required(AllowEmptyStrings = false, ErrorMessage = "Company Name is required")]
        [RegularExpression(@"^.*\S.*$", ErrorMessage = "Company Name is required")]
        public string Name { get; set; }
        public string FilePath { get; set; }

        [RegularExpression(@"^.*\S.*$", ErrorMessage = "Description is not valid")]
        public string Description { get; set; }
        public DateTime? InsertedDate { get; set; }
        public DateTime? UpdatedDate { get; set; }
        public int? InsertedByUserId { get; set; }
        public int? UpdatedByUserId { get; set; }
        public HttpPostedFileBase file { get; set; }
        public SelectList Category { get; set; }
    }
}