using System;
using System.ComponentModel.DataAnnotations;
using System.Web;

namespace AKStore.Models
{
    public class CategoryModel
    {
        public int Id { get; set; }
        public int DistributorId { get; set; }

        [Required(AllowEmptyStrings = false, ErrorMessage = "Category Name is required")]
        [RegularExpression(@"^.*\S.*$", ErrorMessage = "Category Name is required")]
        public string Name { get; set; }
        public string FilePath { get; set; }
        [RegularExpression(@"^.*\S.*$", ErrorMessage = "Description is not valid")]
        public string Description { get; set; }
        public DateTime? InsertedDate { get; set; }
        public DateTime? UpdatedDate { get; set; }
        public int? InsertedByUserId { get; set; }
        public int? UpdatedByUserId { get; set; }
        public HttpPostedFileBase file { get; set; }

    }
}